//
//  WHURefreshClassicItem.h
//  TestRefreshView
//
//  Created by Mitty on 16/5/5.
//  Copyright (c) 2016年 WHU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHURefreshItemSubClass.h"

@interface WHURefreshClassicItem : WHURefreshItemSubClass

+ (instancetype) refreshItem;

// 将刷新外观图添加至刷新组件容器
- (void) appendToRefreshView:(WHURefreshView *) refreshView;

// 对应刷新组件状态的UI外观调整
- (void) displayAccordingToStatus:(WHURefreshViewStatus) status;

@end
