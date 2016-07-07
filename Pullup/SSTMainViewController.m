//
//  SSTMainViewController.m
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTMainViewController.h"

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
@property (weak, nonatomic) NSLayoutConstraint *clippedBottomConstraint;

@property (weak, nonatomic) UIViewController *locationBarViewController;
@property (weak, nonatomic) SSTCollectionViewController *collectionViewController;
@property (weak, nonatomic) UIViewController *bottomNavViewController;

@end

@implementation SSTMainViewController {
    BOOL _isExpanded;
}

#pragma mark - View Lifecyle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationBarVC"];
    self.collectionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectionVC"];
    self.collectionViewController.delegate = self;
    self.bottomNavViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BottomNavVC"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self embedChildViewControllers];
}

#pragma mark - Private
#pragma mark -

- (void)embedChildViewControllers {
    if (!self.locationBarViewController.view.superview) {
        [self embedViewController:self.locationBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            [view constrainToHeight:kLocationBarHeight];
        }];
    }
    
    if (!self.collectionContainerView.superview && !self.clippedContainerView.superview) {
        UIView *collectionContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionContainerViewHeight)];
        collectionContainerView.tag = kTagCollectionContainerView;
        collectionContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionContainerView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:collectionContainerView];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:0.0f usingLayoutGuidesFrom:self];
        [collectionContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0];
        self.collectionContainerHeightConstraint = [collectionContainerView constrainToHeight:kCollectionContainerViewHeight];
        self.collectionContainerView = collectionContainerView;
        
        UIView *clippedContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kCollectionViewHeight)];
        clippedContainerView.tag = kTagClippedView;
        clippedContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        clippedContainerView.clipsToBounds = TRUE;
//        clippedContainerView.backgroundColor = [UIColor yellowColor];
        [collectionContainerView addSubview:clippedContainerView];
        [clippedContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
        [clippedContainerView pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f];
        self.clippedBottomConstraint = [clippedContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:kFooterNavigationViewHeight][0];
        self.clippedContainerView = clippedContainerView;
        
        NSAssert(self.collectionContainerHeightConstraint, @"Constraint is required");
        NSAssert(self.clippedBottomConstraint, @"Constraint is required");
    }
    
    if (!self.collectionViewController.view.superview) {
        [self embedViewController:self.collectionViewController intoView:self.clippedContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
            [view constrainToHeight:height];
        }];
    }

    if (!self.bottomNavViewController.view.superview) {
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
    CGFloat bottomNavHeight = 0.0; //CGRectGetHeight(self.bottomNavViewController.view.frame);
    CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
    
    self.expandedReferenceView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.25];
    self.expandedReferenceView.hidden = NO;
    
    DebugLog(@"height: %f", height);
    DebugLog(@"bottomNavHeight: %f", bottomNavHeight);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.25f options:options animations:^{
        self.collectionContainerHeightConstraint.constant = height;
        self.clippedBottomConstraint.constant = 0.0f;

        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
        CGRect containerFrame = self.collectionContainerView.frame;
        containerFrame.origin.y = self.topLayoutGuide.length;
        self.collectionContainerView.frame = containerFrame;
        
        CGRect clippedFrame = self.clippedContainerView.frame;
        clippedFrame.origin.y = 0.0f;
        self.clippedContainerView.frame = clippedFrame;
        
        self.locationBarViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _isExpanded = TRUE;
        
        [self.collectionViewController expandedViewDidAppear];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)pullDown:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.75f : 0.0f;
    
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
        _isExpanded = FALSE;
        
        [self.collectionViewController expandedViewDidDisappear];
        
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
    if (_isExpanded) {
        [self pullDown:TRUE withCompletionBlock:nil];
    }
    else {
        [self pullUp:TRUE withCompletionBlock:nil];
    }
}

- (void)collectionViewCoordinatorShouldCollapse:(SSTCollectionViewCoordinator *)vc {
    if (_isExpanded) {
        [self pullDown:TRUE withCompletionBlock:nil];
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
    if (_isExpanded) {
        if (point.y < 100.0f) {
            [self pullUp:TRUE withCompletionBlock:nil];
        }
        else {
            [self pullDown:TRUE withCompletionBlock:nil];
        }
    }
    else {
        if (point.y < (CGRectGetHeight(self.expandedReferenceView.frame) * 0.75f)) {
            [self pullUp:TRUE withCompletionBlock:nil];
        }
        else {
            [self pullDown:TRUE withCompletionBlock:nil];
        }
    }
}

@end
