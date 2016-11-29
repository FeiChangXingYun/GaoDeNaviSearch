//
//  SearchResultListVC.m
//  GaoDeNaviSearch
//
//  Created by pro on 16/3/16.
//  Copyright © 2016年 JYY. All rights reserved.
//

#import "SearchResultListVC.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "SearchListTableViewCell.h"
@interface SearchResultListVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) AMapTip *mapTip;

@end

@implementation SearchResultListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"SearchListTableViewCell" bundle:nil] forCellReuseIdentifier:CELLID];
}


- (NSArray *)listArray
{
    if(_listArray == nil)
    {
        _listArray = [[NSArray alloc] init];
    }
    return _listArray;
}

#pragma mark -setter&getter
- (UITableView*)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *TV = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
            TV.separatorColor = [UIColor redColor];
            TV.backgroundColor = [UIColor clearColor];
            TV.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.jpg"]];
            TV.delegate = self;
            TV.dataSource = self;
            TV;
        });
    }
    return _tableView;
}
-(AMapTip*)mapTip{
    if (!_mapTip) {
        _mapTip = ({
            AMapTip *AMT = [[AMapTip alloc] init];
            AMT;
        });
    }
    return _mapTip;
}

#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.listArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLID forIndexPath:indexPath];
    self.mapTip = self.listArray[indexPath.row];
    cell.topLabel.text = self.mapTip.name;
    cell.bottomLabel.text = self.mapTip.district;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:@"location"];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
