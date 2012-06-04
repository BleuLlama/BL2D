//
//  BL2DRenderable.m
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

#import "BL2DRenderable.h"

@interface BL2DRenderable()
@end

@implementation BL2DRenderable

@synthesize spx, spy, angle, scale, flipX, flipY, viewW, viewH, active;
//@synthesize turtle;

#pragma mark -
#pragma mark classy stuff

- (id) initWithGraphics:(BL2DGraphics *)paramgfx
{
	self = [super init];
	if (self)
    {
		gfx = paramgfx;
		self.spx = 0.0;
		self.spy = 0.0;
		self.scale = 1.0;
		self.angle = 0.0;
		self.active = NO;
        [self srandNormal];
//        self.turtle = [[BL2DTurtle alloc] initWithRenderable:self];
	}
	return self;
}

- (id) init
{
	self = [super init];
	if (self)
    {
		self.spx = 0.0;
		self.spy = 0.0;
		self.scale = 1.0;
		self.angle = 0.0;
		self.active = NO;
        [self srandNormal];
//        self.turtle = [[BL2DTurtle alloc] initWithRenderable:self];
	}
	return self;
}

- (void)dealloc
{
//    self.turtle = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark the important stuff

- (void) render
{
	if( !self.active  || !gfx ) return;
	
	glPushMatrix();
	glTranslatef( self.spx, self.spy, 0.0 );
	glScalef( scale, scale, 1.0 );
	glRotatef( angle, 0.0, 0.0, 1.0 );
	[gfx renderSingle:-1 flipX:self.flipX flipY:self.flipY];
	glPopMatrix();
}

#pragma mark - random stuff
- (void)srandNormal
{
    srand( time(NULL) );
}

- (void)srandFixed
{
    srand( 0xDEADBEEF );
}

- (float)randNormalized
{
    return( (float)rand() / (float)RAND_MAX );
}

- (unsigned char)rand255
{
    return( rand() & 0x0ff );
}

@end
