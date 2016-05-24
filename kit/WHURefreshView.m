//
//  WHURefreshView.m
//  TestRefreshView
//
//  Created by Mitty on 16/5/4.
//  Copyright (c) 2016年 WHU. All rights reserved.
//

#import "WHURefreshView.h"
#import <objc/runtime.h>
#import "FBKVOController.h"

static const char * WHUScrollViewExistedRefreshView;

@interface WHURefreshView()

@property (nonatomic, strong) NSLayoutConstraint *cstHeight;
@property (nonatomic, assign) CGFloat scrollViewInsetTop;
@property (nonatomic, assign) BOOL forceEndRefreshing;
@property (nonatomic, strong) FBKVOController *kvoController;

@end

@implementation WHURefreshView

// 构造方法
+ (WHURefreshView * _Nullable) initAndAppendToScrollView:(UIScrollView * _Nonnull) scrollView delegate:(id<WHURefreshViewDelegate> _Nullable) delegate {
    
    UIView *superview = scrollView.superview;
    if (!superview) return nil;
    WHURefreshView *existedRefreshView = objc_getAssociatedObject(scrollView, WHUScrollViewExistedRefreshView);
    if (existedRefreshView) {
        [existedRefreshView removeFromSuperview];
        objc_setAssociatedObject(scrollView, WHUScrollViewExistedRefreshView, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    WHURefreshView *refreshView = [[self alloc] init];

    refreshView.clipsToBounds = YES;
    refreshView.scrollView = scrollView;
    refreshView.delegate = delegate;
    refreshView.scrollViewInsetTop = scrollView.contentInset.top;
    refreshView.translatesAutoresizingMaskIntoConstraints = false;
    [superview addSubview:refreshView];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:refreshView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:refreshView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:refreshView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];

    refreshView.cstHeight = [[NSLayoutConstraint constraintsWithVisualFormat:@"V:[refreshView(==0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(refreshView)] firstObject];
    
    [superview addConstraints:@[left, right, bottom, refreshView.cstHeight]];
    
    objc_setAssociatedObject(scrollView, WHUScrollViewExistedRefreshView, refreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // 自动工作类型，根据是否在交互中、下拉的幅度等，更改自身状态
    
    refreshView.kvoController = [FBKVOController controllerWithObserver:self];
    __weak typeof(refreshView) weakSelf = refreshView;
    
    [refreshView.kvoController observe:scrollView
                        keyPath:@"contentOffset"
                        options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              CGFloat oldHeight = - weakSelf.scrollViewInsetTop - [change[NSKeyValueChangeOldKey] CGPointValue].y;
                              CGFloat willHeight = - weakSelf.scrollViewInsetTop - [change[NSKeyValueChangeNewKey] CGPointValue].y;
                              
                              weakSelf.cstHeight.constant = willHeight > 0? willHeight : 0; // 容器贴紧在scrollview上沿与scrollview.contentView上沿之间
                              
                              CGFloat maxHeight = refreshView.heightWhileRefreshing;
                              if (maxHeight <= 0) maxHeight = kWHURefreshView_MaxHeight_Default;
                              
                              if (weakSelf.scrollView.isDragging) { // 1. 交互中
                                  if (weakSelf.status == WHURefreshViewStatusRefreshing) { // 更新中， 不做处理
                                      return;
                                  }
                                  if (willHeight > oldHeight) {           // 1.1 下拉
                                      if (willHeight >= maxHeight && weakSelf.status == WHURefreshViewStatusIdle) {
                                          weakSelf.status = WHURefreshViewStatusPulling;
                                      }
                                  } else if (willHeight < oldHeight){     // 1.2 回放
                                      if (willHeight <= maxHeight && weakSelf.status == WHURefreshViewStatusPulling) {
                                          weakSelf.status  = WHURefreshViewStatusIdle;
                                      }
                                  }
                              } else {                           // 2.交互结束
                                  if (willHeight < oldHeight) {           // 2.2 系统弹回
                                      if (willHeight >= maxHeight && weakSelf.status == WHURefreshViewStatusPulling) {
                                          weakSelf.status = WHURefreshViewStatusRefreshing;
                                      }
                                  }
                              }
                          }];
    
    refreshView.status = WHURefreshViewStatusIdle;
    return refreshView;
}

// 切换工作状态， 当切换至idle时，有动画切换和直接切换两种
- (void) setStatus:(WHURefreshViewStatus)status {
    WHURefreshViewStatus oldStatus = _status;
    _status = status;
    
    if (status != oldStatus) {
        void (^tellDelegate2ChangeUI)() = ^{
            if ([self.delegate respondsToSelector:@selector(refreshView:currentItem:didChangeStatus:)]) {
                [self.delegate refreshView:self currentItem:self.refreshItem didChangeStatus:status];
            }
        };
        
        CGFloat maxHeight = self.heightWhileRefreshing;
        if (maxHeight <= 0) maxHeight = kWHURefreshView_MaxHeight_Default;
        
        switch (status) {
            case WHURefreshViewStatusIdle:
                if (self.forceEndRefreshing) {
                    self.forceEndRefreshing = NO;
                    UIEdgeInsets insets = self.scrollView.contentInset;
                    insets.top -= maxHeight;
                    
                    NSTimeInterval duration = self.resumeDuration;
                    if (duration <= 0) {
                        duration = kWHURefreshView_AnimateDuration_FromRefreshingToIdle_Default;
                    }
                    
                    [UIView animateWithDuration:duration animations:^{
                        [self.scrollView setContentInset:insets];
                        self.cstHeight.constant = 0;
                        [self setNeedsLayout];
                        [self layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        _status = WHURefreshViewStatusIdle;
                        tellDelegate2ChangeUI();
                    }];
                } else {
                    tellDelegate2ChangeUI();
                }
                break;
                
            case WHURefreshViewStatusPulling:
                tellDelegate2ChangeUI();
                break;
                
            case WHURefreshViewStatusRefreshing: {
                UIEdgeInsets insets = self.scrollView.contentInset;
                insets.top += maxHeight;
                [self.scrollView setContentInset:insets];
                tellDelegate2ChangeUI();
            }
                break;
        }
    }
}

// 手动工作类型，开启刷新
- (void) beginRefreshing {
    [self setStatus:WHURefreshViewStatusIdle];
    
    CGFloat maxHeight = self.heightWhileRefreshing;
    if (maxHeight <= 0) maxHeight = kWHURefreshView_MaxHeight_Default;
    
    NSTimeInterval duration = self.resumeDuration;
    if (duration <= 0) {
        duration = kWHURefreshView_AnimateDuration_FromRefreshingToIdle_Default;
    }
    
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = self.scrollViewInsetTop + maxHeight;
    [UIView animateWithDuration:duration animations:^{
        [self.scrollView setContentInset:insets];
        self.cstHeight.constant = maxHeight;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setStatus:WHURefreshViewStatusRefreshing];
    }];
}

// 手动工作类型，结束刷新
- (void) endRefreshing {
    self.forceEndRefreshing = YES;
    [self setStatus:WHURefreshViewStatusIdle];
}

@end
