//
//  AppDelegate.m
//  JR-Player
//
//  Created by 王潇 on 16/3/9.
//  Copyright © 2016年 王潇. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoaclViewController.h"
#import "LiveViewController.h"
#import "JRSoundView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[self setWindow];
	[JRSoundView sharedSoundView];
	return YES;
}

#pragma mark -
- (void)setWindow {
	self.window					= [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// 1.
	ViewController *viewVC		= [[ViewController alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewVC];
	
	// 2.
	LoaclViewController *localVC = [[LoaclViewController alloc] init];
	UINavigationController *locNav = [[UINavigationController alloc] initWithRootViewController:localVC];
	locNav.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:0];
	
	ViewController *netVC = [[ViewController alloc] init];
	UINavigationController *netNav = [[UINavigationController alloc] initWithRootViewController:netVC];
	netNav.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
	
	LiveViewController *livVC = [[LiveViewController alloc] init];
	UINavigationController *livNav = [[UINavigationController alloc] initWithRootViewController:livVC];
	livNav.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:2];
	
	UITabBarController *tabController = [[UITabBarController alloc] init];
//	tabController.childViewControllers = @[locNav, netNav, livNav];
	[tabController setViewControllers:@[locNav, netNav, livNav]];
//	[tabController addChildViewController:locNav];
//	[tabController addChildViewController:netNav];
//	[tabController addChildViewController:livNav];
	
	self.window.rootViewController = tabController;
	[self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

