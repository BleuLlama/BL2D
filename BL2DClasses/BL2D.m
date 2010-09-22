//
//  BL2D.m
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

#import "BL2D.h"

@implementation BL2D

@synthesize txO, tyO, tsc;

- (id) init
{
	if ((self = [super init]))
	{
		interface = [[BLGLInterface alloc] init];
		[interface initGLWithWidth:320 andHeight:480];

		self.txO = 0.0;
		self.tyO = 0.0;
		self.tsc = 1.0;
	}
	return self;
}

- (void)dealloc
{
	[interface release];
	[super dealloc];
}

#pragma mark -
#pragma mark Graphics banks

- (void) loadGraphicsBank:(int)bnk withPng:(NSString *)fileInBundle
{
	// hardcode 2 banks for now.
	if( bnk == 0 ) {
		tileLayer = [interface addLayer:[interface loadTexture:fileInBundle]];
	} else if( bnk == 1 ) {
		spriteLayer = [interface addLayer:[interface loadTexture:fileInBundle]];
	}
}

#pragma mark -
#pragma mark render bits

- (void) renderFrameStart
{
	glClear(GL_COLOR_BUFFER_BIT);
}


#pragma mark -
#pragma mark Tilemap

- (void) renderTilemap:(int *)buffer xTiles:(int)xt yTiles:(int)yt usingOrdering:(int*)ordering
{
	// no proper tilemap stuff...
	// brute force placing/drawing each tile every frame
	
#define kSpriteSize 8
#define kFixedOffset 5
	int spriteIndex;
	
	for( unsigned int y=0 ; y<yt; y++ )
	{
		for( unsigned int x=0; x<xt ; x++ )
		{
			if( buffer == NULL ) {
				spriteIndex = rand()%256;
			} else {
				if( ordering == NULL ) {
					spriteIndex = buffer[ (y * xt) + x ];
				} else {
					spriteIndex = buffer[ ordering[ (y * xt) + x ]];
				}
			}
			
			[interface drawImage:tileLayer size:SIZE_8x8
						   frame:spriteIndex 
							   x:txO + kFixedOffset + (x * kSpriteSize * tsc)
							   y:tyO + kFixedOffset + (y * kSpriteSize * tsc)
						  hscale:tsc vscale:tsc angle:0.0 colour:NULL];
		}
	}
}


- (void) renderTilemap:(int *)buffer xTiles:(int)xt yTiles:(int)yt
{
	[self renderTilemap:buffer xTiles:xt yTiles:yt usingOrdering:NULL];
}


- (void) renderTilemapApply
{
	// i guess you'd ideally want to do all the updating & DrawImage()ing for tiles+sprites,
	// and then only do the Render()ing for both afterwards, so it all happens at once. 
	
	[interface render:tileLayer];
}

#pragma mark -
#pragma mark Sprites

// draw a sprite at a specific location
- (void) renderSprite:(int)spid x:(float)x y:(float)y
{
	[interface drawImage:spriteLayer size:SIZE_16x16 frame:spid
					   x:x y:y hscale:1.0 vscale:1.0 angle:0.0 colour:NULL];
}

- (void) renderSprite:(int)spid x:(float)x y:(float)y xFlip:(BOOL)xf yFlip:(BOOL)yf
{
	[interface drawImage:spriteLayer size:SIZE_16x16 frame:spid
					   x:x y:y hscale:xf?-1.0:1.0 vscale:yf?-1.0:1.0 angle:0.0 colour:NULL];
}

- (void) renderSpriteApply
{
	[interface render:spriteLayer];
}

@end
