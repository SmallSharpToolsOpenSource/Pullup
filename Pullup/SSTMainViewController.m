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

@interface SSTMainViewController () <SSTCollectionDelegate>

@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet UIView *collectionContainerView;
@property (weak, nonatomic) IBOutlet UIView *bottomNavContainerView;

@property (weak, nonatomic) IBOutlet UIView *expandedReferenceView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionBottomConstraint;

@property (weak, nonatomic) IBOutlet UIViewController *locationBarViewController;
@property (weak, nonatomic) IBOutlet SSTCollectionViewController *collectionViewController;
@property (weak, nonatomic) IBOutlet UIViewController *bottomNavViewController;

@end

@implementation SSTMainViewController {
    BOOL _isExpanded;
}

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

- (void)embedChildViewControllers {
    if (!self.locationBarViewController.view.superview) {
        [self embedViewController:self.locationBarViewController intoView:self.topContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0f];
        }];
    }
    
    if (!self.collectionViewController.view.superview) {
        [self embedViewController:self.collectionViewController intoView:self.collectionContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinTopEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge inset:0.0f];
            CGFloat height = CGRectGetHeight(self.expandedReferenceView.frame);
            [view constrainToHeight:height];
        }];
    }

    if (!self.bottomNavViewController.view.superview) {
        [self embedViewController:self.bottomNavViewController intoView:self.bottomNavContainerView placementBlock:^(UIView *view) {
            [view pinToSuperviewEdges:JRTViewPinAllEdges inset:0.0f];
        }];
    }
}

- (void)pullUpAndDown:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self pullUp:animated withCompletionBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
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
    CGPoint origin = self.topContainerView.frame.origin;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.25f options:options animations:^{
        CGRect frame = self.collectionContainerView.frame;
        frame.origin = origin;
        frame.size.height = height;
        self.collectionContainerView.frame = frame;
        
        self.locationBarViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // set the contraints to match the current frame
        self.collectionHeightConstraint.constant = height;
        self.collectionBottomConstraint.constant = 0.0f;
        
        _isExpanded = TRUE;
        
        [self.collectionViewController expandedViewDidAppear];
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)pullDown:(BOOL)animated withCompletionBlock:(void (^)())completionBlock {
    // TODO: set the height back to 100 and set the origin to the total view height minus the heights of the container and bottom nav view
    
    CGFloat duration = animated ? 0.75f : 0.0f;
    CGFloat height = 100.0f;
    CGPoint origin = CGPointMake(0.0f, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.bottomNavContainerView.frame) - 100.0f);
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    [UIView animateWithDuration:duration delay:0.0f usingSpringWithDamping:0.9f initialSpringVelocity:0.25f options:options animations:^{
        CGRect frame = self.collectionContainerView.frame;
        frame.origin = origin;
        frame.size.height = height;
        self.collectionContainerView.frame = frame;
        
        self.locationBarViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // set the contraints to match the current frame
        self.collectionHeightConstraint.constant = height;
        self.collectionBottomConstraint.constant = CGRectGetHeight(self.bottomNavContainerView.frame);
        
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
    CGRect frame = self.collectionContainerView.frame;
    
    if (_isExpanded) {
        CGFloat originalY = self.topLayoutGuide.length;
        CGFloat updatedY = originalY + point.y;
        
        frame.origin.y = updatedY;
        
        self.collectionContainerView.frame = frame;
    }
    else {

        CGFloat originalY = CGRectGetHeight(self.view.frame) - 150.0f;
        CGFloat updatedY = MAX(MIN(originalY, originalY + point.y), 0.0f);
        CGFloat viewHeight = CGRectGetHeight(self.view.frame);
        CGFloat updateHeight = viewHeight - updatedY - CGRectGetHeight(self.bottomNavContainerView.frame);
        
        frame.origin.y = updatedY;
        
        self.collectionContainerView.frame = frame;
        self.collectionHeightConstraint.constant = updateHeight;
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
