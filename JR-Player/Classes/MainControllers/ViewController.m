//
//  ViewController.m
//  JR-Player
//
//  Created by 王潇 on 16/3/9.
//  Copyright © 2016年 王潇. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView	*tableView;
@property (nonatomic, strong) NSArray		*dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setUpView];
}

#pragma mark - Private Methond
- (void)setUpView {
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.tableView = ({
		UITableView *tableView	= [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
		tableView.delegate		= self;
		tableView.dataSource	= self;
		tableView;
	});
	[self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
	cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	PlayerViewController *player = [[PlayerViewController alloc] init];
	player.video = self.dataSource[indexPath.row];
	[self.navigationController pushViewController:player animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 0.1;
}

#pragma mark - Controller Methond
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	self.navigationController.navigationBar.alpha = 0.1;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.navigationController.navigationBar.alpha = 1.0;
}

#pragma mark - Lazy loading
- (NSArray *)dataSource {
	if (_dataSource) {
		return _dataSource;
	}

	_dataSource = @[
					@{@"title":@"了不起的盖茨商业王国(上)",
					  @"video":[NSURL URLWithString:@"http://220.189.221.179/6771B63CE113D82DF2A5B64C42/030008020056D852362B671AE3FD7216AF3C83-49E5-5B29-4869-047F0AEEF5F7.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=100&ts_keyframe=1"]},
					
					@{@"title":@"了不起的盖茨商业王国(下)",
					  @"video":[NSURL URLWithString:@"http://221.228.249.78/6972915A9C5478404CA30E3C3E/030008020156D852362B671AE3FD7216AF3C83-49E5-5B29-4869-047F0AEEF5F7.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=100&ts_keyframe=2"]},
					
					@{@"title":@"马云放大招玩黑科技(上)",
					  @"video":[NSURL URLWithString:@"http://59.63.177.108/6771A30AE6B317D19D0E64C4F/030008020056CDDDEAFD951AE3FD720610C41E-561E-5E98-4477-6ED9D80767CA.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=7&ts_keyframe=1"]},
					
					@{@"title":@"马云放大招玩黑科技(下)",
					  @"video":[NSURL URLWithString:@"http://59.63.177.42/65715D337A644812494CFC215D/030008020156CDDDEAFD951AE3FD720610C41E-561E-5E98-4477-6ED9D80767CA.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=56&ts_keyframe=1"]},
					
					@{@"title":@"俄罗斯重启载人登月计划(上)",
					  @"video":[NSURL URLWithString:@"http://222.73.61.236/657296C891C398115F850F6456/030008020056B39847C93D1AE3FD7272685779-4941-4A65-A274-FDDAA868E524.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=6&ts_keyframe=1"]},
					
					@{@"title":@"俄罗斯重启载人登月计划(下)",
					  @"video":[NSURL URLWithString:@"http://59.63.171.71/65733C7ACF43A7F8D49D72FDE/030008020156B39847C93D1AE3FD7272685779-4941-4A65-A274-FDDAA868E524.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=31&ts_keyframe=1"]},
					
					@{@"title":@"寻找太阳系第九大行星(上)",
					  @"video":[NSURL URLWithString:@"http://180.96.9.242/6774F014EC636815297FC05E34/030008020056B20C3681B51AE3FD72FDA0ABF0-297E-9E88-CF54-40FFC32DF8DB.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=13&ts_keyframe=1"]},
					
					@{@"title":@"寻找太阳系第九大行星(下)",
					  @"video":[NSURL URLWithString:@"http://61.160.227.24/6775C2C240A4982EFCB1BF3574/030008020156B20C3681B51AE3FD72FDA0ABF0-297E-9E88-CF54-40FFC32DF8DB.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=51&ts_keyframe=1"]},
					
					@{@"title":@"这位科技神童了不得(上)",
					  @"video":[NSURL URLWithString:@"http://222.73.61.234/6572FD889FE4A816A5A8546390/030008020056A8E5A3629B1AE3FD72DB902511-2505-B485-BB61-1D529E46A40E.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=9&ts_keyframe=1"]},
					
					@{@"title":@"这位科技神童了不得(下)",
					  @"video":[NSURL URLWithString:@"http://222.73.245.176/67753BAE4CB43814A918CB23A5/030008020156A8E5A3629B1AE3FD72DB902511-2505-B485-BB61-1D529E46A40E.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=37&ts_keyframe=1"]},
					
					@{@"title":@"硅谷群雄录 杰克·多西(上)",
					  @"video":[NSURL URLWithString:@"http://180.96.9.237/6973E7B0D8042819F4190142AE/030008030056A0EFDA673C1AE3FD7286800142-7DC0-630D-7864-D5BB30CB5457.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=15&ts_keyframe=1"]},
					
					@{@"title":@"硅谷群雄录 杰克·多西(下)",
					  @"video":[NSURL URLWithString:@"http://202.102.93.180/67736ABA95D318145A1E6C4658/030008030156A0EFDA673C1AE3FD7286800142-7DC0-630D-7864-D5BB30CB5457.mp4.ts?ts_start=0&ts_end=0&ts_seg_no=62&ts_keyframe=1"]},
					
					@{@"title":@"AAAAAAAA",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/14562919706254.mp4"]},
	  
					@{@"title":@"BBBBBBB",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4"]},
	  
					@{@"title":@"CCCCCC",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/14525705791193.mp4"]},
	  
					@{@"title":@"DDDDD",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4"]},
	  
					@{@"title":@"EEEEEE",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1455968234865481297704.mp4"]},
	  
					@{@"title":@"别跑，FFFFF",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1455782903700jy.mp4"]},
	  
					@{@"title":@"别跑GGGGGG",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/14564977406580.mp4"]},
					
					];
	
	return _dataSource;
}

// 哪些页面支持自动转屏
- (BOOL)shouldAutorotate{
	return NO;
}

//当前viewcontroller支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

@end
