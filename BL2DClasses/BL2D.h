//
//  BL2D.h
//  Basic2DEngine
//
//  Copyright 2010-2012 Scott Lawrence. All rights reserved.
//

/*
 Copyright (c) 2010-2012 Scott Lawrence
 
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

/*
 Basic architecture:
 
 This file contains the wrappers you'll usually use.
 Use this to load graphics, initialize tilemaps and sprites.
 It's your responsibility to store aside the pointers to these to change them
 You also will be able to render from this class
 
 This will instantiate BL2DGraphics objects containing info about the GL Texturemaps
 This will instantiate BL2DSprite objects to manage/render sprites
 This will instantiate BL2DTilemap objects to manage/render tilemaps
 This will instantiate BL2DPoly objects to manage/render nontextured triangles or lines
 
 Sprite and Tilemaps both implement BL2DRenderable, (adding -render; )
 
 A Sprite or a Tilemap can only reference one graphic (could be the same one)
 
 Layers will be drawn in the order they're allocated. (via BL2D:render)
 */

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "BL2DRenderable.h"

#import "BL2DGraphics.h"
#import "BL2DSprite.h"
#import "BL2DTilemap.h"
#import "BL2DPoly.h"


@interface BL2D : NSObject {
	NSMutableArray * renderLayers;
	float  screenW, screenH;
}
@property (nonatomic, retain) NSMutableArray * renderLayers;

- (id) initWithEffectiveScreenWidth:(float)w Height:(float)h;

////////////////////////////////////////////

// load in a graphics source, returns a handle to the graphics
- (BL2DGraphics *) addPNGGraphics:(NSString *)filenameWithoutPNGExtenstion tilesWide:(int)acrs tilesHigh:(int)slurp;
- (BL2DGraphics *) addPlistGraphics:(NSString *)filenameWithoutPlistExtenstion;

- (BL2DGraphics *) addRawGraphicsW:(int)w H:(int)h;

- (BL2DTilemap *) addTilemapLayerUsingGraphics:(BL2DGraphics *)gfx 
									 tilesWide:(int)w 
									 tilesHigh:(int)h;

- (BL2DSprite *) addSprite:(BL2DGraphics *)gfx;

- (BL2DPoly *) addPoly:(int)maxVerts;
- (BL2DPoly *) addPoly:(int)maxVerts withDrawMode:(GLenum)pMode;

////////////////////////////////////////////

- (void) renderPrep;	// per-frame prep
- (void) renderStart;	// sets up GL stuff (clear screen - optional)
- (void) renderStuff;	// draws all of the stuff
- (void) renderEnd;		// ends the GL stuff

- (void) render;		// calls the above four, for simplicity
@end
