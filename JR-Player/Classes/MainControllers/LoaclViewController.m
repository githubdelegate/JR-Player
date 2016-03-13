//
//  LoaclViewController.m
//  JR-Player
//
//  Created by 王潇 on 16/3/13.
//  Copyright © 2016年 王潇. All rights reserved.
//

#import "LoaclViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PlayerViewController.h"

@interface LoaclViewController () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray	*localVideos;
@property (nonatomic, strong) UITableView		*tableView;
@property (nonatomic, assign) BOOL				isFirst;
@end

@implementation LoaclViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setUpView];
	[self loadLocalVideos];
}

- (void)loadLocalVideos {
	
	self.localVideos = [[NSMutableArray alloc] init];
	dispatch_async(dispatch_get_main_queue(), ^{
		
		@autoreleasepool {
			ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){

				if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
					
				}else{
					[self showAlert];
					NSLog(@"相册访问失败.");
				}
			};
			
			ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
	
				if (result != NULL) {
					
					if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
						
						NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url

						NSDictionary *video = @{
												@"title":[result defaultRepresentation].filename,
												@"video":[NSURL URLWithString:urlstr],
												@"image":@"",
												@"duration" : [result valueForProperty:ALAssetPropertyDuration]
												};
						
						[self.localVideos addObject:video];
						[self.tableView reloadData];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// 取消
	if (buttonIndex == 0) {
		
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		// 设置
		NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		if([[UIApplication sharedApplication] canOpenURL:url]) {
			 NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
			[[UIApplication sharedApplication] openURL:url];
		}
	}
}

#pragma mark -
- (void)setUpView {
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.title = @"本地视频";
	self.tableView = ({
		UITableView *tableView	= [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
		tableView.delegate		= self;
		tableView.dataSource	= self;
		tableView;
	});
	[self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.localVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	}
	
	cell.textLabel.text			= self.localVideos[indexPath.row][@"title"];
	CGFloat time				= [self.localVideos[indexPath.row][@"duration"] floatValue];
	cell.detailTextLabel.text	= [self calcSeconds:time];

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	PlayerViewController *player = [[PlayerViewController alloc] init];
	player.video = self.localVideos[indexPath.row];
	NSLog(@"====== %@", self.localVideos[indexPath.row]);
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
	[self examineAtionStatus];
	self.navigationController.navigationBar.alpha = 1.0;
}

#pragma mark - Private Methond
- (NSString *)calcSeconds:(CGFloat)seconds {
	
	NSInteger hour = seconds / 3600;
	NSInteger time = (NSInteger)seconds % 3600;
	NSInteger min  = (NSInteger)time / 60;
	NSInteger sec  = time % 60;
	return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)min, (long)sec];
}

- (BOOL)examineAtionStatus {
//	AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
	ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
	if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
		
		if (self.isFirst) {
			[self showAlert];
		}
		return NO;
	}
	
	return YES;
}

- (void)showAlert {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相册访问失败"
													message:@"无法访问相册.请在'设置->定位服务'设置为打开状态."
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:@"设置", nil];
	[alert show];
	self.isFirst = YES;
}

@end
