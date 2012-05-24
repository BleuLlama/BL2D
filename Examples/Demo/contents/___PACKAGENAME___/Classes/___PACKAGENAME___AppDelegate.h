//
//  ___PACKAGENAME___AppDelegate.h
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ___PACKAGENAME___ViewController;

@interface ___PACKAGENAME___AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ___PACKAGENAME___ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ___PACKAGENAME___ViewController *viewController;

@end

