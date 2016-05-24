//
//  ViewController2.m
//  WHURefreshHelper
//
//  Created by Mitty on 16/5/24.
//  Copyright © 2016年 Mitty. All rights reserved.
//

#import "ViewController2.h"
#import "WHURefreshView.h"

#import "WHURefreshClassicItem.h"

@interface ViewController2 ()<WHURefreshViewDelegate>

@end

@implementation ViewController2


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    WHURefreshView *refreshView = [WHURefreshView initAndAppendToScrollView:self.tableView delegate:self];
    refreshView.backgroundColor = [UIColor yellowColor];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"cell - %@", @(indexPath.row)];
    
    return cell;
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
            // finished fetching data
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [refreshView endRefreshing];
            });
        });
        
    }
    
}



@end
