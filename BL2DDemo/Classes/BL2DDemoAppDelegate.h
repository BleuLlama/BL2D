//
//  BL2DDemoAppDelegate.h
//  BL2DDemo
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BL2DDemoViewController;

@interface BL2DDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BL2DDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BL2DDemoViewController *viewController;

@end

