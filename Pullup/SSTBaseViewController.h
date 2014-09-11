//
//  SSTBaseViewController.h
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTBaseViewController : UIViewController

- (void)fillSubview:(UIView *)subview inSuperView:(UIView *)superview;

- (void)embedViewController:(UIViewController *)vc intoView:(UIView *)superview placementBlock:(void (^)(UIView *view))placementBlock;

- (void)removeEmbeddedViewController:(UIViewController *)vc;

@end
