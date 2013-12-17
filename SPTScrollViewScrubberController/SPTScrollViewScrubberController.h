//
//  SPTScrollViewScrubberController.h
//  SPTScrollViewScrubber
//
//  Created by Tim Mecking on 08/12/13.
//  Copyright (c) 2013 Tim Mecking. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Scrubber alignment for non-active axis.
 */
typedef NS_ENUM(NSUInteger,SPTScrollViewScrubberAlignment) {
	/// Do not align, leave the frame.origin.x/y as is.
	SPTScrollViewScrubberAlignmentNone=0,
	
	/// Align to the left/top edge, set frame.origin.x/y to the edge inset.
	SPTScrollViewScrubberAlignmentBegin,
	
	/// Align to the center, set the center.x/y to the middle between the edge
	/// insets.
	SPTScrollViewScrubberAlignmentMiddle,
	
	/// Align to the right/bottom edge, set the frame.origin.x/y to the scroll
	/// views bounds.size.width/height - edge inset - frame.size.width/height.
	SPTScrollViewScrubberAlignmentEnd,
	
	/// Align to the nearest edge.
	SPTScrollViewScrubberAlignmentNearestEdge
};
#define SPTScrollViewScrubberAlignmentLeft		SPTScrollViewScrubberAlignmentBegin
#define SPTScrollViewScrubberAlignmentRight		SPTScrollViewScrubberAlignmentEnd
#define SPTScrollViewScrubberAlignmentTop		SPTScrollViewScrubberAlignmentBegin
#define SPTScrollViewScrubberAlignmentBottom	SPTScrollViewScrubberAlignmentEnd

/**
 * Instances of `SPTScrollViewScrubberController` control a scrubber view to 
 * quickly scroll through an `UIScrollView` or any of its subclasses like
 * `UITableView` or `UICollectionView`.
 *
 * It was inspired by [NSScreencast episode 97: Scrolling Nub (11/28/2013)][1].
 *
 *
 * [1]: http://nsscreencast.com/episodes/97-scrolling-nub
 *
 *
 * ### UIScrollViewDelegate ###
 *
 * It is not necessary that SPTScrollViewController instances are the delegate
 * of the scroll view as long as the following delegate callbacks get passed
 * through:
 *
 *	-(void)scrollViewDidScroll:(UIScrollView *)scrollView
 *	-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
 *	-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
 *
 * And additionally these if zooming is enabled for the scroll view:
 *
 *	-(void)scrollViewDidZoom:(UIScrollView *)scrollView
 *	-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
 *	-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
 *
 *
 */

@interface SPTScrollViewScrubberController : NSObject
	<UIScrollViewDelegate,UITableViewDelegate,UICollectionViewDelegate>

/**
 * ---------------------------------------------------------------------------
 * @name Views
 * ---------------------------------------------------------------------------
 */

/**
 * The instance of `UIScrollView` or any of its subclasses to be used with
 * the scrubber.
 */
@property (nonatomic,strong) IBOutlet UIScrollView* scrollView;

/**
 * A `UIView` instance or any of its subclasses to be used as the scrubber.
 *
 * This view will be added as a subview to the scrollView object, if it has not
 * already been added. The default is a simple 30x30 view with red background 
 * color and a corner radius of 15 which results in red dot.
 *
 * @warning	There must not be any autolayout constraints affecting its 
 * 			layout.
 */
@property (nonatomic,strong) IBOutlet UIView* scrubberView;

/**
 * ---------------------------------------------------------------------------
 * @name Scroll direction
 * ---------------------------------------------------------------------------
 */

/**
 * A Boolean value that determines whether the scrubber should be used for
 * horizontal scrolling.
 *
 * The default value is `NO`.
 */
@property (nonatomic,assign) BOOL horizontalScrubbing;

/**
 * A Boolean value that determines whether the scrubber should be used for
 * vertical scrolling.
 *
 * The default value is `YES`.
 */
@property (nonatomic,assign) BOOL verticalScrubbing;

/**
 * The minimum factor the content views width must be larger than the scroll
 * views content areas width at which the scrubber can be used for horizontal
 * scrolling.
 *
 * The scroll views content area is determined by adjusting its bounds by its
 * content insets. The minimumHorizontalScrollFactor must be greater than 1.0.
 * The default value is `2.0`.
 */
@property (nonatomic,assign) CGFloat minimumHorizontalScrollFactor;

/**
 * The minimum factor the content views height must be larger than the scroll
 * views content areas height at which the scrubber can be used for vertical
 * scrolling.
 *
 * The scroll views content area is determined by adjusting its bounds by its
 * content insets. The minimumVerticalScrollFactor must be greater than 1.0.
 * The default value is `2.0`.
 */
@property (nonatomic,assign) CGFloat minimumVerticalScrollFactor;

/**
 * ---------------------------------------------------------------------------
 * @name Scrubber positioning
 * ---------------------------------------------------------------------------
 */

/**
 * The minimum distance the scrubber view is inset from the enclosing scroll
 * view.
 *
 * The default value is `{10.0,10.0,10.0,10.0}`.
 */
@property (nonatomic,assign) UIEdgeInsets edgeInsets;

/**
 * The alignment mode for the horizontal axis.
 *
 * The scrubber view is aligned according to this value if it is not used for
 * horizontal scrolling or if the scrollable area is not large enough. The 
 * default value is `SPTScrollViewScrubberAlignmentNone`.
 *
 * @see horizontalScrubbing
 * @see minimumHorizontalScrollFactor
 * @see SPTScrollViewScrubberAlignment
 */
@property (nonatomic,assign) SPTScrollViewScrubberAlignment horizontalAlignment;

/**
 * The alignment mode for the vertical axis.
 *
 * The scrubber view is aligned according to this value if it is not used for
 * vertical scrolling or if the scrollable area is not large enough. The
 * default value is `SPTScrollViewScrubberAlignmentNone`.
 *
 * @see verticalScrubbing
 * @see minimumVerticalScrollFactor
 * @see SPTScrollViewScrubberAlignment
 */
@property (nonatomic,assign) SPTScrollViewScrubberAlignment verticalAlignment;

/**
 * ---------------------------------------------------------------------------
 * @name Scrubber hiding / selecting / highlighting
 * ---------------------------------------------------------------------------
 */

/**
 * A Boolean value that determines if the scrubber view should be hidden while
 * the user performs a zoom gesture.
 *
 * The default value is `YES`.
 */
@property (nonatomic,assign) BOOL hideWhileZooming;

/**
 * A Boolean value that determines if the scrubber view should be selected when
 * the scroll views content size changes.
 *
 * The default value is `YES`.
 */
@property (nonatomic,assign) BOOL selectOnContentSizeChange;

/**
 * A Boolean value that determines if the scrubber view should be selected when
 * the scroll views content offset changes for any reason.
 *
 * If this value is `NO` the scrubber view will only be selected if content
 * offset changes have been caused by a drag gesture.
 * Otherwise the scrubber gets selected for any change of the scroll position,
 * e.g. status bar taps, programmatically changes to the content offset, or
 * content size being shrinked.
 *
 * The default value is `YES`.
 */
@property (nonatomic,assign) BOOL selectOnAnyContentOffsetChange;

/**
 * A block which changes properties of the scrubber view to highlight it.
 *
 * This is called when the scrubbing property changes to `YES`, i.e. a drag 
 * operation on the scrubber view begins. The default block sets the views
 * highlighted property if it responds to -setHighlighted:.
 */
@property (nonatomic,copy) void(^highlightScrubberView)(UIView* view);

/**
 * A block which changes properties of the scrubber view to unhighlight it.
 *
 * This is called when the scrubbing property changes to `NO`, i.e. a drag
 * operation on the scrubber view ends. The default block unsets the views
 * highlighted propertxy if it responds to -setHighlighted:.
 */
@property (nonatomic,copy) void(^unhighlightScrubberView)(UIView* view);

/**
 * A block which changes properties of the scrubber view to select it.
 *
 * This is used in select animation or called directly when the view needs to
 * selected immediatly. The default block sets the scrubber views alpha
 * value to 1.0 and sets the views selected property if it responds to 
 * -setSelected:.
 */
@property (nonatomic,copy) void(^selectScrubberView)(UIView* view);

/**
 * A block which changes properties of the scrubber view to unselect it.
 *
 * This is used in unselect animation. The default block sets the scrubber views
 * alpha value to 0.3 and unsets its selected property if it responds to
 * -setSelected:.
 */
@property (nonatomic,copy) void(^deselectScrubberView)(UIView* view);

/**
 * The time interval by which the unselection gets delayed after scrolling.
 *
 * The default value is 0.75 seconds.
 */
@property (nonatomic,assign) NSTimeInterval deselectDelay;

/**
 * A time interval value that determines the duration of deselect animations.
 *
 * The default value is 0.5 seconds.
 */
@property (nonatomic,assign) NSTimeInterval deselectAnimationDuration;

/**
 * Flashes the scrubber view by selecting immediately and deselecting it 
 * animated.
 *
 * This method has no effect if the scrubber view is selected.
 */
-(void)flashScrubberView;

/**
 * ---------------------------------------------------------------------------
 * @name State
 * ---------------------------------------------------------------------------
 */

/**
 * A Boolean value that determines if the user is currently dragging the
 * scrubber view.
 */
@property (nonatomic,readonly,getter = isScrubbing) BOOL scrubbing;

/**
 * A Boolean value that determines if the scrubber view is currently selected.
 *
 */
@property (nonatomic,readonly,getter = isScrubberViewSelected) BOOL scrubberViewSelected;

@end
