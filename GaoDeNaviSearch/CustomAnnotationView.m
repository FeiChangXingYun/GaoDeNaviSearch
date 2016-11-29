//
//  CustomAnnotationView.m
//  GaoDeNaviSearch
//
//  Created by pro on 16/3/17.
//  Copyright © 2016年 JYY. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "CalloutViewController.h"
@interface CustomAnnotationView ()
@property (strong, readwrite, nonatomic) CustomCalloutView *calloutView;
@property (strong, nonatomic) CalloutViewController *calloutVC;
@property (strong, nonatomic) UINavigationController *naviC;
@end

@implementation CustomAnnotationView
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (self.selected == selected) {
        NSLog(@"又点击了一次图标");
        return;
    }
    if (selected)
    {
        if (self.calloutView == nil)
        {
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,-CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        self.calloutView.customImage = [UIImage imageNamed:@"1234"];
        self.calloutView.title = self.annotation.title;
        self.calloutView.subtitle = self.annotation.subtitle;
        [self addSubview:self.calloutView];
    }else
    {
        //点击气泡进入的页面
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        window.rootViewController = self.calloutVC;
        [self.calloutView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}

- (CalloutViewController*)calloutVC{
    if (!_calloutVC) {
        _calloutVC = ({
            CalloutViewController *callVC = [[CalloutViewController alloc] init];
            callVC;
        });
    }
    return _calloutVC;
}

- (UINavigationController*)naviC{
    if (!_naviC) {
        _naviC = [[UINavigationController alloc] initWithRootViewController:self.calloutVC];
    }
    return _naviC;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
