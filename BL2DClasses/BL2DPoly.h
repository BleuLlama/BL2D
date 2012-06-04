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
#import "BL2DTurtle.h"

// the basic unit of measure for this is a single triangle.
// in the future, this will be settable as triangle, lines, triangle strip, points. etc.

@interface BL2DPoly: BL2DRenderable {
    int maxVerts;
	GLfloat * vertexMesh;
	GLubyte * colorMesh;
    int usedVerts;
    
    GLenum drawMode;
    
    float lastX,lastY;
    unsigned char lastR,lastG,lastB,lastA;
    
    BL2DTurtle * turtle;
    
    bool useAlpha;
    
    // for text
    float textKern;     // 255.0 = one 'em' (default is 32.0) (additional space between chars)
    float textWidth;    // (default is 10.0)
    float textHeight;   // (default is 20.0)
}

@property (nonatomic, assign) GLenum drawMode;
@property (nonatomic, assign) bool useAlpha;
@property (nonatomic, assign) float textKern;
@property (nonatomic, assign) float textWidth;
@property (nonatomic, assign) float textHeight;
@property (nonatomic, retain) BL2DTurtle * turtle;

- (id) initWithMaxVerts:(int)max;
- (id) initWithMaxVerts:(int)max withDrawMode:(GLenum)pMode;


// "primitives"
- (void) clearData;

#pragma mark - colors

// doesn't add a point or change the last point,
// this sets for the next point(s) added. [0..255]
- (void) setColorR:(unsigned char)pR G:(unsigned char)pG B:(unsigned char)pB;
- (void) setColorR:(unsigned char)pR G:(unsigned char)pG B:(unsigned char)pB A:(unsigned char)pA;
- (void) setRandomColor;

#pragma mark - points and polys
- (int) addX:(float)pX Y:(float)pY;
- (int) addRandomPointW:(float)pWidth H:(float)pHeight;
- (int) repeatPoint;

#pragma mark - shapes
- (int) addLineX0:(float)x0 Y0:(float)y0  X1:(float)x1 Y1:(float)y1;
- (int) addTriangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2;
- (int) addRectangleX0:(float)x0 Y0:(float)y0  X1:(float)x1 Y1:(float)y1;

#pragma mark - vectorfont
typedef struct BL2DVectorFontLines
{
    int nIndicies;
    GLfloat i[40];
} BL2DVectorFontLines;

extern BL2DVectorFontLines * theVectorFont;
-(int) addChar:(char)c atX:(float)px atY:(float)py;
-(int) addText:(NSString *)txt atX:(float)px atY:(float)py;
-(float) getTextSize;
-(void) setTextSize:(float)ptSize;


#pragma mark - turtle

@end
