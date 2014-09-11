//
//  SSTCollectionViewController.h
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTBaseViewController.h"

@protocol SSTCollectionDelegate;

@interface SSTCollectionViewController : SSTBaseViewController

@property (weak, nonatomic) id<SSTCollectionDelegate> delegate;

- (void)setCellHeight:(CGFloat)cellHeight;

- (void)expandedViewDidAppear;

- (void)expandedViewDidDisappear;

@end

@protocol SSTCollectionDelegate <NSObject>

@required

- (UIView *)collectionViewControllerPrimaryView:(SSTCollectionViewController *)vc;

@optional

- (void)collectionViewControllerDidTapHeader:(SSTCollectionViewController *)vc;

- (void)collectionViewControllerShouldCollapse:(SSTCollectionViewController *)vc;

- (void)collectionViewController:(SSTCollectionViewController *)vc didMoveToPoint:(CGPoint)point;

- (void)collectionViewController:(SSTCollectionViewController *)vc didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity;

@end
