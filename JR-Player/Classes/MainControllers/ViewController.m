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
	
	self.title = @"视频列表";
	
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
					
					@{@"title":@"视频一",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/14562919706254.mp4"]},
	  
					@{@"title":@"视频二",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4"]},
	  
					@{@"title":@"视频三",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/14525705791193.mp4"]},
	  
					@{@"title":@"视频四",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4"]},
	  
					@{@"title":@"视频五",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1455968234865481297704.mp4"]},
	  
					@{@"title":@"视频六",
					  @"image":@"http://wimg.spriteapp.cn/picture/2016/0309/56df7b64b4416_wpd.jpg",
					  @"video":[NSURL URLWithString:@"http://baobab.wdjcdn.com/1455782903700jy.mp4"]},
	  
					@{@"title":@"视频七",
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
