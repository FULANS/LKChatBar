//
//  LKLayImSwipeView.h
//  LiemsMobileEnterprise
//
//  Created by hillyoung on 2019/2/15.
//  Copyright © 2019 luculent. All rights reserved.
//

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wauto-import"
#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"

#import <Availability.h>
#undef weak_delegate
#if __has_feature(objc_arc) && __has_feature(objc_arc_weak)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LKSwipeViewAlignment)
{
    LKSwipeViewAlignmentEdge = 0,
    LKSwipeViewAlignmentCenter
};


@protocol LKSwipeViewDataSource, LKSwipeViewDelegate;

@interface LKSwipeView : UIView

@property (nonatomic, weak) IBOutlet id<LKSwipeViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<LKSwipeViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, readonly) CGSize itemSize;
@property (nonatomic, assign) NSInteger itemsPerPage;
@property (nonatomic, assign) BOOL truncateFinalPage;
@property (nonatomic, strong, readonly) NSArray *indexesForVisibleItems;
@property (nonatomic, strong, readonly) NSArray *visibleItemViews;
@property (nonatomic, strong, readonly) UIView *currentItemView;
@property (nonatomic, assign) NSInteger currentItemIndex;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) LKSwipeViewAlignment alignment;
@property (nonatomic, assign) CGFloat scrollOffset;
@property (nonatomic, assign, getter = isPagingEnabled) BOOL pagingEnabled;
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign, getter = isWrapEnabled) BOOL wrapEnabled;
@property (nonatomic, assign) BOOL delaysContentTouches;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) float decelerationRate;
@property (nonatomic, assign) CGFloat autoscroll;
@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isDecelerating) BOOL decelerating;
@property (nonatomic, readonly, getter = isScrolling) BOOL scrolling;
@property (nonatomic, assign) BOOL defersItemViewLoading;
@property (nonatomic, assign, getter = isVertical) BOOL vertical;

- (void)reloadData;
- (void)reloadItemAtIndex:(NSInteger)index;
- (void)scrollByOffset:(CGFloat)offset duration:(NSTimeInterval)duration;
- (void)scrollToOffset:(CGFloat)offset duration:(NSTimeInterval)duration;
- (void)scrollByNumberOfItems:(NSInteger)itemCount duration:(NSTimeInterval)duration;
- (void)scrollToItemAtIndex:(NSInteger)index duration:(NSTimeInterval)duration;
- (void)scrollToPage:(NSInteger)page duration:(NSTimeInterval)duration;
- (UIView *)itemViewAtIndex:(NSInteger)index;
- (NSInteger)indexOfItemView:(UIView *)view;
- (NSInteger)indexOfItemViewOrSubview:(UIView *)view;

@end


@protocol LKSwipeViewDataSource <NSObject>

- (NSInteger)numberOfItemsInLKSwipeView:(LKSwipeView *)swipeView;
- (UIView *)swipeView:(LKSwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;

@end


@protocol LKSwipeViewDelegate <NSObject>
@optional

- (CGSize)swipeViewItemSize:(LKSwipeView *)swipeView;
- (void)swipeViewDidScroll:(LKSwipeView *)swipeView;
- (void)swipeViewCurrentItemIndexDidChange:(LKSwipeView *)swipeView;
- (void)swipeViewWillBeginDragging:(LKSwipeView *)swipeView;
- (void)swipeViewDidEndDragging:(LKSwipeView *)swipeView willDecelerate:(BOOL)decelerate;
- (void)swipeViewWillBeginDecelerating:(LKSwipeView *)swipeView;
- (void)swipeViewDidEndDecelerating:(LKSwipeView *)swipeView;
- (void)swipeViewDidEndScrollingAnimation:(LKSwipeView *)swipeView;
- (BOOL)swipeView:(LKSwipeView *)swipeView shouldSelectItemAtIndex:(NSInteger)index;
- (void)swipeView:(LKSwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index;

@end

