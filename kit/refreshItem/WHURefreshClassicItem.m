//
//  WHURefreshClassicItem.m
//  TestRefreshView
//
//  Created by Mitty on 16/5/5.
//  Copyright (c) 2016年 WHU. All rights reserved.
//

#import "WHURefreshClassicItem.h"
#import "WHURefreshView.h"

#define kWHURefreshViewIdleText @"下拉可以刷新"
#define kWHURefreshViewPullingext @"松开立即刷新"
#define kWHURefreshViewRefreshingText @"正在刷新数据中..."
#define kWHUImagePath @"WHURefreshArrow"


#define WHUResourceName(name) name


@interface WHURefreshClassicItem()

@property (weak, nonatomic) IBOutlet UIImageView *imgViewArrow;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;

@end

@implementation WHURefreshClassicItem

#pragma mark - instantiation

+ (instancetype) refreshItem {
    WHURefreshClassicItem *item = [[[NSBundle mainBundle] loadNibNamed: WHUResourceName(NSStringFromClass([self class])) owner:self options:nil] firstObject];
    return item;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self p_customInitUI];
}

- (void) p_customInitUI {
    UIImage *image = [UIImage imageNamed:kWHUImagePath];
    self.imgViewArrow.image = image;
    [self.activityIndicator startAnimating];
    [self displayAccording2State:WHURefreshViewStatusIdle];
}

#pragma mark - methods

// 将刷新外观图添加至刷新组件容器
- (void) appendToRefreshView:(WHURefreshView *) refreshView {
    [refreshView addSubview:self];
    refreshView.refreshItem = self;
    self.translatesAutoresizingMaskIntoConstraints = false;
    // align self from the left and right
    [refreshView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[self]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    
    // align self from the bottom
    [refreshView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    
    // height constraint
    CGFloat height = refreshView.heightWhileRefreshing;
    if (height <= 0) {
        height = kWHURefreshView_MaxHeight_Default;
    }
    NSString *heightFormat = [NSString stringWithFormat: @"V:[self(==%@)]", @(height)];
    [refreshView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightFormat options:0 metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}

// 对应刷新组件状态的UI外观调整
- (void) displayAccordingToStatus:(WHURefreshViewStatus) status {
    switch (status) {
        case WHURefreshViewStatusIdle:
            self.labelInfo.text = kWHURefreshViewIdleText;
            self.activityIndicator.hidden = YES;
            self.imgViewArrow.hidden = NO;
            self.imgViewArrow.transform = CGAffineTransformIdentity;
            break;
            
        case WHURefreshViewStatusPulling:
            self.labelInfo.text = kWHURefreshViewPullingext;
            self.activityIndicator.hidden = YES;
            self.imgViewArrow.hidden = NO;
            self.imgViewArrow.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case WHURefreshViewStatusRefreshing:
            self.labelInfo.text = kWHURefreshViewRefreshingText;
            self.activityIndicator.hidden = NO;
            self.imgViewArrow.hidden = YES;
            break;
    }
}


@end
