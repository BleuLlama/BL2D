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
- (void) renderFrameStart;

// render a tilemap to the screen
- (void) renderTilemap:(int *)buffer xTiles:(int)xt yTiles:(int)yt;
- (void) renderTilemap:(int *)buffer xTiles:(int)xt yTiles:(int)yt usingOrdering:(int*)layout;

// apply the rendered tilemaps
- (void) renderTilemapApply;


// draw a sprite at a specific location
- (void) renderSprite:(int)spid x:(float)x y:(float)y;

// apply the rendered sprites
- (void) renderSpriteApply;
@end
