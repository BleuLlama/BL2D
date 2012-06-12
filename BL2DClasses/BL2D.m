//
//  BL2D.m
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

#import "BL2D.h"

@implementation BL2D

@synthesize renderLayers;

- (id) initWithEffectiveScreenWidth:(float)w Height:(float)h
{
	self = [super init];
	if (self)
    {
		screenW = w;
		screenH	= h;
		self.renderLayers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	self.renderLayers = nil;
	[super dealloc];
}

// load in a graphics source, returns a handle to the graphics
- (BL2DGraphics *) addPNGGraphics:(NSString *)filenameWithoutPNGExtenstion
						tilesWide:(int)acrs
						tilesHigh:(int)slurp
{
	BL2DGraphics * gfx = [[BL2DGraphics alloc] initWithPNG:filenameWithoutPNGExtenstion 
												 tilesWide:acrs
												 tilesHigh:slurp];
	
	return gfx;
}


- (BL2DGraphics *) addPlistGraphics:(NSString *)filenameWithoutPlistExtenstion
{
    BL2DGraphics * gfx  = [[BL2DGraphics alloc] initWithPlist:filenameWithoutPlistExtenstion];
    return gfx;
}

- (BL2DGraphics *) addRawGraphicsW:(int)w H:(int)h
{
    BL2DGraphics * gfx = [[BL2DGraphics alloc] initWithRawW:w H:h];
    return gfx;
}


- (BL2DTilemap *) addTilemapLayerUsingGraphics:(BL2DGraphics *)gfx
									 tilesWide:(int)w
									 tilesHigh:(int)h
{
	BL2DTilemap *tmap = [[BL2DTilemap alloc] initWithGraphics:gfx];
	[tmap setTilesWide:w tilesHigh:h];
	[self.renderLayers addObject:tmap];
	tmap.viewH = screenH;
	tmap.viewW = screenW;
	return tmap;
}

- (BL2DSprite *) addSprite:(BL2DGraphics *)gfx
{
	BL2DSprite *sp = [[BL2DSprite alloc] initWithGraphics:gfx];
	[self.renderLayers addObject:sp];
	sp.viewH = screenH;
	sp.viewW = screenW;
	return sp;
}

- (BL2DPoly *) addPoly:(int)maxVerts
{
    BL2DPoly * p = [[BL2DPoly alloc] initWithMaxVerts:maxVerts];
    [self.renderLayers addObject:p];
    return p;
}


- (BL2DPoly *) addPoly:(int)maxVerts withDrawMode:(GLenum)pMode
{
    BL2DPoly * p = [[BL2DPoly alloc] initWithMaxVerts:maxVerts withDrawMode:pMode];
    [self.renderLayers addObject:p];
    return p;
}

#pragma mark -
#pragma mark rendering

- (void) renderPrep
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof( 0.0f, screenW, screenH, 0.0f, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// just in case
	glDisable(GL_DEPTH_TEST);
}

- (void) renderStart
{
	glClear( GL_COLOR_BUFFER_BIT );
}

- (void) renderStuff
{
	[renderLayers makeObjectsPerformSelector:@selector( render ) withObject:self];
}

- (void) renderEnd
{
}

- (void) render
{
	[self renderPrep];
	[self renderStart];
	[self renderStuff];
	[self renderEnd];
}
@end
