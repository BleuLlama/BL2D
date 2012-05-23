//
//  BL2DTilemap.h
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
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "BL2DRenderable.h"
#import "BL2DGraphics.h"

@interface BL2DTilemap: BL2DRenderable {
	int * tilesBuffer;
	GLfloat * screenMesh;
	GLfloat * texturePoints;
	BOOL fillScreen;
	
	int nWide;
	int nHigh;
}
@property BOOL fillScreen;

- (id) initWithGraphics:(BL2DGraphics *)gfx;

- (void) setTilesWide:(int)w tilesHigh:(int)h;

// change tiles (one at a time)
- (int) width;
- (int) height;

- (void) setCharacterAtX:(int)x atY:(int)y to:(int)value;
- (int) getCharacterAtX:(int)x atY:(int)y;
- (void) commitChanges;

// change in bulk
- (void) copyNewTilesBuffer:(int *)newBuffer;
- (void) copyNewTilesBufferU8:(unsigned char *)newBuffer;

// random
- (void) fillWithRandom;
@end
