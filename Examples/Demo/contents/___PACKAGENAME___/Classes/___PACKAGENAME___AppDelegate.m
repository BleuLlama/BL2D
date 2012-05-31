//
//  ___PACKAGENAME___AppDelegate.m
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010-2012 __MyCompanyName__. All rights reserved.
//

#import "___PACKAGENAME___AppDelegate.h"
#import "___PACKAGENAME___ViewController.h"

@implementation ___PACKAGENAME___AppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Compatibility for 3.x

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{        
    // Override point for customization after application launch.
	
    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
    return YES;
}


#pragma mark -
#pragma mark for 4.x

- (void)applicationWillResignActive:(UIApplication *)application
{
    [viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
