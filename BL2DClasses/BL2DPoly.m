//
//  BL2DPoly.m
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

#import "BL2DPoly.h"

@interface BL2DPoly()
@end

@implementation BL2DPoly

@synthesize drawMode, useAlpha, useSmoothing, turtle;

#pragma mark - classy stuff

- (void) initialSetup
{
    vertexMesh = NULL;
    colorMesh = NULL;
    usedVerts = 0;
    useAlpha = NO;
    
    [self setTextSize:20.0];
    
    vertexMesh = (GLfloat *) calloc( maxVerts * 2, sizeof( GLfloat ));  // X,Y
    colorMesh = (GLubyte *) calloc( maxVerts * 4, sizeof( GLubyte ));   // R,G,B,A
    
    self.turtle = [[BL2DTurtle alloc] initWithRenderable:self];
    [self clearData];
}

- (id) initWithMaxVerts:(int)pMax
{
	self = [super init];
	if (self)
    {
        maxVerts = pMax;
        [self initialSetup];
        drawMode = GL_TRIANGLES;
	}
	return self;
}

- (id) initWithMaxVerts:(int)pMax withDrawMode:(GLenum)pMode
{
	self = [super init];
	if (self)
    {
        maxVerts = pMax;
        [self initialSetup];
        drawMode = pMode;
	}
	return self;
}



- (void)dealloc
{
    self.turtle = nil;
    
	if( vertexMesh ) free( vertexMesh );
	vertexMesh = NULL;
	
	if( colorMesh ) free( colorMesh );
	colorMesh = NULL;
	
	// not anymore [super dealloc];
}



#pragma mark - render routines

- (void) render
{
    if( !active ) return;
    if( usedVerts < 2 ) return;
    glDisable(GL_DEPTH_TEST);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(2, GL_FLOAT, 0, vertexMesh );
    glEnableClientState(GL_COLOR_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorMesh);
	
    if( useAlpha ) {
        glEnable(GL_BLEND);
        //	glBlendFunc (GL_ONE, GL_SRC_COLOR);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }

    if( useSmoothing ) {
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        glEnable(GL_LINE_SMOOTH);
    }
        
	glPushMatrix();
	glTranslatef( self.spx, self.spy, 0.0 );
    glScalef( scale, scale, 1.0 );
	glRotatef( angle, 0.0, 0.0, 1.0 );
	
	glDrawArrays(drawMode, 0, usedVerts);
    // ref: http://www3.ntu.edu.sg/home/ehchua/programming/opengl/images/GL_GeometricPrimitives.png
    // ref: http://www3.ntu.edu.sg/home/ehchua/programming/opengl/GL2_Graphics3D.html
    
    glPopMatrix();

	if( useAlpha ) {
        glDisable(GL_BLEND);
    }
    
    if( useSmoothing ) {
        glDisable(GL_LINE_SMOOTH);
        glDisable(GL_BLEND);
    }
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}


#pragma mark - utility
- (void)clearData
{
    usedVerts = 0;
    
    lastX = 0.0;
    lastY = 0.0;
    
    lastR = 0.0;
    lastG = 0.0;
    lastB = 0.0;
    
    // does not kill the buffers, just resets draw stuff.
    [self.turtle reset];
}


- (NSString *)description
{
	NSMutableString * str = [[NSMutableString alloc] init];
    [str appendFormat:@"%d of %d vertexen utilized.", usedVerts, maxVerts];
	return str;
}


#pragma mark - colors

- (void)setColorR:(unsigned char)pR G:(unsigned char)pG B:(unsigned char)pB
{
        // doesn't add a point or change the last point,
        // this sets for the next point(s) added.
    lastR = pR;
    lastG = pG;
    lastB = pB;
    lastA = 255;
}

- (void)setColorR:(unsigned char)pR G:(unsigned char)pG B:(unsigned char)pB A:(unsigned char )pA
{
    lastR = pR;
    lastG = pG;
    lastB = pB;
    lastA = pA;
}

- (void) setRandomColor
{
    [self setColorR:[self rand255] G:[self rand255] B:[self rand255] A:[self rand255]];
}


#pragma mark - points and polys

- (int)addX:(float)pX Y:(float)pY
{
    if( usedVerts >= maxVerts ) {
        //NSLog( @"ERROR: Adding more than %d verts!", maxVerts );
        //NSLog( @"You should fix this before deploying." );
        return 0;
    }
    
    int vindex = usedVerts*2;
    
    // set the points, and the "last" item for them.
    vertexMesh[vindex+0] = lastX = pX;
    vertexMesh[vindex+1] = lastY = pY;
    
    
    // set the colors
    int cindex = usedVerts*4;
    colorMesh[cindex+0] = lastR;
    colorMesh[cindex+1] = lastG;
    colorMesh[cindex+2] = lastB;
    colorMesh[cindex+3] = 255;      // Alpha
    
    // move on to the next one
    usedVerts ++;
    return 1;
}

- (int) repeatPoint
{
    return [self addX:lastX Y:lastY];
}

- (int) addRandomPointW:(float)pWidth H:(float)pHeight
{
    return [self addX:pWidth*[self randNormalized] Y:pHeight*[self randNormalized]];
}



#pragma mark - shapes

- (int) addLineX0:(float)x0 Y0:(float)y0  X1:(float)x1 Y1:(float)y1
{
    int r = 0;
    r += [self addX:x0 Y:y0];
    r += [self addX:x1 Y:y1];
    
    return r;
}

- (int) addTriangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2
{
    int r = 0;
    r += [self addX:x0 Y:y0];
    r += [self addX:x1 Y:y1];
    r += [self addX:x2 Y:y2];
    return r;
}

- (int) addRectangleX0:(float)x0 Y0:(float)y0  X1:(float)x1 Y1:(float)y1
{
    int r = 0;
    
    r+= [self addTriangleX0:x0 Y0:y0 X1:x0 Y1:y1 X2:x1 Y2:y1]; // not confusing at all!
    r+= [self addTriangleX0:x0 Y0:y0 X1:x1 Y1:y1 X2:x1 Y2:y0];
    return r;
}


#pragma mark - Vector Font

@synthesize textKern, textWidth, textHeight;

// NOTE:
//	I'm unhappy with square brackets []
//	also, curly brackets {} are the same as square brackets for now.

BL2DVectorFontLines __internalVectorFont[] = {
	/*   0 */ { 0 },
	/*   1 */ { 0 },
	/*   2 */ { 0 },
	/*   3 */ { 0 },
	/*   4 */ { 0 },
	/*   5 */ { 0 },
	/*   6 */ { 0 },
	/*   7 */ { 0 },
	/*   8 */ { 0 },
	/*   9 */ { 0 },
	/*  10 */ { 0 },
	/*  11 */ { 0 },
	/*  12 */ { 0 },
	/*  13 */ { 0 },
	/*  14 */ { 0 },
	/*  15 */ { 0 },
	/*  16 */ { 0 },
	/*  17 */ { 0 },
	/*  18 */ { 0 },
	/*  19 */ { 0 },
	/*  20 */ { 0 },
	/*  21 */ { 0 },
	/*  22 */ { 0 },
	/*  23 */ { 0 },
	/*  24 */ { 0 },
	/*  25 */ { 0 },
	/*  26 */ { 0 },
	/*  27 */ { 0 },
	/*  28 */ { 0 },
	/*  29 */ { 0 },
	/*  30 */ { 0 },
	/*  31 */ { 0 },
	/*  32 */ { 0 },
	/*  !  */ { 12, { 128.0, 170.0,  128.0, 0.0,  128.0, 0.0,  255.0, 0.0,  255.0, 0.0,  128.0, 170.0,  128.0, 228.0,  64.0, 255.0,  64.0, 255.0,  176.0, 255.0,  176.0, 255.0,  128.0, 228.0,   -1.0 } }, 
	/*  "  */ { 12, { 0.0, 0.0,  128.0, 0.0,  128.0, 0.0,  0.0, 86.0,  0.0, 86.0,  0.0, 0.0,  
        128.0, 0.0,  255, 0.0,  255, 0.0,  128.0, 86.0,  128.0, 86.0,  128.0, 0.0,-1.0 } },
	/*  #  */ { 8, { 64.0, 0.0,  64.0, 255.0,  192.0, 0.0,  192.0, 255.0,  0.0, 96.0,  255.0, 96.0,  0.0, 160.0,  255.0, 160.0,   -1.0 } }, 
	/*  $  */ { 12, { 255.0, 42.0,  0.0, 42.0,  0.0, 42.0,  0.0, 128.0,  0.0, 128.0,  255.0, 128.0,  255.0, 128.0,  255.0, 214.0,  255.0, 214.0,  0.0, 214.0,  128.0, 0.0,  128.0, 255.0,   -1.0 } }, 
	/*  %  */ { 18, { 0.0, 0.0,  96.0, 0.0,  96.0, 0.0,  96.0, 96.0,  96.0, 96.0,  0.0, 96.0,  0.0, 96.0,  0.0, 0.0,  255.0, 255.0,  160.0, 255.0,  160.0, 255.0,  160.0, 160.0,  160.0, 160.0,  255.0, 160.0,  255.0, 160.0,  255.0, 255.0,  255.0, 0.0,  0.0, 255.0,   -1.0 } }, 
	/*  &  */ { 12, { 255.0, 255.0,  0.0, 86.0,  0.0, 86.0,  128.0, 0.0,  128.0, 0.0,  255.0, 86.0,  255.0, 86.0,  0.0, 214.0,  0.0, 214.0,  128.0, 255.0,  128.0, 255.0,  176.0, 228.0,   -1.0 } }, 
	/*  '  */ { 6, { 0.0, 0.0,  128.0, 0.0,  128.0, 0.0,  0.0, 86.0,  0.0, 86.0,  0.0, 0.0,   -1.0 } }, 
	/*  (  */ { 6, { 64.0, 0.0,  0.0, 42.0,  0.0, 42.0,  0.0, 214.0,  0.0, 214.0,  64.0, 255.0,   -1.0 } }, 
	/*  )  */ { 6, { 176.0, 0.0,  255.0, 42.0,  255.0, 42.0,  255.0, 214.0,  255.0, 214.0,  176.0, 255.0,   -1.0 } }, 
	/*  *  */ { 4, { 176.0, 86.0,  64.0, 170.0,  64.0, 86.0,  176.0, 170.0,   -1.0 } }, 
	/*  +  */ { 4, { 136.0, 34.0,  136.0, 221.0,  0.0, 136.0,  255.0, 136.0,   -1.0 } }, 
	/*  ,  */ { 10, { 128.0, 214.0,  176.0, 228.0,  176.0, 228.0,  128.0, 255.0,  128.0, 255.0,  64.0, 255.0,  64.0, 255.0,  64.0, 228.0,  64.0, 228.0,  128.0, 214.0,   -1.0 } }, 
	/*  -  */ { 2, { 0.0, 128.0,  255.0, 128.0,   -1.0 } }, 
	/*  .  */ { 8, { 128.0, 214.0,  176.0, 228.0,  176.0, 228.0,  128.0, 255.0,  128.0, 255.0,  64.0, 228.0,  64.0, 228.0,  128.0, 214.0,   -1.0 } }, 
	/*  /  */ { 2, { 0.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  0  */ { 8, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,   -1.0 } }, 
	/*  1  */ { 2, { 128.0, 0.0,  128.0, 255.0,   -1.0 } }, 
	/*  2  */ { 10, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 128.0,  255.0, 128.0,  0.0, 128.0,  0.0, 128.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  3  */ { 8, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 128.0,  255.0, 128.0,   -1.0 } }, 
	/*  4  */ { 6, { 0.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 128.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  5  */ { 10, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 128.0,  255.0, 128.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,   -1.0 } }, 
	/*  6  */ { 8, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  255.0, 255.0,  255.0, 128.0,  255.0, 128.0,  0.0, 128.0,   -1.0 } }, 
	/*  7  */ { 4, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  8  */ { 14, { 255.0, 128.0,  255.0, 0.0,  255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 128.0,  255.0, 128.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 128.0,   -1.0 } }, 
	/*  9  */ { 8, { 255.0, 128.0,  0.0, 128.0,  0.0, 128.0,  0.0, 0.0,  0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  :  */ { 16, { 128.0, 0.0,  192.0, 42.0,  192.0, 42.0,  128.0, 86.0,  128.0, 86.0,  64.0, 42.0,  64.0, 42.0,  128.0, 0.0,  128.0, 171.0,  192.0, 213.0,  192.0, 213.0,  128.0, 252.0,  128.0, 252.0,  64.0, 213.0,  64.0, 213.0,  128.0, 171.0,   -1.0 } }, 
	/*  ;  */ { 18, { 128.0, 0.0,  192.0, 42.0,  192.0, 42.0,  128.0, 86.0,  128.0, 86.0,  64.0, 42.0,  64.0, 42.0,  128.0, 0.0,  128.0, 170.0,  192.0, 214.0,  192.0, 214.0,  128.0, 255.0,  128.0, 255.0,  64.0, 255.0,  64.0, 255.0,  64.0, 214.0,  64.0, 214.0,  128.0, 170.0,   -1.0 } }, 
	/*  <  */ { 4, {255, 0.0,  0, 128.0,  0,128.0, 255.0, 255.0} },
	/*  =  */ { 4, { 0.0, 86.0,  255.0, 86.0,  0.0, 170.0,  255.0, 170.0,   -1.0 } }, 
	/*  >  */ { 4, {0, 0,   255, 128,   255, 128, 0, 255 }},
	/*  ?  */ { 14, { 0.0, 42.0,  128.0, 0.0,  128.0, 0.0,  255.0, 42.0,  255.0, 42.0,  128.0, 128.0,  128.0, 128.0,  128.0, 170.0,  128.0, 214.0,  64.0, 255.0,  64.0, 255.0,  176.0, 255.0,  176.0, 255.0,  128.0, 214.0,   -1.0 } }, 
	/*  @  */ { 18, { 255.0, 255.0,  255.0, 0.0,  255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  255.0, 255.0,  176.0, 170.0,  176.0, 170.0,  176.0, 86.0,  176.0, 86.0,  64.0, 86.0,  64.0, 86.0,  64.0, 170.0,  64.0, 170.0,  176.0, 170.0,   -1.0 } }, 
	/*  A  */ { 10, { 0.0, 255.0,  0.0, 86.0,  0.0, 86.0,  128.0, 0.0,  128.0, 0.0,  255.0, 86.0,  255.0, 86.0,  255.0, 255.0,  0.0, 128.0,  255.0, 128.0,   -1.0 } }, 
	/*  B  */ { 18, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 86.0,  255.0, 86.0,  176.0, 128.0,  176.0, 128.0,  0.0, 128.0,  0.0, 128.0,  176.0, 128.0,  176.0, 128.0,  255.0, 170.0,  255.0, 170.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,   -1.0 } }, 
	/*  C  */ { 6, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  D  */ { 12, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  128.0, 0.0,  128.0, 0.0,  255.0, 42.0,  255.0, 42.0,  255.0, 214.0,  255.0, 214.0,  128.0, 255.0,  128.0, 255.0,  0.0, 255.0,   -1.0 } }, 
	/*  E  */ { 8, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  0.0, 128.0,  176.0, 128.0,   -1.0 } }, 
	/*  F  */ { 6, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 128.0,  176.0, 128.0,   -1.0 } }, 
	/*  G  */ { 12, { 255.0, 86.0,  255.0, 0.0,  255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  255.0, 255.0,  255.0, 170.0,  255.0, 170.0,  128.0, 170.0,   -1.0 } }, 
	/*  H  */ { 6, { 0.0, 0.0,  0.0, 255.0,  0.0, 128.0,  255.0, 128.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  I  */ { 6, { 0.0, 0.0,  255.0, 0.0,  128.0, 0.0,  128.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  J  */ { 8, { 0.0, 0.0,  255.0, 0.0,  176.0, 0.0,  176.0, 255.0,  176.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 214.0,   -1.0 } }, 
	/*  K  */ { 6, { 0.0, 0.0,  0.0, 255.0,  255.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 255.0,   -1.0 } }, 
	/*  L  */ { 4, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  M  */ { 8, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  128.0, 86.0,  128.0, 86.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  N  */ { 6, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  255.0, 255.0,  255.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  O  */ { 8, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,   -1.0 } }, 
	/*  P  */ { 8, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 128.0,  255.0, 128.0,  0.0, 128.0,   -1.0 } }, 
	/*  Q  */ { 12, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 214.0,  255.0, 214.0,  128.0, 255.0,  128.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,  128.0, 214.0,  255.0, 255.0,   -1.0 } }, 
	/*  R  */ { 10, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 128.0,  255.0, 128.0,  0.0, 128.0,  0.0, 128.0,  255.0, 255.0,   -1.0 } }, 
	/*  S  */ { 10, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 128.0,  255.0, 128.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,   -1.0 } }, 
	/*  T  */ { 4, { 0.0, 0.0,  255.0, 0.0,  128.0, 0.0,  128.0, 255.0,   -1.0 } }, 
	/*  U  */ { 6, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  255.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  V  */ { 4, { 0.0, 0.0,  128.0, 255.0,  128.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  W  */ { 8, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  128.0, 214.0,  128.0, 214.0,  255.0, 255.0,  255.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  X  */ { 4, { 0.0, 0.0,  255.0, 255.0,  255.0, 0.0,  0.0, 255.0,   -1.0 } }, 
	/*  Y  */ { 6, { 0.0, 0.0,  128.0, 86.0,  128.0, 86.0,  255.0, 0.0,  128.0, 86.0,  128.0, 255.0,   -1.0 } }, 
	/*  Z  */ { 6, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  [  */ { 6, { 64.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  64.0, 255.0,   -1.0 } }, 
	/*  \  */ { 2, { 255.0, 255.0,  0.0, 0.0,   -1.0 } }, 
	/*  ]  */ { 6, { 176.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,  255.0, 255.0,  176.0, 255.0,   -1.0 } }, 
	/*  ^  */ { 4, { 0.0, 86.0,  128.0, 0.0,  128.0, 0.0,  255.0, 86.0,   -1.0 } }, 
	/*  _  */ { 2, { 0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  `  */ { 6, { 0.0, 42.0,  128.0, 86.0,  128.0, 86.0,  144.0, 42.0,  144.0, 42.0,  64.0, 0.0,   -1.0 } }, 
	/*  a  */ { 10, { 0.0, 255.0,  0.0, 86.0,  0.0, 86.0,  128.0, 0.0,  128.0, 0.0,  255.0, 86.0,  255.0, 86.0,  255.0, 255.0,  0.0, 128.0,  255.0, 128.0,   -1.0 } }, 
	/*  b  */ { 18, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 86.0,  255.0, 86.0,  176.0, 128.0,  176.0, 128.0,  0.0, 128.0,  0.0, 128.0,  176.0, 128.0,  176.0, 128.0,  255.0, 170.0,  255.0, 170.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,   -1.0 } }, 
	/*  c  */ { 6, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  d  */ { 12, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  128.0, 0.0,  128.0, 0.0,  255.0, 42.0,  255.0, 42.0,  255.0, 214.0,  255.0, 214.0,  128.0, 255.0,  128.0, 255.0,  0.0, 255.0,   -1.0 } }, 
	/*  e  */ { 8, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  0.0, 128.0,  176.0, 128.0,   -1.0 } }, 
	/*  f  */ { 6, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 128.0,  176.0, 128.0,   -1.0 } }, 
	/*  g  */ { 12, { 255.0, 86.0,  255.0, 0.0,  255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  255.0, 255.0,  255.0, 170.0,  255.0, 170.0,  128.0, 170.0,   -1.0 } }, 
	/*  h  */ { 6, { 0.0, 0.0,  0.0, 255.0,  0.0, 128.0,  255.0, 128.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  i  */ { 6, { 0.0, 0.0,  255.0, 0.0,  128.0, 0.0,  128.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  j  */ { 8, { 0.0, 0.0,  255.0, 0.0,  176.0, 0.0,  176.0, 255.0,  176.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 214.0,   -1.0 } }, 
	/*  k  */ { 6, { 0.0, 0.0,  0.0, 255.0,  255.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 255.0,   -1.0 } }, 
	/*  l  */ { 4, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*  m  */ { 8, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  128.0, 86.0,  128.0, 86.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,   -1.0 } }, 
	/*  n  */ { 6, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  255.0, 255.0,  255.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  o  */ { 8, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,   -1.0 } }, 
	/*  p  */ { 8, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 128.0,  255.0, 128.0,  0.0, 128.0,   -1.0 } }, 
	/*  q  */ { 12, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 214.0,  255.0, 214.0,  128.0, 255.0,  128.0, 255.0,  0.0, 255.0,  0.0, 255.0,  0.0, 0.0,  128.0, 214.0,  255.0, 255.0,   -1.0 } }, 
	/*  r  */ { 10, { 0.0, 255.0,  0.0, 0.0,  0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 128.0,  255.0, 128.0,  0.0, 128.0,  0.0, 128.0,  255.0, 255.0,   -1.0 } }, 
	/*  s  */ { 10, { 255.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 128.0,  0.0, 128.0,  255.0, 128.0,  255.0, 128.0,  255.0, 255.0,  255.0, 255.0,  0.0, 255.0,   -1.0 } }, 
	/*  t  */ { 4, { 0.0, 0.0,  255.0, 0.0,  128.0, 0.0,  128.0, 255.0,   -1.0 } }, 
	/*  u  */ { 6, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,  255.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  v  */ { 4, { 0.0, 0.0,  128.0, 255.0,  128.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  w  */ { 8, { 0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  128.0, 214.0,  128.0, 214.0,  255.0, 255.0,  255.0, 255.0,  255.0, 0.0,   -1.0 } }, 
	/*  x  */ { 4, { 0.0, 0.0,  255.0, 255.0,  255.0, 0.0,  0.0, 255.0,   -1.0 } }, 
	/*  y  */ { 6, { 0.0, 0.0,  128.0, 86.0,  128.0, 86.0,  255.0, 0.0,  128.0, 86.0,  128.0, 255.0,   -1.0 } }, 
	/*  z  */ { 6, { 0.0, 0.0,  255.0, 0.0,  255.0, 0.0,  0.0, 255.0,  0.0, 255.0,  255.0, 255.0,   -1.0 } }, 
	/*HACK  {  */ { 6, { 64.0, 0.0,  0.0, 0.0,  0.0, 0.0,  0.0, 255.0,  0.0, 255.0,  64.0, 255.0,   -1.0 } },
	/*  |  */ { 2, { 128, 0, 128, 255 }},
	/*HACK  }  */ { 6, { 176.0, 0.0,  255.0, 0.0,  255.0, 0.0,  255.0, 255.0,  255.0, 255.0,  176.0, 255.0,   -1.0 } },
	/*  ~  */ { 6, { 0.0, 128.0,  64.0, 100.0,  64.0, 100.0,  176.0, 150.0,  176.0, 150.0,  255.0, 128.0,   -1.0 } }, 
	/* 127 */ { 0 },
	/* 128 */ { 0 },
	/* 129 */ { 0 },
	/* 130 */ { 0 },
	/* 131 */ { 0 },
	/* 132 */ { 0 },
	/* 133 */ { 0 },
	/* 134 */ { 0 },
	/* 135 */ { 0 },
	/* 136 */ { 0 },
	/* 137 */ { 0 },
	/* 138 */ { 0 },
	/* 139 */ { 0 },
	/* 140 */ { 0 },
	/* 141 */ { 0 },
	/* 142 */ { 0 },
	/* 143 */ { 0 },
	/* 144 */ { 0 },
	/* 145 */ { 0 },
	/* 146 */ { 0 },
	/* 147 */ { 0 },
	/* 148 */ { 0 },
	/* 149 */ { 0 },
	/* 150 */ { 0 },
	/* 151 */ { 0 },
	/* 152 */ { 0 },
	/* 153 */ { 0 },
	/* 154 */ { 0 },
	/* 155 */ { 0 },
	/* 156 */ { 0 },
	/* 157 */ { 0 },
	/* 158 */ { 0 },
	/* 159 */ { 0 },
	/* 160 */ { 0 },
	/* 161 */ { 0 },
	/* 162 */ { 0 },
	/* 163 */ { 0 },
	/* 164 */ { 0 },
	/* 165 */ { 0 },
	/* 166 */ { 0 },
	/* 167 */ { 0 },
	/* 168 */ { 0 },
	/* 169 */ { 0 },
	/* 170 */ { 0 },
	/* 171 */ { 0 },
	/* 172 */ { 0 },
	/* 173 */ { 0 },
	/* 174 */ { 0 },
	/* 175 */ { 0 },
	/* 176 */ { 0 },
	/* 177 */ { 0 },
	/* 178 */ { 0 },
	/* 179 */ { 0 },
	/* 180 */ { 0 },
	/* 181 */ { 0 },
	/* 182 */ { 0 },
	/* 183 */ { 0 },
	/* 184 */ { 0 },
	/* 185 */ { 0 },
	/* 186 */ { 0 },
	/* 187 */ { 0 },
	/* 188 */ { 0 },
	/* 189 */ { 0 },
	/* 190 */ { 0 },
	/* 191 */ { 0 },
	/* 192 */ { 0 },
	/* 193 */ { 0 },
	/* 194 */ { 0 },
	/* 195 */ { 0 },
	/* 196 */ { 0 },
	/* 197 */ { 0 },
	/* 198 */ { 0 },
	/* 199 */ { 0 },
	/* 200 */ { 0 },
	/* 201 */ { 0 },
	/* 202 */ { 0 },
	/* 203 */ { 0 },
	/* 204 */ { 0 },
	/* 205 */ { 0 },
	/* 206 */ { 0 },
	/* 207 */ { 0 },
	/* 208 */ { 0 },
	/* 209 */ { 0 },
	/* 210 */ { 0 },
	/* 211 */ { 0 },
	/* 212 */ { 0 },
	/* 213 */ { 0 },
	/* 214 */ { 0 },
	/* 215 */ { 0 },
	/* 216 */ { 0 },
	/* 217 */ { 0 },
	/* 218 */ { 0 },
	/* 219 */ { 0 },
	/* 220 */ { 0 },
	/* 221 */ { 0 },
	/* 222 */ { 0 },
	/* 223 */ { 0 },
	/* 224 */ { 0 },
	/* 225 */ { 0 },
	/* 226 */ { 0 },
	/* 227 */ { 0 },
	/* 228 */ { 0 },
	/* 229 */ { 0 },
	/* 230 */ { 0 },
	/* 231 */ { 0 },
	/* 232 */ { 0 },
	/* 233 */ { 0 },
	/* 234 */ { 0 },
	/* 235 */ { 0 },
	/* 236 */ { 0 },
	/* 237 */ { 0 },
	/* 238 */ { 0 },
	/* 239 */ { 0 },
	/* 240 */ { 0 },
	/* 241 */ { 0 },
	/* 242 */ { 0 },
	/* 243 */ { 0 },
	/* 244 */ { 0 },
	/* 245 */ { 0 },
	/* 246 */ { 0 },
	/* 247 */ { 0 },
	/* 248 */ { 0 },
	/* 249 */ { 0 },
	/* 250 */ { 6, { 0.0, 238.0,  136.0, 136.0,  136.0, 136.0,  255.0, 238.0,  255.0, 238.0,  0.0, 238.0,   -1.0 } }, 
	/* 251 */ { 6, { 255.0, 34.0,  102.0, 136.0,  102.0, 136.0,  255.0, 221.0,  255.0, 221.0,  255.0, 34.0,   -1.0 } }, 
	/* 252 */ { 6, { 0.0, 17.0,  136.0, 136.0,  136.0, 136.0,  255.0, 17.0,  255.0, 17.0,  0.0, 17.0,   -1.0 } }, 
	/* 253 */ { 6, { 0.0, 34.0,  187.0, 136.0,  187.0, 136.0,  0.0, 221.0,  0.0, 221.0,  0.0, 34.0,   -1.0 } }, 
	/* 254 */ { 0 },
};

BL2DVectorFontLines * theVectorFont = __internalVectorFont;


-(float) getTextSize
{
    return textHeight;
}

-(void) setTextSize:(float)ptSize
{
    textHeight = ptSize;
    textWidth = textHeight/2;
    textKern = textHeight/4;
}

-(int) addChar:(char)c atX:(float)px atY:(float)py
{
    int r = 0;
    int s = 0;
    int nIdx = __internalVectorFont[c].nIndicies;
    
    
    while( nIdx >= 2 ) {
        float x0 = px + ((__internalVectorFont[c].i[s++] / 255.0 ) * textWidth);
        float y0 = py + ((__internalVectorFont[c].i[s++] / 255.0 ) * textHeight);
        nIdx--;
        float x1 = px + ((__internalVectorFont[c].i[s++] / 255.0 ) * textWidth);
        float y1 = py + ((__internalVectorFont[c].i[s++] / 255.0 ) * textHeight);
        nIdx--;
        
        [self addLineX0:x0 Y0:y0 X1:x1 Y1:y1 ];
    }
    
    return r;
}

-(int) addText:(NSString *)txt atX:(float)px atY:(float)py
{
    float realX = px;
    int r = 0;
    
	for( int i=0 ; i< [txt length] ; i++ )
	{
		unichar ch = [txt characterAtIndex:i];
        r += [self addChar:ch atX:realX atY:py];
        realX += textWidth + textKern;
    }
    return r;
}

@end

