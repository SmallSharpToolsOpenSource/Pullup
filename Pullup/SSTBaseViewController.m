//
//  SSTBaseViewController.m
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTBaseViewController.h"

@interface SSTBaseViewController ()

@end

@implementation SSTBaseViewController

#pragma mark - Embedding View Controllers

- (void)fillSubview:(UIView *)subview inSuperView:(UIView *)superview {
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:views]];
}

- (void)embedViewController:(UIViewController *)vc intoView:(UIView *)superview placementBlock:(void (^)(UIView *view))placementBlock {
    NSAssert(vc, @"VC must be define");
    NSAssert(superview, @"Superview must be defined");
    
    vc.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:vc];
    [superview addSubview:vc.view];
    
    if (placementBlock) {
        placementBlock(vc.view);
    }
    else {
        [self fillSubview:vc.view inSuperView:superview];
    }
    
    [vc didMoveToParentViewController:self];
}

- (void)removeEmbeddedViewController:(UIViewController *)vc {
    if (vc) {
        [vc willMoveToParentViewController:self];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
}

@end
