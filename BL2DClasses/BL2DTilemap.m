//
//  BL2DTilemap.m
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

#import "BL2DTilemap.h"

@interface BL2DTilemap()
@end

@implementation BL2DTilemap

@synthesize fillScreen;

#pragma mark -
#pragma mark classy stuff

- (id) initWithGraphics:(BL2DGraphics *)paramgfx
{
	self = [super initWithGraphics:paramgfx];
	if (self)
    {
		// blah
		tilesBuffer = NULL;
		screenMesh = NULL;
		texturePoints = NULL;
	}
	return self;
}

- (void)dealloc
{
	if( tilesBuffer ) free( tilesBuffer );
	tilesBuffer = NULL;
	
	if( screenMesh ) free( screenMesh );
	screenMesh = NULL;
	
	if( texturePoints ) free( texturePoints );
	texturePoints = NULL;
	
	// not anymore [super dealloc];
}

- (void) setTilesWide:(int)w tilesHigh:(int)h
{
	if( tilesBuffer ) {
		// if it's differently sized, free it, start over
		if( ( w*h ) != (nWide * nHigh) )  {
			free( tilesBuffer );
			tilesBuffer = NULL;
			
			if( screenMesh ) {
				free( screenMesh );
				screenMesh = NULL;
			}
			
			if( texturePoints ) { 
				free( texturePoints );
				texturePoints = NULL;
			}
		}
	}
	
	nWide = w;
	nHigh = h;
	
	// allocate a new buffer
	if( !tilesBuffer ) {
		tilesBuffer = (int *) malloc( sizeof( int ) * (w*h) );
	}

	// and zero it out.
	memset( tilesBuffer, 0, (w*h) * sizeof( int ));
}

#pragma mark - accessors
- (int) width
{
    return nWide;
}

- (int) height
{
    return nHigh;
}

#pragma mark - get/set characters

- (void) setCharacterAtX:(int)px atY:(int)py to:(int)value
{
	if( !tilesBuffer ) return;
    
    if( px >= nWide ) return;
    if( py >= nHigh ) return;
	
	tilesBuffer[ (py*nWide) + px ] = value;
}

- (int) getCharacterAtX:(int)px atY:(int)py
{
	if( !tilesBuffer ) return -1;
	
	return tilesBuffer[ (py*nWide) + px ];
}

- (void) fillWithRandom
{
	for( int item = 0; item < nWide * nHigh ; item++ )
	{
		tilesBuffer[ item ] = rand() % ( self.gfx.tilesWide * self.gfx.tilesHigh );
	}
}

#pragma mark - get/set characters - text rendering


- (void)drawTextAtX:(int)x atY:(int)y txt:(NSString *)txt
{
    for( int xx = 0 ; xx<[txt length] ; xx++ )
    {
        [self setCharacterAtX:x+xx atY:y to:[txt characterAtIndex:xx]];
    }
}

- (void)drawCenteredTextAt:(int)y txt:(NSString *)txt
{

    int x = (int)(nWide/2) - ((int)[txt length]/2);
    [self drawTextAtX:x atY:y txt:txt]; // XXXXX FIX
}

- (void)drawLeftTextAtX:(int)x atY:(int)y txt:(NSString *)txt
{
    [self drawTextAtX:(int)(nWide - [txt length] - x) atY:y txt:txt];
}


#pragma mark - buffer stuff

#define kNumberOfPoints     (5)
#define kScreenQuadCount	(15)	/* 5 points - x, y z in screen - last one repeated for now */
#define kTextureQuadCount	(10)	/* 5 points - x, y in source texture */

/* 
 okay. i need to explain this 
 Repeating the last point in the quad is a less-than-optimal solution,
 however, it'll work for now.
 
 The issue is that if you have a grid like this:
 
 A  B  C 
 D  E  F
 G  H  I
 
 of points. and you want to map quads into it, they map (with simply 4 point quads) as:
 A D B E
 B E C F
 D G E H
 E H F I
 
 Which is fine, except for when this is rendered as a single Triangle Strip, you get errors;
 namely, it will draw the following tris:
 
 A D B  OK. first half of t0
 D B E  OK. second half of t0
 B E B  OK. Zero-area triangle, necessary to advance to the next tri
 E B E  OK. Zero-area triangle, necessary to advance to the next tri
 B E C  OK. first half of t1
 E C F  OK. second half of t1
 C F D  BAD - should be zero-area, but it's a weird, erroneous triangle
 F D G  BAD - should be zero-area, but it's a weird, erroneous triangle
 D G E  OK. first half of t2
 ...
 
 So, the proper solution here is, at the end of every row, repeat the final point
 But instead, for now, we repeat the final point on *every* tri.  This means that 
 we end up with an extra Zero-area triangle for every quad drawn.
 
 This is not optimal, but i'm in a crunch right now to get this implemented, and
 i'm running with this quick-and-dirty hack to get this working.
 */

- (void) fillQuadIn:(GLfloat *)buffer forRow:(int)r forCol:(int)c
{
	// [0],[1],[2] = top left x0,y0,z0
	//	then bot left, then top right, then bot right
	
	// top left
	buffer[0] = c * self.gfx.pxWidth;		// x0
	buffer[1] = r * self.gfx.pxHeight;		// y0
	buffer[2] = 0.0;
	
	// bottom left
	buffer[3] = buffer[0];				// x1
	buffer[4] = buffer[1]+self.gfx.pxHeight;	// y1
	buffer[5] = 0.0;
	
	// top right
	buffer[6] = buffer[0]+self.gfx.pxWidth;	// x2
	buffer[7] = buffer[1];				// x3
	buffer[8] = 0.0;
	
	// bottom right
	buffer[9] = buffer[6];				// x4
	buffer[10] = buffer[4];				// y4
	buffer[11] = 0.0;

	// bottom right (repeated)
	buffer[12] = buffer[6];				// x5
	buffer[13] = buffer[4];				// y5
	buffer[14] = 0.0;
}

- (void) commitChanges
{
	if( !tilesBuffer ) return;
	
	// rebuild the texture map array
	
	// two for the first vertical, then two for each additional endpoint;

	if( !screenMesh ) // points in the GL world
	{
		// 15 floats per quad.
		// 3 for each corner point.  hence this right here -------vvvvv
		screenMesh = malloc( sizeof( GLfloat ) * (nWide * nHigh * kScreenQuadCount ) /* xyz */ );
		if( !screenMesh ) return;
	}
	
	if( !texturePoints ) // points in the source image
	{
		// 8 floats per quad.
		// 2 for each corner point ----------------------------------vvvvv
		texturePoints = malloc( sizeof( GLfloat ) * (nWide * nHigh * kTextureQuadCount ));
	}
	
	// okay. so we've got the screen mesh memory set up. time to fill it.
	int tileidx = 0;
	for( int row = 0 ; row < nHigh ; row++ )
	{
		for( int col = 0 ; col < nWide ; col++ )
		{
			int idx = ((row * nWide) + col) * kScreenQuadCount;
			[self fillQuadIn:&screenMesh[idx] forRow:row forCol:col];
			
			int idxtx = ((row * nWide) + col) * kTextureQuadCount;
			[self.gfx fillQuadIn:&texturePoints[idxtx] forTile:tilesBuffer[tileidx++]];

		}
	}
}



// change in bulk
- (void) copyNewTilesBuffer:(int *)newBuffer
{
	if( !tilesBuffer ) return;
	
	// should probably do a memcopy here instead. but for clarity's sake...
	
	for( int i = 0 ; i< (nWide * nHigh) ; i++ )
	{
		tilesBuffer[i] = newBuffer[i];
	}
}

- (void) copyNewTilesBufferU8:(unsigned char *)newBuffer
{
	if( !tilesBuffer ) return;

	for( int i = 0 ; i< (nWide * nHigh) ; i++ )
	{
		tilesBuffer[i] = (int)newBuffer[i];
	}	
}

#pragma mark - render routines

- (void) render
{
	if( !tilesBuffer || !active ) return;
	[self.gfx glActivate];

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
		glScalef( viewW/self.gfx.pxWidth, viewH/self.gfx.pxHeight, 1.0 );// gfx.pxHeight * gfx.sourceHeightP, 1.0 );
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
	[self.gfx glDeactivate];
}

#pragma mark - debug

- (NSString *)description
{
	NSMutableString * str = [[NSMutableString alloc] init];
	
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
	return str;
}

@end

