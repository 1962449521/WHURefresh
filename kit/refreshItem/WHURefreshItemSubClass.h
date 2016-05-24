//
//  WHURefreshItem.h
//  TestRefreshView
//
//  Created by Mitty on 16/5/5.
//  Copyright (c) 2016年 WHU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHURefreshViewDelegate.h"

@interface WHURefreshItemSubClass : UIView

// 对应刷新组件状态的UI外观调整
- (void) displayAccording2State:(WHURefreshViewStatus)status;

@end
