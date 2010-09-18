//
//  BL2D.h
//  Basic2DEngine
//
//  Copyright 2010 Scott Lawrence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLGLInterface.h"

// just make this opaque from here to eliminate the necessity to remove 
// the requirement that things that include this file be obj-c++


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
