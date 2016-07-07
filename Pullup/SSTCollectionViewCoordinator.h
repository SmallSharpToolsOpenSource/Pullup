//
//  SSTCollectionViewCoordinator.h
//  Pullup
//
//  Created by Brennan Stehling on 7/6/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSTCollectionViewCoordinatorDelegate;

@interface SSTCollectionViewCoordinator : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<SSTCollectionViewCoordinatorDelegate> delegate;

- (void)flashScrollIndicators;

- (NSIndexPath *)indexPathForView:(UIView *)view;

@end

@protocol SSTCollectionViewCoordinatorDelegate <NSObject>

@required

- (UIView *)collectionViewCoordinatorPrimaryView:(SSTCollectionViewCoordinator *)coordinator;

@optional

- (void)collectionViewCoordinatorDidTapHeader:(SSTCollectionViewCoordinator *)coordinator;

- (void)collectionViewCoordinatorShouldCollapse:(SSTCollectionViewCoordinator *)coordinator;

- (void)collectionViewCoordinator:(SSTCollectionViewCoordinator *)coordinator didMoveToPoint:(CGPoint)point;

- (void)collectionViewCoordinator:(SSTCollectionViewCoordinator *)coordinator didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity;

@end
