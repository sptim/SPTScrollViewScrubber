#import "SPTScrollViewScrubberSample_CollectionViewController.h"
#import "SPTScrollViewScrubberController.h"

#define NUMBER_OF_COLORS 20

@interface SPTScrollViewScrubberSample_CollectionViewController ()
@property (nonatomic,copy) NSArray* colors;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet SPTScrollViewScrubberController *scrubberController;

@end


@implementation SPTScrollViewScrubberSample_CollectionViewController

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
	UICollectionViewFlowLayout* layout=(UICollectionViewFlowLayout*)self.collectionViewLayout;
	layout.scrollDirection=self.segmentedControl.selectedSegmentIndex ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
	
	self.scrubberController.horizontalScrubbing=YES;
	self.scrubberController.verticalScrubbing=YES;
	self.scrubberController.horizontalAlignment=SPTScrollViewScrubberAlignmentEnd;
	self.scrubberController.verticalAlignment=SPTScrollViewScrubberAlignmentEnd;
	self.scrubberController.deselectScrubberView=^(UIView* view) {
		[(id)view setSelected:NO];
		view.alpha=0.0;
	};
	self.scrubberController.deselectDelay=5.0;
	// Do any additional setup after loading the view.
}

- (IBAction)segmentedControlValueChanged:(id)sender {
	UICollectionViewFlowLayout* layout=(UICollectionViewFlowLayout*)self.collectionViewLayout;
	layout.scrollDirection=self.segmentedControl.selectedSegmentIndex ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 11;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 10+section;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
	UILabel* label=(UILabel*)[cell viewWithTag:1];
	label.text=[NSString stringWithFormat:@"Section %d",(int)indexPath.section];
	label=(UILabel*)[cell viewWithTag:2];
	label.text=[NSString stringWithFormat:@"%d",(int)indexPath.row+1];
	cell.backgroundColor=self.colors[indexPath.row];
	cell.layer.cornerRadius=4.0;
	return cell;
}

@end
