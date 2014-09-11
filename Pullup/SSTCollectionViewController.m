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

@interface SSTCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (readonly, nonatomic) UIView *primaryView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation SSTCollectionViewController {
    CGFloat _cellHeight;
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

- (void)setCellHeight:(CGFloat)cellHeight {
    _cellHeight = cellHeight;
}

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

- (void)pannningDidMoveToPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(collectionViewController:didMoveToPoint:)]) {
        [self.delegate collectionViewController:self didMoveToPoint:point];
    }
}

- (void)pannningDidStopMovingAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity {
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

#pragma mark - User Actions
#pragma mark -

#pragma mark - Gestures
#pragma mark -

- (IBAction)panGestureRecognized:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.primaryView];
    CGFloat yDelta = point.y - _panGestureStartingPoint.y;

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
                [self pannningDidMoveToPoint:CGPointMake(0.0f, yDelta)];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
                // Release to either expand or collapse depending on current position and velocity
                CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
                [self pannningDidStopMovingAtPoint:CGPointMake(0.0f, yDelta) withVelocity:velocity];
            }
            
            break;
            
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PullupCell" forIndexPath:indexPath];
    
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(320.0f, CGRectGetHeight(self.view.frame));
//    return CGSizeMake(320.0f, _cellHeight > 0 ? _cellHeight : CGRectGetHeight(self.view.frame));
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
        CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
        // Check for vertical gesture
        
        should = fabsf(translation.y) > fabsf(translation.x);
        
        if (should) {
            CGPoint point = [gestureRecognizer locationInView:self.primaryView];
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
    if (fabsf(velocity.x) > 0.1) {
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat x = targetContentOffset->x;
        x = roundf(x / width) * width;
        targetContentOffset->x = x;
    }
}

@end
