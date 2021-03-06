//
//  BL2DSprite.m
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

#import "BL2DSprite.h"

@interface BL2DSprite()
@end

@implementation BL2DSprite

#pragma mark -
#pragma mark classy stuff

- (id) initWithGraphics:(BL2DGraphics *)paramgfx
{
	self = [super initWithGraphics:paramgfx];
	if (self)
    {
		index = 0;
	}
	return self;
}

- (void)dealloc
{
	// not anymore [super dealloc];
}


#pragma mark -
#pragma mark the important stuff

- (void) setSpriteIndex:(int)indexparam
{
	index = indexparam;
//	[gfx setupBufferForTile:index into:renderBuffer];
}

- (void) render
{
	if( !self.active  || !self.gfx ) return;
	
	glPushMatrix();
	glTranslatef( self.spx, self.spy, 0.0 );
	glScalef( scale, scale, 1.0 );
	glRotatef( angle, 0.0, 0.0, 1.0 );
	[self.gfx renderSingle:index flipX:self.flipX flipY:self.flipY];
	glPopMatrix();
}


@end
