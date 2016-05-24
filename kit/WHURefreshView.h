//
//  WHURefreshView.h
//  TestRefreshView
//
//  Created by Mitty on 16/5/4.
//  Copyright (c) 2016年 WHU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHURefreshViewDelegate.h"
#import "WHURefreshItemSubClass.h"

#define kWHURefreshView_MaxHeight_Default      44 // 刷新时的refresh view 固定高度
#define kWHURefreshView_AnimateDuration_FromRefreshingToIdle_Default      0.2 // 刷新完由刷新到空闲的动画时间

@interface WHURefreshView : UIView

@property (nonatomic, assign) WHURefreshViewStatus status;
@property (nonatomic, weak)   UIScrollView  * _Nullable scrollView;
@property (nonatomic, weak)   WHURefreshItemSubClass * _Nullable refreshItem;
@property (nonatomic, weak)   id<WHURefreshViewDelegate> _Nullable  delegate;

@property (nonatomic, assign) CGFloat heightWhileRefreshing; // default kWHURefreshView_MaxHeight_Default
@property (nonatomic, assign) NSTimeInterval resumeDuration; // default kWHURefreshView_AnimateDuration_FromRefreshingToIdle_Default

// 实例构造方法
+ (WHURefreshView * _Nullable) initAndAppendToScrollView:(UIScrollView * _Nonnull) scrollView delegate:(id<WHURefreshViewDelegate> _Nullable) delegate;

// 手动工作类型，开启刷新
- (void) beginRefreshing;

// 手动工作类型，结束刷新
- (void) endRefreshing;

@end
