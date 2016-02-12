About
-----

SPTScrollViewScrubberController adds a scrubber to an instance of UIScrollView
or any of its subclasses to quickly scroll through large contents.

It was inspired by [NSScreencast episode 97: Scrolling Nub (11/28/2013)][1].

[1]: http://nsscreencast.com/episodes/97-scrolling-nub


License
-------

SPTScrollViewScrubberController and SPTScrollViewScrubberSample are released
under MIT License.
It is highly appreciated, though not required, to include a link to 
[http://www.mecking.net/ios-apps/](http://www.mecking.net/ios-apps/) anywhere
in your app or on your website.


Obtaining the source
--------------------

The source code is available on github at 
[https://github.com/sptim/SPTScrollViewScrubber][2].

[AppleDoc][3] generated documentation can be browsed at
[http://sptim.github.io/SPTScrollViewScrubber/][4].

SPTScrollViewScrubberController is also available using [CocoaPods][5]. Add 
this to your `Podfile` and run `pod install`:

	pod 'SPTScrollViewScrubber'

[2]: https://github.com/sptim/SPTScrollViewScrubber/
[3]: http://gentlebytes.com/appledoc/
[4]: http://sptim.github.io/SPTScrollViewScrubber/
[5]: http://cocoapods.org/



Using SPTScrollViewScrubberController with UITableView
------------------------------------------------------

### Adding a scrubber to an `UITableView` instance programmatically ###

Only 2 steps are necessary to add a scrubber to a table view.

1. Import the header and add a property for the SPTScrollViewScrubberController
   instance of your UITableViewController subclass.

		@property (nonatomic,strong) SPTScrollViewScrubberController* scrubController;

2. In your -viewDidLoad method instanciate and setup the
   SPTScrollViewScrubberController object.

		self.scrubController=[[SPTScrollViewScrubberController alloc] init];
		self.scrubController.scrollView=self.tableView;
		self.tableView.delegate=self.scrubController;


### UITableViewDelegate Methods ###

If you cannot make the SPTScrollViewScrubberController instance the delegate of the
table view, you must forward 3 delegate methods from your table view delegate
(usually the UITableViewController subclass) to the scrubber controller:

	-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
		[self.scrubController scrollViewDidScroll:scrollView];
	}
	-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
		[self.scrubController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}
	 -(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
		[self.scrubberController scrollViewDidEndDecelerating:scrollView];
	}


### Scrubber View ###

You most probably want to use a custom scrubber view. To do so just set the
scrubberView property to an instance of UIView or any of its subclasses. 
There must not be any autolayout constraints attached to that view. Use its
frame or center property to position and size it.

By default SPTScrollViewScrubberController only changes the scrubberViews
position on the scrubbing/scrolling axis(es). When used with UITableView this
is always the vertical axis (y coordinate).

If you set the horizontalAlignment property on the controller, it will also
position the scrubberView on the horizontal axis. You can choose to have it
pinned to any side or the center of the scroll view. When the frame of the
scrollView changes, i.e. because of interface rotation, the 
SPTScrollViewScrubberController will adjust the scrubberViews position 
accordingly.

The margin, i.e. free space between the scrollViews edge and the 
scrubberView, can be configured using SPTScrollViewScrubberController's
edgeInsets property.

The scrubber view will be hidden if the table views content height is less than
2 times its content area height. The content area is determined by by applying
its content inset to its bounds. You can adjust the minimum factor at which the
scrubber will be shown by setting the minimumVerticalScrollFactor property of
your SPTScrollViewScrubberController instance. The factor must be greater than
`1.0`.

### View Transitions & Animations ###

The scrubber can be in 3 different states:

- unselected / unhighlighted

  This is the idle state. By default the scrubber view is faded out by having
  its alpha value set to 0.3.

- selected / unhighlighted

  During any scroll event the scrubber view enters this state. After some delay
  it returns to the previous state. In the default configuration the view's 
  alpha value is set to 1.0.

- selected / highlighted

  While the user touches and holds the scrubber view, its in this state. There
  is no visual difference from the previous state in the default configuration.

There are four block properties on SPTScrollViewScrubberController to configure
the view transitions:

1. `@property (nonatomic,copy) void(^highlightScrubberView)(UIView* view);`

2. `@property (nonatomic,copy) void(^unhighlightScrubberView)(UIView* view);`

3. `@property (nonatomic,copy) void(^selectScrubberView)(UIView* view);`

4. `@property (nonatomic,copy) void(^deselectScrubberView)(UIView* view);`

Each get called with a pointer to the scrubberView object as the argument. The 
default implementations set the corresponding property of the scrubberView 
object if it responds to the setter selector (-[setSelected:], 
-[setHighlighted:]). The select/unselect blocks also set the view's alpha value
as described above.

Currently the only transition which gets animated is deselect. Its animation
speed is configured by the deselectAnimationDuration property of the scrubber 
controller. After a scroll operation finishes, deselection is delayed by the 
time interval specified in the deselectDelay property.







