//
//  SSTCollectionViewController.m
//  Pullup
//
//  Created by Brennan Stehling on 9/9/14.
//  Copyright (c) 2014 SmallSharpTools. All rights reserved.
//

#import "SSTCollectionViewController.h"

#define kTagHeaderView 1
#define kTagHeaderLabel 2
#define kTagTableView 3

#define kNumberOfItems 10

@interface SSTCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (readonly, nonatomic) UIView *primaryView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation SSTCollectionViewController {
    CGPoint _panGestureStartingPoint;
}

#pragma mark - View Lifecycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.collectionView, @"Outlet is required");
    NSAssert(self.collectionView.dataSource == self, @"DataSource must be self");
    NSAssert(self.collectionView.delegate = self, @"Delegate must be self");
}

#pragma mark - Public
#pragma mark -

- (void)expandedViewDidAppear {
    if (self.collectionView.visibleCells.count) {
        UICollectionViewCell *cell = self.collectionView.visibleCells[0];
        UITableView *tableView = (UITableView *)[cell viewWithTag:kTagTableView];
        [tableView flashScrollIndicators];
    }
}

- (void)expandedViewDidDisappear {
    // do nothing
}

#pragma mark - Private
#pragma mark -

- (void)panningDidMoveToPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(collectionViewController:didMoveToPoint:)]) {
        [self.delegate collectionViewController:self didMoveToPoint:point];
    }
}

- (void)panningDidStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity {
    if ([self.delegate respondsToSelector:@selector(collectionViewController:didStopMovingAtPoint:withVelocity:)]) {
        [self.delegate collectionViewController:self didStopMovingAtPoint:point withVelocity:velocity];
    }
}

- (UIView *)primaryView {
    if ([self.delegate respondsToSelector:@selector(collectionViewControllerPrimaryView:)]) {
        return [self.delegate collectionViewControllerPrimaryView:self];
    }
    
    return nil;
}

#pragma mark - Gestures
#pragma mark -

- (IBAction)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.primaryView];
    CGFloat adjustedY = point.y - _panGestureStartingPoint.y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
                [self panningDidMoveToPoint:CGPointMake(0.0f, adjustedY)];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
                CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
                [self panningDidStopMovingAtPoint:CGPointMake(0.0f, adjustedY) withVelocity:velocity];
            }
            
            break;
            
        default:
            NSAssert(FALSE, @"Condition should never occur.");
            break;
    }
}

#pragma mark - User Actions
#pragma mark -

- (IBAction)detailDisclosureButtonTapped:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"You tapped the detail disclosure button."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kNumberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PullupCell" forIndexPath:indexPath];
    
    if (self.panGestureRecognizer == nil) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        self.panGestureRecognizer = panGestureRecognizer;
    }
    
    UIView *headerView = [cell viewWithTag:kTagHeaderView];
    headerView.gestureRecognizers = @[self.panGestureRecognizer];
    
    UILabel *headerLabel = (UILabel *)[cell viewWithTag:kTagHeaderLabel];
    headerLabel.text = [NSString stringWithFormat:@"Item %lu", (unsigned long)(indexPath.item+1)];
    
    UITableView *tableView = (UITableView *)[cell viewWithTag:kTagTableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.contentOffset = CGPointMake(0.0f, 0.0f);
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0.0f, 0.0f, 50.0f, 0.0f);
    tableView.contentInset = inset;
    tableView.scrollIndicatorInsets = inset;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return TRUE;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(collectionViewControllerDidTapHeader:)]) {
        [self.delegate collectionViewControllerDidTapHeader:self];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [collectionView deselectItemAtIndexPath:indexPath animated:TRUE];
    });
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BasicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Table View Row %lu", (unsigned long)(indexPath.row+1)];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

#pragma mark - UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    });
}

#pragma mark - UIGestureRecognizerDelegate
#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // ensure the pan gesture does not handle horizontal movement so sliders do not
    // interfere with paging the collection view
    
    BOOL should = YES;
    
    if ([gestureRecognizer isEqual:self.panGestureRecognizer]) {
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
        // Check for vertical gesture
        
        should = fabs(translation.y) > fabs(translation.x);
        
        if (should) {
            CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
            _panGestureStartingPoint = point;
        }
    }
    
    return should;
}

#pragma mark - UIScrollViewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // if value is < -50 then trigger view to collapse view
    if (scrollView.contentOffset.y < -50.0f) {
        if ([self.delegate respondsToSelector:@selector(collectionViewControllerShouldCollapse:)]) {
            [self.delegate collectionViewControllerShouldCollapse:self];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // if the velocity is "slow" it should just go the next cell, otherwise let it go to the next paged position
    // positive x is moving right, negative x is moving left
    // slow is < 0.75
    
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    NSUInteger currentIndex = MAX(MIN(round(self.collectionView.contentOffset.x / CGRectGetWidth(self.collectionView.frame)), kNumberOfItems - 1), 0);
    
    if (fabs(velocity.x) > 2.0) {
        CGFloat x = targetContentOffset->x;
        x = round(x / width) * width;
        targetContentOffset->x = x;
    }
    else {
        NSUInteger targetIndex = velocity.x > 0.0 ? MIN(currentIndex + 1, kNumberOfItems - 1) : MAX(currentIndex - 1, 0);
        targetContentOffset->x = targetIndex * width;
    }
}

@end
