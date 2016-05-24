//
//  ViewController.m
//  WHURefreshHelper
//
//  Created by Mitty on 16/5/24.
//  Copyright © 2016年 Mitty. All rights reserved.
//

#import "ViewController.h"

#import "WHURefreshView.h"
#import "WHURefreshClassicItem.h"

@interface ViewController ()<WHURefreshViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    WHURefreshView *refreshView = [WHURefreshView initAndAppendToScrollView:self.scrollView delegate:self];
    refreshView.backgroundColor = [UIColor blueColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WHURefreshViewDelegate

- (void) refreshView:(WHURefreshView * _Nonnull) refreshView currentItem:(WHURefreshItemSubClass * _Nullable) refreshItem didChangeStatus:(WHURefreshViewStatus) newStatus  {
    
    if (refreshItem == nil) {
        [[WHURefreshClassicItem refreshItem] appendToRefreshView:refreshView];
    }
    WHURefreshClassicItem *myRefreshItem = (WHURefreshClassicItem *)refreshItem;
    [myRefreshItem displayAccordingToStatus:newStatus];
    
    if (newStatus == WHURefreshViewStatusRefreshing) {
        // start to fetch data from network
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:10];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [refreshView endRefreshing];
            });
        });
        
    }
    
}

@end
