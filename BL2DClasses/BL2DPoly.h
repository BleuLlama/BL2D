//
//  BL2DPoly.h
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

#import "BL2DRenderable.h"

// the basic unit of measure for this is a single triangle.
// in the future, this will be settable as triangle, lines, triangle strip, points. etc.

@interface BL2DPoly: BL2DRenderable {
    int maxVerts;
	GLfloat * vertexMesh;
	GLubyte * colorMesh;
    int usedVerts;
    
    float lastX,lastY;
    unsigned char lastR,lastG,lastB,lastA;
    
    bool useAlpha;
}

@property (nonatomic, assign) bool useAlpha;

- (id) initWithMaxVerts:(int)max;

// "primitives"
- (void) clearData;

// doesn't add a point or change the last point,
// this sets for the next point(s) added. [0..255]
- (void) setColorR:(unsigned char)pR G:(unsigned char)pG B:(unsigned char)pB;
- (void) setColorR:(unsigned char)pR G:(unsigned char)pG B:(unsigned char)pB A:(unsigned char)pA;
- (void) setRandomColor;

- (void) setX:(float)pX Y:(float)pY;
- (void) setRandomPointW:(float)pWidth H:(float)pHeight;
- (void) repeatPoint;

@end
