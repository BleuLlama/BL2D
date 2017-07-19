//
//  ViewController.h
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 7/14/17.
//  Copyright © 2017 Scott Lawrence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BL2D.h"

@interface ViewController : UIViewController
{
    GLuint program;
    
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    /*
     Use of the CADisplayLink class is the preferred method for controlling your animation timing.
     CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
     The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
     */
    id displayLink;
    NSTimer *animationTimer;
    
    bool isRetina;
    bool isPad;
    
    
    long startTime;
    long frameCount;
    IBOutlet UILabel * fpsLabel;
    
    int playState;
}


@property (strong, nonatomic) IBOutlet UILabel *statusText;

@property (nonatomic, retain) EAGLContext *context;


@property (nonatomic, assign) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

    // BL2D stuff

@property (nonatomic, retain) BL2D * bl2de;
@property (nonatomic, retain) BL2DGraphics * tilegfx;
@property (nonatomic, retain) BL2DGraphics * spritegfx;
@property (nonatomic, retain) BL2DGraphics * builtgfx;
@property (nonatomic, retain) BL2DGraphics * rawgfx;

@property (nonatomic, retain) BL2DTilemap * backgroundTiles;
@property (nonatomic, retain) BL2DTilemap * backgroundTiles2;
@property (nonatomic, retain) BL2DSprite * raw;
@property (nonatomic, retain) BL2DSprite * sprite0;
@property (nonatomic, retain) BL2DSprite * sprite1;
@property (nonatomic, retain) BL2DSprite * sprite2;
@property (nonatomic, retain) BL2DSprite * sprite3;

@property (nonatomic, retain) BL2DPoly * poly0; // triangles
@property (nonatomic, retain) BL2DPoly * poly1; // lines

- (void)startAnimation;
- (void)stopAnimation;

@end

