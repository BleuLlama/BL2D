//
//  BL2DDemoViewController.h
//  BL2DDemo
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "BL2D.h"

@interface BL2DDemoViewController : UIViewController
{
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    /*
	 Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	 CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	 The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
	 */
    id displayLink;
    NSTimer *animationTimer;
	
	// BL2D stuff
	BL2D * bl2de;
	BL2DGraphics * tilegfx;
	BL2DGraphics * spritegfx;
	
	BL2DTilemap * backgroundTiles;
	BL2DTilemap * backgroundTiles2;
	BL2DSprite * sprite0;
	BL2DSprite * sprite1;
	BL2DSprite * sprite2;
	BL2DSprite * sprite3;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (nonatomic, retain) BL2DGraphics * tilegfx;
@property (nonatomic, retain) BL2DGraphics * spritegfx;
@property (nonatomic, retain) BL2DTilemap * backgroundTiles;
@property (nonatomic, retain) BL2DTilemap * backgroundTiles2;
@property (nonatomic, retain) BL2DSprite * sprite0;
@property (nonatomic, retain) BL2DSprite * sprite1;
@property (nonatomic, retain) BL2DSprite * sprite2;
@property (nonatomic, retain) BL2DSprite * sprite3;

- (void)startAnimation;
- (void)stopAnimation;

@end
