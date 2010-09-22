//
//  BL2D.h
//  Basic2DEngine
//
//  Copyright 2010 Scott Lawrence. All rights reserved.
//

/*
 Copyright (c) 2010 Scott Lawrence
 
 (MIT License)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */ 

#import <Foundation/Foundation.h>
#import "BLGLInterface.h"


#define kMaxTileLayers	(8)
#define kMaxSprites		(32)

// Version 1: Two banks
// bank 0 is 8x8 tiles for the tilemap, stored in a 256x256 png
// bank 1 is 16x16 tiles for the sprites, stored in a 256x256 png
// future versions may have arbitrary banks of graphics


@interface BL2D : NSObject {
	BLGLInterface* interface;
	unsigned int tileLayer;
	unsigned int spriteLayer;
	
	float txO;	// tilemap position on screen X
	float tyO;	// tilemap position on screen Y
	float tsc;	// tilemap scale
}

@property (nonatomic) float txO;
@property (nonatomic) float tyO;
@property (nonatomic) float tsc;


// Version 1: Two banks
// bank 0 is 8x8 tiles for the tilemap, stored in a 256x256 png
// bank 1 is 16x16 tiles for the sprites, stored in a 256x256 png

- (id) init;

- (void) loadGraphicsBank:(int)bnk withPng:(NSString *)fileInBundle;
#define kGraphicsBank_Tilemap	(0)
#define kGraphicsBank_Sprite	(1)

// start rendering a frame (just screen clear for now)
// do this first before any of the other things below
- (void) renderFrameStart;

// render a tilemap to the screen
// buffer points to an array of ints containing xt*yt values.
- (void) renderTilemap:(int *)buffer xTiles:(int)xt yTiles:(int)yt;

// the Ordering parameter is an offset layout array of ints that specify,
// for each X,Y position, the index into the buffer to pull from
// this is handy for rendering tilemaps that have non-contiguous or oddly 
// ordered content in memory.  (for example, Pac-Man arcade video is the right
// column, top to bottom, then the second column from the right, etc.
- (void) renderTilemap:(int *)buffer xTiles:(int)xt yTiles:(int)yt usingOrdering:(int*)layout;


// apply the rendered tilemaps 
//  - this actually forces the tilemaps to be rendered to the video buffer
- (void) renderTilemapApply;


// draw a sprite at a specific location
- (void) renderSprite:(int)spid x:(float)x y:(float)y;

// draw a sprite but optionally flip it along the X or Y axis
- (void) renderSprite:(int)spid x:(float)x y:(float)y xFlip:(BOOL)xf yFlip:(BOOL)yf;

// apply the rendered sprites
//  - this actually forces the sprites to be rendered to the video buffer
- (void) renderSpriteApply;
@end
