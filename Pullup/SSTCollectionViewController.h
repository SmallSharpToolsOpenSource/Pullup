//
//  SSTCollectionViewController.h
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTBaseViewController.h"

#import "SSTCollectionViewCoordinator.h"

@interface SSTCollectionViewController : SSTBaseViewController

@property (weak, nonatomic) id<SSTCollectionViewCoordinatorDelegate> delegate;

- (void)expandedViewDidAppear;

- (void)expandedViewDidDisappear;

@end