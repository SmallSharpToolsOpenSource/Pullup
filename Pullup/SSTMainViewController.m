//
//  SSTMainViewController.m
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTMainViewController.h"

#import "SSTCollectionViewController.h"

#import "UIView+AutoLayout.h"

// Make sure NDEBUG is defined on Release
#ifndef NDEBUG

#define DebugLog(message, ...) NSLog(@"%s: " message, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#else

#define DebugLog(message, ...)

#endif

#define kTagCollectionContainerView 100
#define kTagClippedView 200

#define kCollectionContainerViewHeight 150.0f
#define kCollectionViewHeight 100.0f
#define kBottomNavigationViewHeight 50.0f

@interface SSTMainViewController () <SSTCollectionDelegate>

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
    CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
    [self.collectionViewController setCellHeight:height];
    self.bottomNavViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BottomNavVC"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self embedChildViewControllers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self pullUpAndDown:TRUE];
}

#pragma mark - Private
#pragma mark -

- (void)embedChildViewControllers {
    if (!self.locationBarViewController.view.superview) {
        [self embedViewController:self.locationBarViewController intoView:self.view placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f usingLayoutGuidesFrom:self];
            [view pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            [view constrainToHeight:40.0f];
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
        clippedContainerView.backgroundColor = [UIColor clearColor];
        [collectionContainerView addSubview:clippedContainerView];
        [clippedContainerView pinToSuperviewEdges:JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
        [clippedContainerView pinToSuperviewEdges:JRTViewPinTopEdge inset:0.0f];
        self.clippedBottomConstraint = [clippedContainerView pinToSuperviewEdges:JRTViewPinBottomEdge inset:kBottomNavigationViewHeight][0];
        self.clippedContainerView = clippedContainerView;
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
            [view constrainToHeight:kBottomNavigationViewHeight];
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
    
//    CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
}

- (void)pullUp:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    CGFloat duration = animated ? 0.75f : 0.0f;
    CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.25f options:options animations:^{
        self.collectionContainerHeightConstraint.constant = height;
        self.clippedBottomConstraint.constant = 0.0f;

        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
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
        self.clippedBottomConstraint.constant = kBottomNavigationViewHeight;
        
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

#pragma mark - SSTCollectionDelegate
#pragma mark -

- (UIView *)collectionViewControllerPrimaryView:(SSTCollectionViewController *)vc {
    return self.view;
}

- (void)collectionViewControllerDidTapHeader:(SSTCollectionViewController *)vc {
    if (_isExpanded) {
        [self pullDown:TRUE withCompletionBlock:nil];
    }
    else {
        [self pullUp:TRUE withCompletionBlock:nil];
    }
}

- (void)collectionViewControllerShouldCollapse:(SSTCollectionViewController *)vc {
    if (_isExpanded) {
        [self pullDown:TRUE withCompletionBlock:nil];
    }
}

- (void)collectionViewController:(SSTCollectionViewController *)vc didMoveToPoint:(CGPoint)point {
    CGRect frame = self.clippedContainerView.frame;
    
    if (_isExpanded) {
        CGFloat originalY = self.topLayoutGuide.length;
        CGFloat updatedY = originalY + point.y;
        
        frame.origin.y = updatedY;
        
        self.clippedContainerView.frame = frame;
    }
    else {
        CGFloat originalY = CGRectGetHeight(self.view.frame) - 150.0f;
        CGFloat updatedY = MAX(MIN(originalY, originalY + point.y), 0.0f);
        CGFloat viewHeight = CGRectGetHeight(self.view.frame);
        CGFloat updateHeight = viewHeight - updatedY - kBottomNavigationViewHeight;
        
        frame.origin.y = updatedY;
        
        self.clippedContainerView.frame = frame;
        self.collectionContainerHeightConstraint.constant = updateHeight;
    }
}

- (void)collectionViewController:(SSTCollectionViewController *)vc didStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity {
    if (_isExpanded) {
        CGFloat originalY = self.topLayoutGuide.length;
        CGFloat updatedY = originalY + point.y;
        
        if (updatedY < originalY + 100.0f) {
            [self pullUp:TRUE withCompletionBlock:nil];
        }
        else {
            [self pullDown:TRUE withCompletionBlock:nil];
        }
    }
    else {
        CGFloat originalY = CGRectGetHeight(self.view.frame) - 150.0f;
        CGFloat updatedY = MAX(MIN(originalY, originalY + point.y), 0.0f);
        
        if (updatedY < originalY - 100.0f) {
            [self pullUp:TRUE withCompletionBlock:nil];
        }
        else {
            [self pullDown:TRUE withCompletionBlock:nil];
        }
    }
}

@end
