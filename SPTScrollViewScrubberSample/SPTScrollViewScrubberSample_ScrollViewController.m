#import "SPTScrollViewScrubberSample_ScrollViewController.h"
#import "SPTScrollViewScrubberController.h"

@interface SPTScrollViewScrubberSample_ScrollViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet SPTScrollViewScrubberController *scrubberController;

@end

@implementation SPTScrollViewScrubberSample_ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.scrubberController.horizontalScrubbing=YES;
	self.scrubberController.horizontalAlignment=SPTScrollViewScrubberAlignmentNearestEdge;
	self.scrubberController.verticalAlignment=SPTScrollViewScrubberAlignmentNearestEdge;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.scrubberController scrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.scrubberController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self.scrubberController scrollViewDidEndDecelerating:scrollView];
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
	[self.scrubberController scrollViewDidZoom:scrollView];
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[self.scrubberController scrollViewWillBeginZooming:scrollView withView:view];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	[self.scrubberController scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}
@end
