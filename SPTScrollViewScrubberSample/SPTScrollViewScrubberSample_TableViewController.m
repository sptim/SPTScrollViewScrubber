#import "SPTScrollViewScrubberSample_TableViewController.h"
#import "SPTScrollViewScrubberController.h"

#define NUMBER_OF_COLORS	40

@interface SPTScrollViewScrubberSample_TableViewController ()
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (nonatomic,strong) SPTScrollViewScrubberController* scrubberController;
@property (nonatomic,copy) NSArray* colors;
@end

@implementation SPTScrollViewScrubberSample_TableViewController

-(NSArray *)colors {
	if(!_colors) {
		NSMutableArray* array=[[NSMutableArray alloc] initWithCapacity:NUMBER_OF_COLORS];
		for(NSInteger i=0 ; i<NUMBER_OF_COLORS ; i++) {
			[array addObject:[UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0]];
		}
		self.colors=array;
	}
	return _colors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.scrubberController=[[SPTScrollViewScrubberController alloc] init];
	self.scrubberController.scrollView=self.tableView;
}

- (IBAction)stepperValueChanged:(id)sender {
	[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stepper.value;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text=[NSString stringWithFormat:@"Cell %d of %d",(int)indexPath.row+1,(int)self.stepper.value];
	cell.backgroundColor=self.colors[indexPath.row % NUMBER_OF_COLORS];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.scrubberController scrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self.scrubberController scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self.scrubberController scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - View rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Since we did not read the documentation we have to adjust the scrubber's horizontal position
	
	CGFloat distance=self.tableView.bounds.size.width-self.scrubberController.scrubberView.center.x;
	double delayInSeconds = duration/2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		CGPoint center=self.scrubberController.scrubberView.center;
		center.x=self.tableView.bounds.size.width-distance;
		self.scrubberController.scrubberView.center=center;
	});
}
@end
