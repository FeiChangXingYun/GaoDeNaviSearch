//
//  ViewController.m
//  GaoDeNaviSearch
//
//  Created by pro on 16/3/15.
//  Copyright © 2016年 JYY. All rights reserved.
//

#import "ViewController.h"
#import <AMapNaviKit/MAMapKit.h>//这个头文件至关重要
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "SearchResultListVC.h"
#import "CustomAnnotationView.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<MAMapViewDelegate,AMapNaviManagerDelegate,AMapSearchDelegate,AMapLocationManagerDelegate,AMapNaviViewControllerDelegate>

@property (strong, nonatomic) MAMapView  *mapView;
@property (strong, nonatomic) MAPointAnnotation *pointAnnotation;//大头针标注
@property (strong, nonatomic) MAPointAnnotation *myPointAnnotation;//我的位置的大头针
@property (strong, nonatomic) AMapNaviManager *naviManager;//导航管理器
@property (strong, nonatomic) AMapGeoPoint *geoPoint;//用于记录终点的位置
@property (strong, nonatomic) AMapSearchAPI *mapSearchAPI;//搜索的，正向地理编码
@property (strong, nonatomic) AMapSearchAPI *unMapSearchAPIPara;//反相地理编码
@property (strong, nonatomic) AMapNaviViewController *naviViewController; //导航视图控制器
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double longitude;
@property (copy, nonatomic) NSString *addrString;
@property (copy, nonatomic) NSString *titleString;
@property (strong, nonatomic) AMapLocationManager *locationManager;
@property (strong, nonatomic) AMapSearchAPI *promptSearch;
@property (strong, nonatomic) SearchResultListVC *searchResultVC;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [MAMapServices sharedServices].apiKey = APPKey;
    [AMapSearchServices sharedServices].apiKey = APPKey;
    [AMapNaviServices sharedServices].apiKey = APPKey;
    [self.view addSubview:self.mapView];
    [self initNaviManager];
    self.unMapSearchAPIPara = [[AMapSearchAPI alloc] init];
    self.unMapSearchAPIPara.delegate = self;
    [self  initNotificationCenter];
    self.searchResultVC = [[SearchResultListVC alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (IBAction)daoHangButtonClick:(id)sender {
    [self.view endEditing:YES];
    [self initMapSearch];//正地理编码
    [self initNaviViewController];
    [self routeCal];
}

- (IBAction)searchButtonClick:(id)sender {
    [self  initMapSearch:self.searchTF.text];
    
}

//初始化导航管理对象
- (void)initNaviManager
{
    if (_naviManager == nil){
        _naviManager = [[AMapNaviManager alloc] init];
        _naviManager.delegate = self;
    }
}

//通过按钮点击来调用该方法 ,来导航
- (void)routeCal
{
    //设置起点为住的地方
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:self.latitude longitude:self.longitude];
    //终点为公司地址
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:self.geoPoint.latitude longitude:self.geoPoint.longitude];
    NSArray *startPoints = @[startPoint];
    NSArray *endPoints   = @[endPoint];
    //驾车路径规划（未设置途经点、导航策略为速度优先）
    [_naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];
//        NSLog(@"选择了驾车");
    
    //    //步行路径规划
//         [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
//        NSLog(@"选择了步行");
    
}

//正向地理编码获取目的地的经纬度
- (void)initMapSearch
{
    AMapSearchAPI *mapSearchAPI = [[AMapSearchAPI alloc] init];
    mapSearchAPI.delegate = self;
    self.mapSearchAPI = mapSearchAPI;
    //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
//    geo.address = @"北京市昌平区天通苑北地铁站";
    geo.address = self.endTF.text;
    [self.mapSearchAPI  AMapGeocodeSearch:geo]; //开始搜索会调用下面的方法
}

//带参数的正向地理编码
-(void)initMapSearch:(NSString*)string{
    AMapSearchAPI *mapSearchAPI = [[AMapSearchAPI alloc] init];
    mapSearchAPI.delegate = self;
    self.mapSearchAPI = mapSearchAPI;
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = string;
    [self.mapSearchAPI  AMapGeocodeSearch:geo];
}

#pragma mark -AMapSearchAPIDelegate
//实现正向地理编码的回调函数
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0){
        return;
    }
    //通过AMapGeocodeSearchResponse对象处理搜索结果
    // NSString *strCount = [NSString stringWithFormat:@"count: %ld", (long)response.count];
    NSString *strGeocodes = @"";
    for (AMapTip *p in response.geocodes)
    {
        AMapGeoPoint *geoPoint = [[AMapGeoPoint alloc] init];
        strGeocodes = [NSString stringWithFormat:@"%@\ngeocode: %@", strGeocodes, p.description];
//        NSLog(@"纬度 %f,经度%f",p.location.latitude,p.location.longitude);
        geoPoint = p.location;
        self.geoPoint = geoPoint;//获得反相地理编码的经度和纬度；
    }
    [self initUnMapSearchAPIlatitude:self.geoPoint.latitude longitude:self.geoPoint.longitude];
    [self.mapView addAnnotation:self.pointAnnotation];//添加搜索的大头针
    //    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strGeocodes];
    //    NSLog(@"Geocode: %@", result);
    //开始获取geocode的经纬度
}

//路径规划成功的回调函数 ，就是导航按钮点击之后调用的方法
- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    //导航视图展示
    [_naviManager presentNaviViewController:_naviViewController animated:YES];
}

//导航视图被展示出来的回调函数 ,上面的函数调用之后才会被调用
- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    //    [super naviManager:naviManager didPresentNaviViewController:naviViewController];
    //调用startGPSNavi方法进行实时导航，调用startEmulatorNavi方法进行模拟导航
    [_naviManager startGPSNavi];
}

//导航视图初始化
- (void)initNaviViewController
{
    if (_naviViewController == nil){
        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
    }
}

//传入两个经纬度转化为逆向地理编码
-(void)initUnMapSearchAPIlatitude:(double)latitude  longitude:(double)longitude{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:latitude    longitude:longitude];
    regeo.radius = 20000;
    regeo.requireExtension = YES;
    [self.unMapSearchAPIPara AMapReGoecodeSearch:regeo];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        self.titleString = [NSString stringWithFormat:@"%@%@%@%@%@%@", response.regeocode.addressComponent.province,response.regeocode.addressComponent.city,response.regeocode.addressComponent.district,response.regeocode.addressComponent.township,response.regeocode.addressComponent.neighborhood,response.regeocode.addressComponent.building];
        for (AMapRoad  *mapRoad in response.regeocode.roads) {
//            NSLog(@"uid:%@-%@-%ld -%@",mapRoad.uid,mapRoad.name,mapRoad.distance,mapRoad.direction);
            self.addrString = [NSString stringWithFormat:@"%@  %ldm 方向:%@",mapRoad.name,mapRoad.distance,mapRoad.direction];
        }
        [self.mapView addAnnotation:self.myPointAnnotation];
    }
}
#pragma mark - setter&getter
-(MAMapView*)mapView{
    if (!_mapView) {
        _mapView = ({
            MAMapView *mapV = [[MAMapView alloc] initWithFrame:CGRectMake(0, 150, FRAME_WIDTH, FRAME_HEIGHT)];
            mapV.delegate = self;
            mapV.showsUserLocation = YES;
            [mapV  setUserTrackingMode:MAUserTrackingModeFollowWithHeading  animated:YES];//地图跟看位置移动，定位图层有三种显示模式
            [mapV setZoomLevel:16.1 animated:YES];//覆盖物的半径
            mapV;
        });
    }
    return _mapView;
}
#pragma mark -MAMapViewDelegate
//当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation){
        //取出当前位置的坐标
       //NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        self.latitude = userLocation.coordinate.latitude;
        self.longitude = userLocation.coordinate.longitude;
        [self initUnMapSearchAPIlatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    }
}

#pragma mark setter&getter
//添加搜索的大头针，指定的位置
-(MAPointAnnotation*)pointAnnotation{
    if (!_pointAnnotation) {
        _pointAnnotation = ({
            MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(self.geoPoint.latitude, self.geoPoint.longitude);
            pointAnnotation.title = self.searchTF.text;
//            pointAnnotation.subtitle = self.addrString;
            pointAnnotation;
        });
    }
    return _pointAnnotation;
}
//我的位置的大头针
-(MAPointAnnotation*)myPointAnnotation{
    if (!_myPointAnnotation) {
        _myPointAnnotation = ({
            MAPointAnnotation *myPA = [[MAPointAnnotation alloc] init];
            myPA.coordinate =CLLocationCoordinate2DMake(self.latitude, self.longitude);
            myPA.title = self.titleString;
            myPA.subtitle = self.addrString;
            myPA;
        });
    }
    return _myPointAnnotation;
}
//添加的气泡
//实现 <MAMapViewDelegate> 协议中的 mapView:viewForAnnotation:回调函数，设置标注样式
/*
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        annotationView.image = [UIImage imageNamed:@"location"];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}
 */
//自定义气泡的全过程
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"location"];
        // 设置为NO，用以调用自定义的calloutView
        annotationView.canShowCallout = NO;
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

//导航出来之后，下面的导航 x按钮执行的方法
//点击导航界面的取消按钮取消导航
- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    [self.naviManager stopNavi];
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

//输入提示搜索
- (void)inputPromptSearch{
    //初始化检索对象
    self.promptSearch = [[AMapSearchAPI alloc] init];
    self.promptSearch.delegate = self;
    //构造AMapInputTipsSearchRequest对象，设置请求参数
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = self.searchTF.text;
    tipsRequest.city = @"北京";
    //发起输入提示搜索
    [self.promptSearch AMapInputTipsSearch: tipsRequest];
}

//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request  response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0){
        return;
    }
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld", response.count];
    NSString *strtips = @"";
    
    for (AMapTip *p in response.tips) {
        strtips = [NSString stringWithFormat:@"%@\nTip: %@ %@ %@", strtips, p.description,p.district,p.name];
        NSLog(@"===%@ %@ %@",p.description,p.district,p.name);
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strtips];
//    NSLog(@"InputTips: %@", result);
    self.searchResultVC.listArray = response.tips;
    [self  presentViewController:self.searchResultVC animated:YES completion:nil];
}
- (IBAction)soundButton:(id)sender {
    NSString *string = nil;
    UIButton *button = (UIButton*)sender;
    if (button.tag==10) {
        string = @"hello walk";
    }else {
        string = @"hello drive";
    }
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"hello walk"];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    utterance.voice = voice;
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    [synth speakUtterance:utterance];
}







//语音播报
//- (void)naviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
//{
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [_iFlySpeechSynthesizer startSpeaking:soundString];//soundString为导航引导语
//    });
//}









//注册通知
-(void)initNotificationCenter{
    NSNotificationCenter *notifiCen = [NSNotificationCenter  defaultCenter];
    [notifiCen addObserver:self  selector:@selector(observerSearch:) name:UITextFieldTextDidEndEditingNotification object:self.searchTF];
}
- (void)observerSearch:(NSNotification*)notification{
    NSLog(@"%s",__func__);
    [self  inputPromptSearch];
}

//让键盘下落
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
