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

@synthesize drawMode, useAlpha;

#pragma mark - classy stuff


- (id) initWithMaxVerts:(int)parammax
{
	self = [super init];
	if (self)
    {
		vertexMesh = NULL;
		colorMesh = NULL;
        maxVerts = parammax;
        usedVerts = 0;
        drawMode = GL_TRIANGLES;
        useAlpha = NO;
        
        vertexMesh = (GLfloat *) calloc( maxVerts * 2, sizeof( GLfloat ));  // X,Y
        colorMesh = (GLubyte *) calloc( maxVerts * 4, sizeof( GLubyte ));   // R,G,B,A
        
        [self clearData];
	}
	return self;
}



- (void)dealloc
{
	if( vertexMesh ) free( vertexMesh );
	vertexMesh = NULL;
	
	if( colorMesh ) free( colorMesh );
	colorMesh = NULL;
	
	[super dealloc];
}



#pragma mark - render routines

- (void) render
{
    if( usedVerts < 3 ) return;
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


@end

