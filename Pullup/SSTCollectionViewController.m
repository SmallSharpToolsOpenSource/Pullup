//
//  SSTCollectionViewController.m
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTCollectionViewController.h"

#import "SSTCollectionViewCoordinator.h"
#import "Macros.h"

@interface SSTCollectionViewController ()

@property (strong, nonatomic) IBOutlet SSTCollectionViewCoordinator *coordinator;

@end

@implementation SSTCollectionViewController

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];

    DebugLog(@"View Did Load: %@", NSStringFromClass(self.class));
}

#pragma mark - Delegate
#pragma mark -

- (id<SSTCollectionViewCoordinatorDelegate>)delegate {
    return self.coordinator.delegate;
}

- (void)setDelegate:(id<SSTCollectionViewCoordinatorDelegate>)delegate {
    self.coordinator.delegate = delegate;
}

#pragma mark - Public
#pragma mark -

- (void)willExpand {
    // do nothing
}

- (void)didExpand {
    [self.coordinator flashScrollIndicators];
}

- (void)willCollapse {
    // do nothing
}

- (void)didCollapse {
    // do nothing
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)detailDisclosureButtonTapped:(UIButton *)sender {
    DebugLog(@"sender: %@", sender);

    NSString *title = @"Info";
    NSString *message = @"You tapped the detail disclosure button.";

    NSIndexPath *indexPath = [self.coordinator indexPathForView:sender];
    NSAssert(indexPath, @"Value is required");
    if (indexPath) {
        DebugLog(@"Item %ld", (long)indexPath.item + 1);
        message = [NSString stringWithFormat:@"You tapped the detail disclosure button for Item %li.", (long)(indexPath.item + 1)];
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        DebugLog(@"OK");
    }]];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

@end
