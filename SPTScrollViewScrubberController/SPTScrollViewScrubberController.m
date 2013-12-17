//
//  SPTScrollViewScrubberController.m
//  SPTScrollViewScrubber
//
//  Created by Tim Mecking on 08/12/13.
//  Copyright (c) 2013 Tim Mecking. All rights reserved.
//

#import "SPTScrollViewScrubberController.h"

@interface SPTScrollViewScrubberController () <UIGestureRecognizerDelegate>
@property (nonatomic,assign,getter = isScrubberViewSelected) BOOL scrubberViewSelected;
@property (nonatomic,assign) CGPoint scrollScrubberOrigin;
@property (nonatomic,assign) CGPoint originalScrollScrubberOrigin;
@property (nonatomic,assign,getter = isScrubbing) BOOL scrubbing;
@end


@implementation SPTScrollViewScrubberController
@synthesize scrubberView=_scrubberView;

#pragma mark - Init & Dealloc

-(id)init {
	if((self=[super init])) {
		_edgeInsets=UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
		_deselectDelay=0.75;
		_deselectAnimationDuration=0.5;
		_verticalScrubbing=YES;
		_minimumHorizontalScrollFactor=2.0;
		_minimumVerticalScrollFactor=2.0;
		_hideWhileZooming=YES;
		_selectOnContentSizeChange=YES;
	}
	return self;
}

-(void)awakeFromNib {
	_edgeInsets=UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
	_deselectDelay=0.75;
	_deselectAnimationDuration=0.5;
	_verticalScrubbing=YES;
	_minimumHorizontalScrollFactor=2.0;
	_minimumVerticalScrollFactor=2.0;
	_hideWhileZooming=YES;
	_selectOnContentSizeChange=YES;
	self.scrubberView=_scrubberView;
}

-(void)dealloc {
	if(_scrubberView.superview) [_scrubberView removeFromSuperview];
	if(_scrollView.delegate==self) _scrollView.delegate=nil;
	[_scrollView removeObserver:self forKeyPath:@"contentSize"];
	[_scrollView removeObserver:self forKeyPath:@"frame"];
	[_scrubberView removeObserver:self forKeyPath:@"bounds"];
	_scrubberView.gestureRecognizers=@[];
}

#pragma mark - Public Property Accessors

-(void(^)(UIView* view))selectScrubberView {
	if(!_selectScrubberView) {
		self.selectScrubberView=^(UIView* view){
			if([view respondsToSelector:@selector(setSelected:)]) {
				NSMethodSignature* signature=[view methodSignatureForSelector:@selector(setSelected:)];
				if(*[signature getArgumentTypeAtIndex:2]==*@encode(BOOL)) [(id)view setSelected:YES];
			}
			view.alpha=1.0;
		};
	}
	return _selectScrubberView;
}

-(void(^)(UIView* view))deselectScrubberView {
	if(!_deselectScrubberView) {
		self.deselectScrubberView=^(UIView* view) {
			if([view respondsToSelector:@selector(setSelected:)]) {
				NSMethodSignature* signature=[view methodSignatureForSelector:@selector(setSelected:)];
				if(*[signature getArgumentTypeAtIndex:2]==*@encode(BOOL)) [(id)view setSelected:NO];
			}
			view.alpha=0.3;
		};
	}
	return _deselectScrubberView;
}

-(void (^)(UIView *))highlightScrubberView {
	if(!_highlightScrubberView) {
		self.highlightScrubberView=^(UIView* view) {
			if([view respondsToSelector:@selector(setHighlighted:)]) {
				NSMethodSignature* signature=[view methodSignatureForSelector:@selector(setHighlighted:)];
				if(*[signature getArgumentTypeAtIndex:2]==*@encode(BOOL)) [(id)view setHighlighted:YES];
			}
		};
	}
	return _highlightScrubberView;
}

-(void (^)(UIView *))unhighlightScrubberView {
	if(!_unhighlightScrubberView) {
		self.unhighlightScrubberView=^(UIView* view) {
			if([view respondsToSelector:@selector(setHighlighted:)]) {
				NSMethodSignature* signature=[view methodSignatureForSelector:@selector(setHighlighted:)];
				if(*[signature getArgumentTypeAtIndex:2]==*@encode(BOOL)) [(id)view setHighlighted:NO];
			}
		};
	}
	return _unhighlightScrubberView;
}

-(UIView *)scrubberView {
	if(!_scrubberView) {
		UIView* view=[[UIView alloc] initWithFrame:CGRectMake(280.0, 0.0, 30.0, 30.0)];
		view.layer.cornerRadius=15.0;
		view.backgroundColor=[UIColor redColor];
		self.scrubberView=view;
	}
	return _scrubberView;
}

-(void)setScrubberView:(UIView *)scrubberView {
	[_scrubberView removeObserver:self forKeyPath:@"bounds"];
	_scrubberView.gestureRecognizers=@[];
	if((_scrubberView=scrubberView)) {
		_scrollScrubberOrigin=scrubberView.frame.origin;
		if((self.scrollView) && (scrubberView.superview!=self.scrollView)) [self.scrollView addSubview:scrubberView];
		
		UIPanGestureRecognizer* panGestureRecognizer=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
		panGestureRecognizer.delaysTouchesBegan=YES;
		panGestureRecognizer.delegate=self;
		
		UILongPressGestureRecognizer* longPressGestureRecognizer=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		longPressGestureRecognizer.minimumPressDuration=0.01;
		longPressGestureRecognizer.delaysTouchesBegan=YES;
		longPressGestureRecognizer.delegate=self;
		
		scrubberView.gestureRecognizers=@[panGestureRecognizer,longPressGestureRecognizer];
		scrubberView.userInteractionEnabled=YES;
		
		self.selectScrubberView(scrubberView);
		self.scrubberViewSelected=YES;

		[scrubberView addObserver:self forKeyPath:@"bounds" options:0 context:NULL];
	}
}

-(void)setScrollView:(UIScrollView *)scrollView {
	[_scrollView removeObserver:self forKeyPath:@"contentSize"];
	[_scrollView removeObserver:self forKeyPath:@"frame"];
	if((_scrollView=scrollView)) {
		if(scrollView.delegate==nil) scrollView.delegate=self;
		if((_scrubberView) && (_scrubberView.superview!=scrollView)) [scrollView addSubview:_scrubberView];
		[scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
		[scrollView addObserver:self forKeyPath:@"frame" options:0 context:NULL];
	}
}

-(void)setMinimumHorizontalScrollFactor:(CGFloat)minimumHorizontalScrollFactor {
	NSAssert(minimumHorizontalScrollFactor>1.0,@"minimumHorizontalScrollFactor must be greater than 1.0",nil);
	_minimumHorizontalScrollFactor=minimumHorizontalScrollFactor;
}

-(void)setMinimumVerticalScrollFactor:(CGFloat)minimumVerticalScrollFactor {
	NSAssert(minimumVerticalScrollFactor>1.0,@"minimumVerticalScrollFactor must be greater than 1.0",nil);
	_minimumVerticalScrollFactor=minimumVerticalScrollFactor;
}

#pragma mark - Public Methods

-(void)flashScrubberView {
	if(!self.scrubberViewSelected) {
		self.scrubberViewSelected=YES;
		[self deselectScrubberViewAnimatedAfterDelay];
	}
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(object==_scrollView) {
		if((_scrubberView) && (!self.scrollView.zooming)) {
			[self setScrubberViewFrame];
			if((self.selectOnContentSizeChange) && ([keyPath isEqualToString:@"contentSize"]) && (!self.scrubberViewSelected)) {
				self.scrubberViewSelected=YES;
				[self deselectScrubberViewAnimatedAfterDelay];
			}
		}
	}
	else if(object==_scrubberView) {
		if(_scrollView) [self setScrubberViewFrame];
	}
}

#pragma mark - Private Property Accessors

-(void)setScrubbing:(BOOL)scrubbing {
	if(_scrubbing!=scrubbing) {
		if((_scrubbing=scrubbing)) {
			self.scrubberViewSelected=YES;
			self.highlightScrubberView(self.scrubberView);
		}
		else {
			self.unhighlightScrubberView(self.scrubberView);
			[self deselectScrubberViewAnimatedAfterDelay];
		}
	}
}

-(void)setScrubberViewSelected:(BOOL)scrubberViewSelected {
	[self setScrubberViewSelected:scrubberViewSelected animated:NO];
}

#pragma mark - Private Methods

-(void)setScrubberViewSelected:(BOOL)scrubberViewSelected animated:(BOOL)animated {
	[self cancelDeselectScrubberViewAnimatedAfterDelay];
	if(scrubberViewSelected!=_scrubberViewSelected) {
		void(^block)(UIView*)=scrubberViewSelected ? self.selectScrubberView : self.deselectScrubberView;
		if(animated) {
			[UIView animateWithDuration:self.deselectAnimationDuration
								  delay:0.0
								options:UIViewAnimationOptionAllowUserInteraction+UIViewAnimationOptionBeginFromCurrentState
							 animations:^{
								 block(self.scrubberView);
							 }
							 completion:^(BOOL finished) {
							 }];
		}
		else {
			block(self.scrubberView);
		}
		_scrubberViewSelected=scrubberViewSelected;
	}
}

-(void)deselectScrubberViewAnimated {
	[self setScrubberViewSelected:NO animated:YES];
}

-(void)deselectScrubberViewAnimatedAfterDelay {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(deselectScrubberViewAnimated) object:nil];
	[self performSelector:@selector(deselectScrubberViewAnimated) withObject:nil afterDelay:self.deselectDelay];
}

-(void)cancelDeselectScrubberViewAnimatedAfterDelay {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(deselectScrubberViewAnimated) object:nil];
}

-(void)horizontalAlignScrubberView {
	CGFloat minX=self.scrollView.contentInset.left+self.edgeInsets.left;
	CGFloat maxX=self.scrollView.bounds.size.width-self.scrollView.contentInset.right-self.edgeInsets.right-self.scrubberView.frame.size.width;
	switch (self.horizontalAlignment) {
		case SPTScrollViewScrubberAlignmentBegin:
			_scrollScrubberOrigin.x=minX;
			break;
		case SPTScrollViewScrubberAlignmentEnd:
			_scrollScrubberOrigin.x=maxX;
			break;
		case SPTScrollViewScrubberAlignmentMiddle:
			_scrollScrubberOrigin.x=floor((maxX-minX)/2.0)+minX;
			break;
		case SPTScrollViewScrubberAlignmentNearestEdge:
			_scrollScrubberOrigin.x=(_scrollScrubberOrigin.x>floor((maxX-minX)/2.0)+minX) ? maxX : minX;
			break;
		case SPTScrollViewScrubberAlignmentNone:
			_scrollScrubberOrigin.x=self.scrubberView.frame.origin.x-self.scrollView.contentOffset.x;
			break;
	}
	_scrollScrubberOrigin.x=MIN(MAX(_scrollScrubberOrigin.x,minX),maxX);
}

-(void)verticalAlignScrubberView {
	CGFloat minY=self.scrollView.contentInset.top+self.edgeInsets.top;
	CGFloat maxY=self.scrollView.bounds.size.height-self.scrollView.contentInset.bottom-self.edgeInsets.bottom-self.scrubberView.frame.size.height;
	switch (self.verticalAlignment) {
		case SPTScrollViewScrubberAlignmentBegin:
			_scrollScrubberOrigin.y=minY;
			break;
		case SPTScrollViewScrubberAlignmentEnd:
			_scrollScrubberOrigin.y=maxY;
			break;
		case SPTScrollViewScrubberAlignmentMiddle:
			_scrollScrubberOrigin.y=floor((maxY-minY)/2.0)+minY;
			break;
		case SPTScrollViewScrubberAlignmentNearestEdge:
			_scrollScrubberOrigin.y=(_scrollScrubberOrigin.y>floor((maxY-minY)/2.0)+minY) ? maxY : minY;
			break;
		case SPTScrollViewScrubberAlignmentNone:
			_scrollScrubberOrigin.y=self.scrubberView.frame.origin.y-self.scrollView.contentOffset.y;
			break;
	}
	_scrollScrubberOrigin.y=MIN(MAX(_scrollScrubberOrigin.y,minY),maxY);
}

-(void)setScrubberViewFrame {
	if(!self.scrubbing) {
		CGRect contentFrame=UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
		BOOL hideScrubberView=YES;
		
		if((self.verticalScrubbing) && (self.scrollView.contentSize.height/contentFrame.size.height>=self.minimumVerticalScrollFactor)) {
			CGFloat bottom=self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
			CGFloat factorY=(bottom==0.0) ? 0.0 : self.scrollView.contentOffset.y/bottom;
			CGFloat minY=self.scrollView.contentInset.top+self.edgeInsets.top;
			CGFloat maxY=self.scrollView.bounds.size.height-self.scrollView.contentInset.bottom-self.edgeInsets.bottom-self.scrubberView.frame.size.height;
			_scrollScrubberOrigin.y=MIN(MAX(factorY * (maxY-minY) + minY,minY),maxY);
			hideScrubberView=NO;
		}
		else {
			[self verticalAlignScrubberView];
		}
		if((self.horizontalScrubbing) && (self.scrollView.contentSize.width/contentFrame.size.width>=self.minimumHorizontalScrollFactor)) {
			CGFloat right=self.scrollView.contentSize.width-self.scrollView.bounds.size.width;
			CGFloat factorX=(right==0.0) ? 0.0 : self.scrollView.contentOffset.x / right;
			CGFloat minX=self.scrollView.contentInset.left+self.edgeInsets.left;
			CGFloat maxX=self.scrollView.bounds.size.width-self.scrollView.contentInset.right-self.edgeInsets.right-self.scrubberView.frame.size.width;
			_scrollScrubberOrigin.x=MIN(MAX(factorX * (maxX-minX) + minX,minX),maxX);
			hideScrubberView=NO;
		}
		else {
			[self horizontalAlignScrubberView];
		}
		
		if((self.scrollView.zooming) && (self.hideWhileZooming)) hideScrubberView=YES;
		self.scrubberView.hidden=hideScrubberView;
	}
	
	CGRect scrubberFrame=self.scrubberView.frame;
	scrubberFrame.origin.x=self.scrollScrubberOrigin.x+self.scrollView.contentOffset.x;
	scrubberFrame.origin.y=self.scrollScrubberOrigin.y+self.scrollView.contentOffset.y;
	self.scrubberView.frame=scrubberFrame;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if(scrollView==self.scrollView) {
		if((self.selectOnAnyContentOffsetChange) || (scrollView.dragging)) {
			self.scrubberViewSelected=YES;
		}
		if((!self.scrubbing) && (!scrollView.dragging)) {
			[self deselectScrubberViewAnimatedAfterDelay];
		}

		[self setScrubberViewFrame];
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(scrollView==self.scrollView) {
		if(!decelerate) [self deselectScrubberViewAnimatedAfterDelay];
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if(scrollView==self.scrollView) {
		[self deselectScrubberViewAnimatedAfterDelay];
	}
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
	if(scrollView==self.scrollView) {
		[self setScrubberViewFrame];
	}
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	if(scrollView==self.scrollView) {
		if(self.hideWhileZooming) self.scrubberView.hidden=YES;
	}
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	if(scrollView==self.scrollView) {
		[self setScrubberViewFrame];
	}
}

#pragma mark - Gesture Recognizer

-(void)pan:(UIPanGestureRecognizer*)recognizer {
	switch(recognizer.state) {
		case UIGestureRecognizerStateBegan:
			self.scrubbing=YES;
			self.originalScrollScrubberOrigin=self.scrollScrubberOrigin;
			[recognizer setTranslation:CGPointZero inView:self.scrollView];
			break;
		case UIGestureRecognizerStateChanged: {
			CGPoint translation=[recognizer translationInView:self.scrollView];
			CGRect contentFrame=UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
			
			CGPoint contentOffset=self.scrollView.contentOffset;
			if((self.verticalScrubbing) && (self.scrollView.contentSize.height/contentFrame.size.height>=self.minimumVerticalScrollFactor)) {
				CGFloat minY=self.scrollView.contentInset.top+self.edgeInsets.top;
				CGFloat maxY=self.scrollView.bounds.size.height-self.scrollView.contentInset.bottom-self.edgeInsets.bottom-self.scrubberView.frame.size.height;
				CGFloat minOffsetY=-self.scrollView.contentInset.top;
				CGFloat maxOffsetY=self.scrollView.contentSize.height-self.scrollView.bounds.size.height+self.scrollView.contentInset.bottom;
			
				if((minY<maxY) && (minOffsetY<maxOffsetY)) {
					_scrollScrubberOrigin.y=MIN(MAX(_originalScrollScrubberOrigin.y+translation.y,minY),maxY);
					CGFloat factorY=(_scrollScrubberOrigin.y-minY) / (maxY-minY);
					contentOffset.y=factorY*(maxOffsetY-minOffsetY)+minOffsetY;
				}
			}
			else {
				[self verticalAlignScrubberView];
			}
			
			if((self.horizontalScrubbing) && (self.scrollView.contentSize.width/contentFrame.size.width>=self.minimumHorizontalScrollFactor)) {
				CGFloat minX=self.scrollView.contentInset.left+self.edgeInsets.left;
				CGFloat maxX=self.scrollView.bounds.size.width-self.scrollView.contentInset.right-self.edgeInsets.right-self.scrubberView.frame.size.width;
				CGFloat minOffsetX=-self.scrollView.contentInset.left;
				CGFloat maxOffsetX=self.scrollView.contentSize.width-self.scrollView.bounds.size.width+self.scrollView.contentInset.right;
				
				if((minX<maxX) && (minOffsetX<maxOffsetX)) {
					_scrollScrubberOrigin.x=MIN(MAX(_originalScrollScrubberOrigin.x+translation.x,minX),maxX);
					CGFloat factorX=(_scrollScrubberOrigin.x-minX) / (maxX-minX);
					contentOffset.x=factorX*(maxOffsetX-minOffsetX)+minOffsetX;
				}
			}
			else {
				[self horizontalAlignScrubberView];
			}
			self.scrollView.contentOffset=contentOffset;
			break;
		}
		default:
			self.scrubbing=NO;
	}
}

-(void)longPress:(UILongPressGestureRecognizer*)recognizer {
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			self.scrubbing=YES;
			break;
		case UIGestureRecognizerStateFailed:
		case UIGestureRecognizerStateEnded:
			self.scrubbing=NO;
			break;
		default:
			break;
	}
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return (otherGestureRecognizer.delegate==self);
}
@end
