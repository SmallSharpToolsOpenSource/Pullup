//
//  SSTMainViewController.m
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTMainViewController.h"

#import "SSTLocationBarViewController.h"
#import "SSTBottomNavigationViewController.h"
#import "SSTCollectionViewController.h"
#import "SSTCollectionViewCoordinator.h"
#import "UIView+AutoLayout.h"
#import "Macros.h"

#define kTagCollectionContainerView 100
#define kTagClippedView 200

#define kLocationBarHeight 40.0f
#define kCollectionContainerViewHeight 150.0f
#define kCollectionViewHeight 100.0f
#define kFooterNavigationViewHeight 50.0f

@interface SSTMainViewController () <SSTCollectionViewCoordinatorDelegate>

@property (weak, nonatomic) IBOutlet UIView *expandedReferenceView;

@property (weak, nonatomic) UIView *collectionContainerView;
@property (weak, nonatomic) UIView *clippedContainerView;

@property (weak, nonatomic) NSLayoutConstraint *collectionContainerHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *collectionHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *clippedBottomConstraint;

// Properties as strong because they are not immediately added to the view hierarchy.
@property (strong, nonatomic) SSTLocationBarViewController *locationBarViewController;
@property (strong, nonatomic) SSTCollectionViewController *collectionViewController;
@property (strong, nonatomic) SSTBottomNavigationViewController *bottomNavViewController;

@property (assign, nonatomic) BOOL isExpanded;

@end

@implementation SSTMainViewController

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationBarVC"];
    self.collectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionVC"];
    self.collectionViewController.delegate = self;
    self.bottomNavViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BottomNavVC"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Embedding must be done after the layout is ready so that cells are the proper size.
    [self embedChildViewControllers];
}

#pragma mark - Private
#pragma mark -

- (void)embedChildViewControllers {
    if (!self.locationBarViewController.view.superview) {
        // The location bar is pinned to the sides and bottom with a fixed height.
        [self embedViewController:self.locationBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            [view constrainToHeight:kLocationBarHeight];
        }];
    }
    
    if (!self.collectionContainerView.superview && !self.clippedContainerView.superview) {
        // The collection view is placed in a container view whcih is pinned to the sides and bottom with a fixed height.
        UIView *collectionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionContainerViewHeight)];
        collectionContainerView.tag = kTagCollectionContainerView;
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionContainerView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:collectionContainerView];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        self.collectionContainerHeightConstraint = [collectionContainerView constrainToHeight:kCollectionContainerViewHeight];
        self.collectionContainerView = collectionContainerView;

        // A clipped container view prevents from sub views from showing below the bottom navigation view.
        UIView *clippedContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionViewHeight)];
        clippedContainerView.tag = kTagClippedView;
        clippedContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        clippedContainerView.clipsToBounds = YES;
        [collectionContainerView addSubview:clippedContainerView];
        [clippedContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
        [clippedContainerView pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f];
        self.clippedBottomConstraint = [clippedContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:kFooterNavigationViewHeight][0];
        self.clippedContainerView = clippedContainerView;
        
        NSAssert(self.collectionContainerHeightConstraint, @"Constraint is required");
        NSAssert(self.clippedBottomConstraint, @"Constraint is required");
    }
    
    if (!self.collectionViewController.view.superview) {
        // The collection view is pinned to the sides and top of the clipped view iwth the height of the reference view.
        [self embedViewController:self.collectionViewController intoView:self.clippedContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
            self.collectionHeightConstraint = [view constrainToHeight:height];
        }];
    }

    if (!self.bottomNavViewController.view.superview) {
        // The bottom navigation view is pinned to the sides and bottom with a fixed height.
        [self embedViewController:self.bottomNavViewController intoView:self.collectionContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinBottomEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            [view constrainToHeight:kFooterNavigationViewHeight];
        }];
    }
}

- (void)pullUpAndDown:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self pullUp:animated withCompletionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self pullDown:animated withCompletionBlock:^{
                    [self pullUpAndDown:animated];
                }];
            });
        }];
    });
}

- (void)pullUp:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.75f : 0.0f;
    CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
    
    [self.collectionViewController willExpand];

    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.25f options:options animations:^{
        // expand the height of the collection container
        self.collectionContainerHeightConstraint.constant = height;
        self.collectionHeightConstraint.constant = height;
        // move clipped view down to the bottom
        self.clippedBottomConstraint.constant = 0.0f;

        // apply contraint changes in animation block
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];

        self.locationBarViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.isExpanded = YES;

        [self.collectionViewController didExpand];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)pullDown:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.75f : 0.0f;

    [self.collectionViewController willCollapse];
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:0.25f options:options animations:^{
        self.collectionContainerHeightConstraint.constant = kCollectionContainerViewHeight;
        self.clippedBottomConstraint.constant = kFooterNavigationViewHeight;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        CGRect clippedFrame = self.clippedContainerView.frame;
        clippedFrame.size.height = kCollectionViewHeight;
        self.clippedContainerView.frame = clippedFrame;
        
        self.locationBarViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.isExpanded = NO;

        [self.collectionViewController didCollapse];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - SSTCollectionViewCoordinatorDelegate
#pragma mark -

- (UIView *)collectionViewCoordinatorPrimaryView:(SSTCollectionViewCoordinator *)vc {
    return self.expandedReferenceView;
}

- (void)collectionViewCoordinatorDidTapHeader:(SSTCollectionViewCoordinator *)vc {
    if (self.isExpanded) {
        [self pullDown:YES withCompletionBlock:nil];
    }
    else {
        [self pullUp:YES withCompletionBlock:nil];
    }
}

- (void)collectionViewCoordinatorShouldCollapse:(SSTCollectionViewCoordinator *)vc {
    if (self.isExpanded) {
        [self pullDown:YES withCompletionBlock:nil];
    }
}

- (void)collectionViewCoordinator:(SSTCollectionViewCoordinator *)vc didMoveToPoint:(CGPoint)point {
    CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame) - point.y;
    
    CGRect containerFrame = self.collectionContainerView.frame;
    containerFrame.origin.y = point.y;
    containerFrame.size.height = height;
    self.collectionContainerView.frame = containerFrame;
    
    CGRect clippedFrame = self.clippedContainerView.frame;
    clippedFrame.origin.y = 0.0f;
    clippedFrame.size.height = height - kFooterNavigationViewHeight;
    self.clippedContainerView.frame = clippedFrame;
    
    self.collectionContainerHeightConstraint.constant = height;
    self.clippedBottomConstraint.constant = kFooterNavigationViewHeight;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)collectionViewCoordinator:(SSTCollectionViewCoordinator *)vc didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity {
    if (self.isExpanded) {
        if (point.y < 100.0f) {
            [self pullUp:YES withCompletionBlock:nil];
        }
        else {
            [self pullDown:YES withCompletionBlock:nil];
        }
    }
    else {
        if (point.y < (CGRectGetHeight(self.expandedReferenceView.frame) * 0.75f)) {
            [self pullUp:YES withCompletionBlock:nil];
        }
        else {
            [self pullDown:YES withCompletionBlock:nil];
        }
    }
}

@end
