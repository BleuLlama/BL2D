//
//  BL2DRenderable.h
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

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "BL2DGraphics.h"

@interface BL2DRenderable:NSObject {
	GLfloat spx, spy;
	GLfloat scale;
	GLfloat angle;
	BOOL flipX;
	BOOL flipY;
	BOOL active;
	
	BL2DGraphics * gfx;	
	
	float viewW;
	float viewH;
}

@property (nonatomic) GLfloat spx;
@property (nonatomic) GLfloat spy;
@property (nonatomic) GLfloat scale;
@property (nonatomic) GLfloat angle;
@property (nonatomic) BOOL flipX;
@property (nonatomic) BOOL flipY;
@property (nonatomic) BOOL active;
@property (nonatomic) float viewW;
@property (nonatomic) float viewH;

- (id) initWithGraphics:(BL2DGraphics *)gfx;
- (void) render;

// some utility functions
- (void)srandNormal;
- (void)srandFixed;
- (float)randNormalized;
- (unsigned char)rand255;

@end
