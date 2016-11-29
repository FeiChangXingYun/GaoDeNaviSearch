//
//  CalloutViewController.m
//  GaoDeNaviSearch
//
//  Created by pro on 16/3/17.
//  Copyright © 2016年 JYY. All rights reserved.
//

#import "CalloutViewController.h"
#import "ViewController.h"

@interface CalloutViewController ()
@property(strong, nonatomic)ViewController *VC;
@end

@implementation CalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"2.jpg"];
    [self.view addSubview:imageView];
    self.title = @"气泡的详细页面";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftBarButtonClick:)];
    self.navigationItem.leftBarButtonItem = item;
    // Do any additional setup after loading the view from its nib.
}

//-(void)leftBarButtonClick:(UIBarButtonItem*)item{
//    [[UIApplication sharedApplication].windows objectAtIndex:0].rootViewController = self.VC;
//}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [[UIApplication sharedApplication].windows objectAtIndex:0].rootViewController = self.VC;
//}
#pragma mark -setter&getter
-(ViewController*)VC{
    if (!_VC) {
        _VC = [[ViewController alloc] init];
    }
    return _VC;
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
