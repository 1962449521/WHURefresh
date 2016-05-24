//
//  WHURefreshViewDelegate.h
//  TestRefreshView
//
//  Created by Mitty on 16/5/5.
//  Copyright (c) 2016年 WHU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WHURefreshViewStatus) {
    WHURefreshViewStatusIdle = 1,
    WHURefreshViewStatusPulling,
    WHURefreshViewStatusRefreshing,
};

@class WHURefreshView;
@class WHURefreshItemSubClass;

@protocol WHURefreshViewDelegate <NSObject>

/**
 *  使用WHURefreshView的代理方的UI或逻辑执行时机
 *
 *  1.填入自定义(继承WHURefreshItem)或【本组件】提供的WHURefreshItem子类  
 *  2.触发刷新时接入通讯逻辑
 *
 *  注意：通讯结束后，可调用[WHURefreshView endRefreshing]手动触发复位，此时该方法依然会被调用
 *
 *  @param refreshView 本组件的核心控件，包裹刷新图的容器
 *  @param refreshItem 自定义(继承WHURefreshItem)或【本组件】提供的WHURefreshItem子类
 *  @param newStatus   状态变化时的新状态
 */
- (void) refreshView:(WHURefreshView * _Nonnull) refreshView currentItem:(WHURefreshItemSubClass * _Nullable) refreshItem didChangeStatus:(WHURefreshViewStatus) newStatus ;

@end
