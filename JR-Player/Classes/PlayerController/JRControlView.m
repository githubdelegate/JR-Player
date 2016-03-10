//
//  JRControlView.m
//  JR-Player
//
//  Created by 王潇 on 16/3/9.
//  Copyright © 2016年 王潇. All rights reserved.
//

#import "JRControlView.h"
#import "JRPlayerView.h"
#import "SlideCollectionViewCell.h"
#import "MSWeakTimer.h"

#define MARGIN		5
#define BAR_H		30
#define LABEL_H		20
#define LABEL_W		55
#define CHOOSE		30

#define HEAD_H		40
#define BTN_H		30

#define COLL_H		56
#define COLL_Y		-COLL_H
#define SLID_C		20
//#define barY		(self.bounds.size.height - MARGIN - BAR_H)

@interface JRControlView () <UICollectionViewDelegate, UICollectionViewDataSource>
// --- View
@property (nonatomic, strong) UIButton			*playBtn;
@property (nonatomic, strong) UILabel			*currentTime;
@property (nonatomic, strong) UILabel			*totleTime;
@property (nonatomic, strong) UIButton			*chooseBtn;
@property (nonatomic, strong) UIProgressView	*progressView;
@property (nonatomic, strong) UISlider			*sliderView;

@property (nonatomic, strong) MSWeakTimer		*timer;
@property (nonatomic, assign) BOOL				isSliding;

@property (nonatomic, strong) UIView			*headerView;
@property (nonatomic, strong) UIView			*footerView;

@property (nonatomic, strong) UIButton			*closeBtn;			//
@property (nonatomic, strong) UILabel			*titleLabel;		//
@property (nonatomic, strong) UIButton			*shearBtn;			//
@property (nonatomic, strong) UIButton			*downBtn;			//
@property (nonatomic, strong) UIButton			*slidBtn;			//
//		|c|t|s|d|s|

@property (nonatomic, strong) UICollectionView		*collectionView;	// 选择
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong,) NSMutableArray		*imagesArray;
@property (nonatomic, strong) UICollectionViewFlowLayout	*layout;

@end

@implementation JRControlView

- (instancetype)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		//
		self.headerView = ({
			UIView *header = [[UIView alloc] init];
			header.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
			[self addSubview:header];
			header;
		});
		self.footerView = ({
			UIView *footer = [[UIView alloc] init];
			footer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
			[self addSubview:footer];
			footer;
		});
		
		self.playBtn = ({
			UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
			[playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
			[playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
			[playBtn addTarget:self action:@selector(playControl) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:playBtn];
			playBtn;
		});
		self.currentTime = ({
			UILabel *label	= [[UILabel alloc] init];
			label.font		= [UIFont systemFontOfSize:12];
			label.textAlignment = NSTextAlignmentCenter;
			[label setTextColor:[UIColor whiteColor]];
			[self addSubview:label];
			label;
		});
		self.sliderView = ({
			UISlider *slider = [[UISlider alloc] init];
			slider.minimumValue = 0.0;
			slider.maximumValue = 1.0;
			[slider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
			[slider addTarget:self action:@selector(slideAction) forControlEvents:UIControlEventValueChanged];
			[slider addTarget:self action:@selector(slideOver) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel];
			[self addSubview:slider];
			slider;
		});
		self.totleTime = ({
			UILabel *label	= [[UILabel alloc] init];
			label.font		= [UIFont systemFontOfSize:12];
			label.textAlignment = NSTextAlignmentCenter;
			[label setTextColor:[UIColor whiteColor]];
			[self addSubview:label];
			label;
		});
		self.chooseBtn = ({
			UIButton *btn		= [[UIButton alloc] init];
			[btn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
			[btn addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:btn];
			btn;
		});
		
		self.closeBtn = ({
			UIButton *closeBtn = [[UIButton alloc] init];
			[closeBtn setImage:[UIImage imageNamed:@"backbtn"] forState:UIControlStateNormal];
			[closeBtn addTarget:self action:@selector(fullScreen) forControlEvents:UIControlEventTouchUpInside];
			[self.headerView addSubview:closeBtn];
			closeBtn;
		});
		self.titleLabel = ({
			UILabel *title = [[UILabel alloc] init];
			title.font = [UIFont systemFontOfSize:14];
			[title setTextColor:[UIColor whiteColor]];
			[self.headerView addSubview:title];
			title;
		});
		self.shearBtn = ({
			UIButton *share = [[UIButton alloc] init];
			[share setImage:[UIImage imageNamed:@"share_normal"] forState:UIControlStateNormal];
			[share setImage:[UIImage imageNamed:@"share_selected"] forState:UIControlStateHighlighted];
			share.contentMode = UIViewContentModeCenter;
			[self.headerView addSubview:share];
			share;
		});
		self.downBtn = ({
			UIButton *down = [[UIButton alloc] init];
			[down setImage:[UIImage imageNamed:@"down_normal"] forState:UIControlStateNormal];
			[down setImage:[UIImage imageNamed:@"down_selected"] forState:UIControlStateSelected];
			[self.headerView addSubview:down];
			down;
		});
		self.slidBtn = ({
			UIButton *slidBtn = [[UIButton alloc] init];
//			[slidBtn setImage:[UIImage imageNamed:@"tab_poster_nav_n"] forState:UIControlStateNormal];
			[slidBtn setTitle:@"slide" forState:UIControlStateNormal];
			[slidBtn addTarget:self action:@selector(openSlidView) forControlEvents:UIControlEventTouchUpInside];
			[self.headerView addSubview:slidBtn];
			slidBtn;
		});

		[self addTimer];
		[self addControlBtn];
	}
	return self;
}

#pragma mark - Controller Methond
- (void)layoutSubviews {
	[super layoutSubviews];

	// 0. |c|s|t|y|
	CGRect frame = self.bounds;
	CGFloat barY = frame.size.height - BAR_H;
	// 1. playBtn
	self.playBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
	// 2. currentTime
	CGFloat curX = MARGIN;
	self.currentTime.frame = CGRectMake(curX, barY + MARGIN, LABEL_W, LABEL_H);
	// 3. sliderView
	curX = CGRectGetMaxX(self.currentTime.frame) + MARGIN;
	CGFloat slidW = self.bounds.size.width - MARGIN * 5 - 30 - LABEL_W * 2;
	self.sliderView.frame = CGRectMake(curX, barY + MARGIN, slidW, LABEL_H);
	// 4. totleTime
	curX = CGRectGetMaxX(self.sliderView.frame) + MARGIN;
	self.totleTime.frame = CGRectMake(curX, barY + MARGIN, LABEL_W, LABEL_H);
	// 5. chooseBtn
	curX = CGRectGetMaxX(self.totleTime.frame) + MARGIN;
	self.chooseBtn.frame = CGRectMake(curX, barY, CHOOSE, CHOOSE);
	
	if ([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait && self.bounds.size.width > 500) {
		self.headerView.frame = CGRectMake(0, 0, self.bounds.size.width, HEAD_H);
		self.footerView.frame = CGRectMake(0, self.bounds.size.height - HEAD_H, self.bounds.size.width, HEAD_H);
		self.closeBtn.frame	  = CGRectMake(MARGIN, MARGIN, HEAD_H, BTN_H);
		CGFloat titleW		  = self.bounds.size.width - 6 * MARGIN - 4 * HEAD_H;
		self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.closeBtn.frame) + MARGIN, MARGIN, titleW, BTN_H);
		self.shearBtn.frame	  = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + MARGIN, 0, HEAD_H, HEAD_H);
		self.downBtn.frame	  = CGRectMake(CGRectGetMaxX(self.shearBtn.frame) + MARGIN, 0, HEAD_H, HEAD_H);
		self.slidBtn.frame	  = CGRectMake(CGRectGetMaxX(self.downBtn.frame) + MARGIN, 0, HEAD_H, HEAD_H);
		
		self.headerView.hidden = NO;
		self.collectionView.hidden = NO;
	} else {
		self.headerView.frame  = CGRectMake(0, 0, 0, 0);
		self.footerView.frame  = CGRectMake(0, self.bounds.size.height - BAR_H, self.bounds.size.width, BAR_H);
		self.headerView.hidden = YES;
		self.collectionView.hidden = YES;
	}
	NSLog(@"--------------::: %@", NSStringFromCGRect(self.bounds));
}

- (void)dealloc {
	NSLog(@"===== 释放");
}

#pragma mark - Property Methond
- (void)setPlayer:(JRPlayerView *)player {
	_player = player;
	
	if (player.player.rate != 0.0) {
		self.playBtn.selected = YES;
	}
	
	CMTime time			= self.player.player.currentTime;
	CMTime time2		= self.player.playerItem.duration;
	CGFloat currentTime = time.value / (CGFloat)time.timescale;
	CGFloat totleTime	= time2.value / (CGFloat)time2.timescale;
	NSString *current	= [self calcSeconds:currentTime];
	NSString *totle		= [self calcSeconds:totleTime];
	self.currentTime.text = current;
	self.totleTime.text   = totle;
}

- (void)openSlidView {
	
	if (self.isShow == YES) {
		[self.player addTimer];
	}
	[self openSlidView:nil];
}

- (void)openSlidView:(void(^)())action {

	[self createSlideView];
	
	if (self.isShow == NO) {
		[UIView animateWithDuration:0.5 animations:^{
			self.collectionView.frame = CGRectMake(0, HEAD_H, self.bounds.size.width, COLL_H);
		} completion:^(BOOL finished) {
			self.isShow = YES;
			[self.player removeTimer];
		}];
	} else {
		[UIView animateWithDuration:0.5 animations:^{
			self.collectionView.frame = CGRectMake(0, COLL_Y, self.bounds.size.width, COLL_H);
		} completion:^(BOOL finished) {
			self.isShow = NO;
			if (action) {
				action();
			}
		}];
	}
}

- (void)createSlideView {
	if (self.collectionView) return;

	self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.player.asset];
	self.imageGenerator.maximumSize = CGSizeMake(200.0f, 0.0f);             // 2
	
	CMTime duration = self.player.asset.duration;
	
	NSMutableArray *times = [NSMutableArray array];                         // 3
	CMTimeValue increment = duration.value / SLID_C;
	CMTimeValue currentValue = 2.0 * duration.timescale;
	while (currentValue <= duration.value) {
		CMTime time = CMTimeMake(currentValue, duration.timescale);
		[times addObject:[NSValue valueWithCMTime:time]];
		currentValue += increment;
	}
	
	self.imagesArray = [NSMutableArray array];
	__block NSUInteger imageCount = times.count;                            // 4
	__block NSMutableArray *images = [NSMutableArray array];
	
	AVAssetImageGeneratorCompletionHandler handler;
	
	handler = ^(CMTime requestedTime,
				CGImageRef imageRef,
				CMTime actualTime,
				AVAssetImageGeneratorResult result,
				NSError *error) {
		
		if (result == AVAssetImageGeneratorSucceeded) {                     // 6
			UIImage *image = [UIImage imageWithCGImage:imageRef];
			
			SlideModel *model = [[SlideModel alloc] initWithImage:image time:actualTime];
			[images addObject:model];
			[self.imagesArray addObject:model];
		} else {
			NSLog(@"Error: %@", [error localizedDescription]);
		}
		
		// If the decremented image count is at 0, we're all done.
		if (--imageCount == 0) {                                            // 7
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.collectionView reloadData];
			});
		}
	};
	
	[self.imageGenerator generateCGImagesAsynchronouslyForTimes:times       // 8
											  completionHandler:handler];
	
	self.collectionView = ({
		UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, COLL_Y, self.bounds.size.width, COLL_H)
														  collectionViewLayout:self.layout];
		
		collectionView.dataSource = self;
		collectionView.delegate   = self;
		collectionView.userInteractionEnabled	   = YES;
		collectionView.showsHorizontalScrollIndicator = NO;
		[collectionView registerClass:[SlideCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
		collectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		[self insertSubview:collectionView belowSubview:self.headerView];
		collectionView;
	});
}

- (void)setTitle:(NSString *)title {
	_title = title;
	
	if (self.titleLabel) {
		self.titleLabel.text = title;
	}
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	if (self.imagesArray.count == SLID_C) {
		return self.imagesArray.count;
	}
	return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	SlideCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	
	if (self.imagesArray.count == SLID_C) {
		cell.model = self.imagesArray[indexPath.row];
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

	if (self.imagesArray.count == SLID_C) {
		CMTime time = [self.imagesArray[indexPath.row] time];
		[self.player.player seekToTime:time];
	}
}

#pragma mark - Control Methond
- (void)addTimer {
	
	if (self.timer) return;
	
	self.timer = ({
		MSWeakTimer *timer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0f
																  target:self
																selector:@selector(updateSlide)
																userInfo:nil
																 repeats:YES
														   dispatchQueue:dispatch_get_main_queue()];
		timer;
	});
}

- (void)removeTimer {
	if (self.timer) {
		[self.timer invalidate];
		self.timer = nil;
	}
}

- (void)playControl {
	
	if (self.player.player.rate == 0.0) {	// bug
		[self.player play];
		[self addTimer];
		self.playBtn.selected = YES;
	} else {
		[self.player pause];
		[self removeTimer];
		self.playBtn.selected = NO;
	}
}

- (void)slideAction {
	self.isSliding = YES;
}

- (void)slideOver {

	CMTime time2		= self.player.playerItem.duration;
	CGFloat totleTime	= time2.value / (CGFloat)time2.timescale;
	CGFloat second		= totleTime * self.sliderView.value;
	CMTime time = CMTimeMake((double)second, (int)1);
	[self.player.player seekToTime:time completionHandler:^(BOOL finished) {
		self.isSliding = NO;
	}];
}

#pragma mark - View Methond

- (void)addControlBtn {
	if (!self.sliderView) return;
	
}

- (void)updateView {
	
}

- (void)updateSlide {
	
	// slider
	CMTime time			= self.player.player.currentTime;
	CMTime time2		= self.player.playerItem.duration;
	CGFloat currentTime = time.value / (CGFloat)time.timescale;
	CGFloat totleTime	= time2.value / (CGFloat)time2.timescale;
	NSLog(@"-------------- %f - %f", currentTime, totleTime);
	if (self.isSliding == NO) {
		self.sliderView.value =  currentTime / totleTime;
	}
	
	// time
	NSString *current	= [self calcSeconds:currentTime];
	NSString *totle		= [self calcSeconds:totleTime];
	self.currentTime.text = current;
	self.totleTime.text   = totle;
}

- (NSString *)calcSeconds:(CGFloat)seconds {

	NSInteger hour = seconds / 3600;
	NSInteger time = (NSInteger)seconds % 3600;
	NSInteger min  = (NSInteger)time / 60;
	NSInteger sec  = time % 60;
	return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
}

- (void)fullScreen {
	if ([self.delegate respondsToSelector:@selector(fullScreenDidSelected)]) {
		[self.delegate fullScreenDidSelected];
	}
}

#pragma mark - Layz Loading
- (UICollectionViewFlowLayout *)layout {
	if (_layout) {
		return _layout;
	}
	
	_layout = [[UICollectionViewFlowLayout alloc] init];
	_layout.minimumLineSpacing		= 0;
	_layout.minimumInteritemSpacing = 0;
	_layout.itemSize				= CGSizeMake(100, 56);
	_layout.scrollDirection			= UICollectionViewScrollDirectionHorizontal;
	
	return _layout;
}

@end





