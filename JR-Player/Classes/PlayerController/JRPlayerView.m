//
//  JRPlayerView.m
//  JR-Player
//
//  Created by 王潇 on 16/3/9.
//  Copyright © 2016年 王潇. All rights reserved.
//

#import "JRPlayerView.h"
#import "JRControlView.h"

@interface JRPlayerView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIButton					*playControl;		// 播放控制按钮
@property (nonatomic, strong) UIActivityIndicatorView	*activity;			// 菊花
@property (nonatomic, strong) UIButton					*appearBtn;			// 开始播放按钮
@property (nonatomic, strong) CALayer					*imageLayer;		// 预览图片

@property (nonatomic, assign) BOOL						smallAppear;
@property (nonatomic, assign) BOOL						isAutoScreen;		//
@property (nonatomic, strong) NSTimer					*closeTimer;		//

@property (nonatomic, assign) CGRect			oldFrame;			// 小屏frame
@end

#define STATUS_KEYPATH @"status"
#define RATE_KEYPATH @"rate"
static const NSString *PlayerItemStatusContext;
static const NSString *PlayerItemRateContext;
@implementation JRPlayerView

- (instancetype)initWithFrame:(CGRect)frame
						image:(NSString *)imageUrl
						asset:(NSURL *)assetUrl {
	
	if (self = [super init]) {
		_imageUrl	= imageUrl;
		_assetUrl	= assetUrl;
		_oldFrame	= frame;
		self.frame	= frame;
		_asset		= [AVAsset assetWithURL:assetUrl];
		self.backgroundColor = [UIColor blackColor];
		[self setImage:imageUrl];
	}
	return self;
}


- (instancetype)initWithFrame:(CGRect)frame
						asset:(NSURL *)assetUrl {
	
	if (self = [super initWithFrame:frame]) {
		_assetUrl = assetUrl;
		_oldFrame = frame;
		_asset	  = [AVAsset assetWithURL:assetUrl];
		self.backgroundColor = [UIColor blackColor];
		[self prepareToPlay];
		[self addControlView];
		[self addGesture];
		
	}
	
	return self;
}

- (instancetype)initWithURL:(NSURL *)assetURL {
	
	if (self = [super init]) {
		_asset = [AVAsset assetWithURL:assetURL];
		[self setView];
	}
	return self;
}

- (void)setImage:(NSString *)imageUrl {
	
	// 1. Image
	self.imageLayer = [CALayer layer];
	NSData *data	= [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
	UIImage *image	= [UIImage imageWithData:data];
	self.imageLayer.contents = (__bridge id _Nullable)([image CGImage]);
	[self.layer addSublayer:self.imageLayer];
	
	// 2. playBtn
	self.appearBtn	= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
	[self.appearBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
	[self addSubview:self.appearBtn];
	[self.appearBtn addTarget:self action:@selector(prepareToPlay) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUrlString:(NSString *)urlString {
	_urlString = urlString;
	_asset = [AVAsset assetWithURL:[NSURL URLWithString:urlString]];
}

- (void)prepareToPlay {
	
	// 1. 获取属性
	NSArray *keys = @[
					  @"tracks",
					  @"duration",
					  @"commonMetadata",
					  @"availableMediaCharacteristicsWithMediaSelectionOptions",
					  @"presentationSize"
					  ];
	
	// 2. 创建 AVPlayerItem
	self.playerItem = [AVPlayerItem playerItemWithAsset:self.asset          // 2
						   automaticallyLoadedAssetKeys:keys];

	// 3. 监控播放状态
	[self.playerItem addObserver:self                                       // 3
					  forKeyPath:STATUS_KEYPATH
						 options:0
						 context:&PlayerItemStatusContext];
	
	// 4. 创建播放对象
	self.player		= [AVPlayer playerWithPlayerItem:self.playerItem];      // 4
	
	[self.player addObserver:self
				  forKeyPath:RATE_KEYPATH
					 options:0
					 context:&PlayerItemRateContext];
	
	// 5. 添加到 View
	[(AVPlayerLayer *) [self layer] setPlayer:self.player];
	
	if (self.appearBtn) {
		[self.appearBtn removeFromSuperview];
	}
	
	[self play];
	[self setView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	
	NSLog(@"notifacation: %@   %@", keyPath, change);
	
	if ([change[@"kind"] isEqualToNumber:[NSNumber numberWithInteger:1]]) {
		
		if (self.imageLayer) {
			[self.imageLayer removeFromSuperlayer];
		}
		
		if (self.smallControlView) {
			[self.smallControlView addControlBtn];
			NSLog(@"===============xxxxxxxxxxxxxxxxxxxxxxxxxxx");
		}
	}
	[self updateControlView];
}

- (void)setView {
	
	// 1. 播放控制
//	self.playControl = [UIButton buttonWithType:UIButtonTypeContactAdd];
//	self.playControl = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//	[self.playControl setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//	[self.playControl setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateHighlighted];
//	[self addSubview:self.playControl];
//	[self.playControl addTarget:self action:@selector(playCont) forControlEvents:UIControlEventTouchUpInside];
	
	// 2. 菊花
	self.activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
	[self addSubview:self.activity];
	
	//
	[self updateControlView];
}

- (void)updateControlView {
	
	self.activity.hidden = YES;
	self.playControl.hidden = YES;
	
	if (self.player.status != 1) {
		self.activity.hidden = NO;
		[self.activity startAnimating];
	} else if (self.player.status == 1) {
		
		if (self.player.rate == 0) {
			self.playControl.hidden = NO;
		} else {
			self.playControl.hidden = YES;
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.playControl.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
	self.activity.center	= CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
	self.appearBtn.center	= CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
	self.imageLayer.frame = self.bounds;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	self.smallControlView.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
	_title = title;
	if (self.smallControlView) {
		self.smallControlView.title = title;
	}
}

#pragma maek - Private Methond
- (void)addGesture {
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
																		  action:@selector(sreenControl)];
	tap.delegate = self;
	[self addGestureRecognizer:tap];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

	if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIImageView"]
		|| [NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]
		|| [NSStringFromClass([touch.view class]) isEqualToString:@"UISlider"]) {
		return NO;
	}
	return YES;
}

- (void)sreenControl {
	if (self.isAutoScreen || self.smallControlView.hidden) return;
	if (self.smallAppear) {
		[self smallControlDisAppear];
	} else {
		[self smallControlAppear];
	}
}

- (void)addControlView {
	
	self.smallControlView = ({
		JRControlView *control	= [[JRControlView alloc] initWithFrame:self.bounds];
		control.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
		control.alpha			= 0.0;
		control.player			= self;
		[self addSubview:control];
		control;
	});
}

- (void)smallControlAppear {
	if (self.smallControlView) {
		if (self.smallAppear == NO) {
			[UIView animateWithDuration:0.25 animations:^{
				self.smallControlView.alpha = 1.0;
			} completion:^(BOOL finished) {
				self.smallAppear = YES;
				
				[self addTimer];
			}];
		}
	}
}

- (void)smallControlDisAppear {
	if (self.smallControlView) {
		if (self.smallAppear == YES) {
			[self removeTimer];
			
			if (self.smallControlView.isShow) {
				__weak JRPlayerView *weekSelf = self;
				[self.smallControlView openSlidView:^{
					[UIView animateWithDuration:0.25 animations:^{
						weekSelf.smallControlView.alpha = 0.0;
					} completion:^(BOOL finished) {
						weekSelf.smallAppear = NO;
					}];
				}];
			} else {
				[UIView animateWithDuration:0.25 animations:^{
					self.smallControlView.alpha = 0.0;
				} completion:^(BOOL finished) {
					self.smallAppear = NO;
				}];
			}
			[self.smallControlView closeAllImgArray];
		}
	}
}

- (void)addTimer {
	self.closeTimer = [NSTimer timerWithTimeInterval:5
											  target:self
											selector:@selector(smallControlDisAppear)
											userInfo:nil
											 repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:self.closeTimer forMode:NSDefaultRunLoopMode];
}

- (void)removeTimer {
	if (self.closeTimer) {
		[self.closeTimer invalidate];
		self.closeTimer = nil;
	}
}

#pragma mark - THTransportDelegate Methods
- (void)playCont {
	
	if (self.player.rate == 0.0) {
		[self.player setRate:1.0];
	} else if (self.player.rate == 1.0) {
		[self.player setRate:0.0];
	}
	[self updateControlView];
}

- (void)play {
	[self.player play];
	NSLog(@"--------------------------------------------------------------------");
}

- (void)pause {
	[self.player pause];
}

- (void)dealloc {
	[self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH];
	[self.player removeObserver:self forKeyPath:RATE_KEYPATH];
}

+ (Class)layerClass {                                                       // 2
	return [AVPlayerLayer class];
}


@end
