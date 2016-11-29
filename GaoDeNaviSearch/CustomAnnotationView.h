//
//  CustomAnnotationView.h
//  GaoDeNaviSearch
//
//  Created by pro on 16/3/17.
//  Copyright © 2016年 JYY. All rights reserved.
//

#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAMapKit.h>
#import "CustomCalloutView.h"
@interface CustomAnnotationView : MAAnnotationView
@property (readonly, nonatomic) CustomCalloutView *calloutView;
@end
