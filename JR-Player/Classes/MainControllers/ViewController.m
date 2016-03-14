//
//  ViewController.m
//  JR-Player
//
//  Created by 王潇 on 16/3/9.
//  Copyright © 2016年 王潇. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LoaclViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView		*tableView;
@property (nonatomic, strong) NSArray			*dataSource;
@property (nonatomic, strong) NSMutableArray	*images;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setUpView];
}

#pragma mark - Private Methond
- (void)setUpView {
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.title = @"网络视频";
	
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

#pragma mark - Load Source
- (void)loadSource {
	
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	
	[library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
						   usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
							   [group setAssetsFilter:[ALAssetsFilter allVideos]];
							   
							   [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0]
													   options:0
													usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
														
														if (result) {
//															NSLog(@"======= %@", result);
															id representation = [result defaultRepresentation];
															NSURL *url = [representation url];
															AVAsset *asset = [AVAsset assetWithURL:url];
															
															NSLog(@"url: %@", url);
														}
													}];
						   } failureBlock:^(NSError *error) {
							   NSLog(@"error: %@", error);
						   }];
	
}

//获取相册的所有图片
- (void)reloadImagesFromLibrary {
	self.images = [[NSMutableArray alloc] init];
	dispatch_async(dispatch_get_main_queue(), ^{
		
		@autoreleasepool {
			ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
				NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
				if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
					NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
				}else{
					NSLog(@"相册访问失败.");
				}
			};
			
			ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
				
				NSLog(@"============ %@", result);
				if (result != NULL) {
					
					if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
						
						NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
						[self.images addObject:urlstr];
						//NSLog(@"urlStr is %@",urlstr);
						/*result.defaultRepresentation.fullScreenImage//图片的大图
						 result.thumbnail                             //图片的缩略图小图
						 //                    NSRange range1=[urlstr rangeOfString:@"id="];
						 //                    NSString *resultName=[urlstr substringFromIndex:range1.location+3];
						 //                    resultName=[resultName stringByReplacingOccurrencesOfString:@"&ext=" withString:@"."];//格式demo:123456.png
						 */
						
						NSLog(@"----- %@", [result valueForProperty:ALAssetPropertyRepresentations]);
						NSLog(@"AAA----- %@", [result valueForProperty:ALAssetPropertyDuration]);
						NSLog(@"----- %@", [result valueForProperty:ALAssetPropertyOrientation]);
						NSLog(@"name----- %@", [result valueForProperty:ALAssetsGroupPropertyPersistentID]);
						NSLog(@"===== %@", [result defaultRepresentation].filename);
					}
				}
			};
			
			ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
				
				if (group == nil) {
					
				}
				
				if (group!=nil) {
					[group setAssetsFilter:[ALAssetsFilter allVideos]];
					NSString *g = [NSString stringWithFormat:@"%@",group];//获取相簿的组
					NSLog(@"gg:%@",g);	//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
					
					NSString *g1 = [g substringFromIndex:16 ] ;
					NSArray *arr = [[NSArray alloc] init];
					arr			 = [g1 componentsSeparatedByString:@","];
					NSString *g2 = [[arr objectAtIndex:0] substringFromIndex:5];
					
					if ([g2 isEqualToString:@"Camera Roll"]) {
						g2=@"相机胶卷";
					}
					NSString *groupName=g2;//组的name
					
					NSLog(@"g1 --- %@", g1);
					NSLog(@"g2 --- %@", g2);
					NSLog(@"gg === %@", [group valueForProperty:ALAssetsGroupPropertyName]);
					[group enumerateAssetsUsingBlock:groupEnumerAtion];
				}
			};
			
			ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
			[library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
								   usingBlock:libraryGroupsEnumeration
								 failureBlock:failureblock];
		}
		
	});
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
	player.hidesBottomBarWhenPushed = YES;
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
