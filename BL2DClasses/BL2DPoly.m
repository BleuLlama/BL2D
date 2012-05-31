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
#ifdef NEVER
	if( !tilesBuffer ) return;
	[gfx glActivate];

	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, texturePoints );
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, screenMesh );
	
	// set it up so we can do transparency
	
	glColor4f( 1.0, 1.0, 1.0, 1.0 );
	glEnable(GL_BLEND);
	//	glBlendFunc (GL_ONE, GL_SRC_COLOR);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glPushMatrix();
	glTranslatef( self.spx, self.spy, 0.0 );
	if( self.fillScreen ) {
		glScalef( viewW/gfx.pxWidth, viewH/gfx.pxHeight, 1.0 );// gfx.pxHeight * gfx.sourceHeightP, 1.0 );
	} else {
		glScalef( scale, scale, 1.0 );
	}
	glRotatef( angle, 0.0, 0.0, 1.0 );
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, kNumberOfPoints * nWide * nHigh);
	glPopMatrix();
	
	glDisable(GL_BLEND);
	glColor4f( 1.0, 1.0, 1.0, 1.0 );
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// unbind
	[gfx glDeactivate];
#endif
}

#pragma mark - debug

- (NSString *)description
{
	NSMutableString * str = [[NSMutableString alloc] init];

    /*
	int ai = 0;
	
	[str appendFormat:@"{\n"];
	for( int i = 0 ; i < nHigh*nWide ; i ++ )
	{
		
		for( int j=0 ; j<4 ; j++ )
		{
			[str appendFormat:@" {%3.0f, %3.0f, %3.0f} ", 
			 screenMesh[ai], 
			 screenMesh[ai+1], 
			 screenMesh[ai+2] ];
			ai += 3;
		}
		[str appendFormat:@"\n"];
	}
	[str appendFormat:@"}\n" ];
     */
    [str appendFormat:@"Wut?"];
	return str;
}

@end

