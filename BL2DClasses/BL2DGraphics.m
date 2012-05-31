//
//  BL2DGraphics.m
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

#import "BL2DGraphics.h"
@interface BL2DGraphics()
- (void) computePercentages;
- (void) loadPng:(NSString *)fn;
@end

#define kPixellyScaleups	(1)  /* use nearest neighbor scaling */

@implementation BL2DGraphics

@synthesize glHandle;
@synthesize pxHeight, pxWidth;
@synthesize tilesWide, tilesHigh;
@synthesize sourceWidthP, sourceHeightP;

#pragma mark -
#pragma mark classy stuff

- (id) initWithPNG:(NSString *)filename 
		 tilesWide:(int)across
		 tilesHigh:(int)slurp
{
	self = [super init];
	if (self)
    {
		image_width = 0;
		image_height = 0;
		tilesWide = across;
		tilesHigh = slurp;
		glHandle = 0;
		percentsW = NULL;
		percentsH = NULL;
        isTiled = true;
        geom = NULL;
		
		[self loadPng:filename];
		[self computePercentages];
		
		pxWidth = image_width / tilesWide;
		pxHeight = image_height / tilesHigh;
	}
	return self;
}

- (id) initWithPlist:(NSString *)plist
{
    self = [super init];
    if( self )
    {
        // do stuff here
        image_width = 0;
        image_height = 0;
        
        // instantiate the dict, extract out useful stuff
        
        NSString *path = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];

        NSDictionary *d = [[NSDictionary  alloc] initWithContentsOfFile:path];
        
/*
        NSLog( @"%@", d );
*/        
        if( !d ) { NSLog( @"%@: ERROR: Unable to load plist file!", plist ); return( self ); }
        
        // 1. load image file
        NSDictionary *td = [d objectForKey:@"Image"];
        if( !td ) { NSLog( @"%@: ERROR: Unable to find Image section in plist file!", plist ); return( self ); }
        
        NSString *text = [td objectForKey:@"base"];
        if( !text ) { NSLog( @"%@: ERROR: Unable to find Image!", plist ); return( self ); }

        [self loadPng:text];
		[self computePercentages];
        
        // 2. load the geometries
        NSArray *ta = [d objectForKey:@"Sprites"];
        if( [ta count] < 1 ) {
            NSLog( @"%@: ERROR: NO SPRITES FOUND!", [td objectForKey:@"base"] );
        }

        int s=0;
        geom = (BL2D_tilegeom *) calloc( [ta count]+1, sizeof(BL2D_tilegeom) );
        for( s=0 ; s< [ta count] ; s++ )
        {
            NSDictionary * di = [ta objectAtIndex:s];
            
/*
            NSLog( @"Item %d:  %d %d  %d %d",
                  [[di valueForKey:@"idx"] intValue],
                  [[di valueForKey:@"x"] intValue],
                  [[di valueForKey:@"y"] intValue],
                  [[di valueForKey:@"w"] intValue],
                  [[di valueForKey:@"h"] intValue]
                  );
 */
            
            geom[s].idx = [[di valueForKey:@"idx"] intValue];
            geom[s].x = [[di valueForKey:@"x"] intValue];
            geom[s].y = [[di valueForKey:@"y"] intValue];
            geom[s].w = [[di valueForKey:@"w"] intValue];
            geom[s].h = [[di valueForKey:@"h"] intValue];
        }
        geom[s].idx = -1; // terminator
        
    }
    return self;
}

- (void)dealloc
{
	// free up our allocated space
	if( percentsW ) free( percentsW );
	if( percentsH ) free( percentsH );
    
    if( geom ) free( geom );
	
	// and free the image texture
	glDeleteTextures( 1, &glHandle );
	
	[super dealloc];
}

#pragma mark -
#pragma mark the important stuff


- (BOOL)isPowerOfTwo:(int)value
{
	return (value & -value) == value;
}

- (int)nextPowerOfTwo:(int)value
{
	int next_pow = value;
	next_pow--;
	next_pow = (next_pow >> 1) | next_pow;
	next_pow = (next_pow >> 2) | next_pow;
	next_pow = (next_pow >> 4) | next_pow;
	next_pow = (next_pow >> 8) | next_pow;
	next_pow = (next_pow >> 16) | next_pow;
	next_pow++; // Val is now the next highest power of 2.
	return next_pow;
}


- (void)loadPng:(NSString *)fn
{
	// ref http://iphonedevelopment.blogspot.com/2009/05/opengl-es-from-ground-up-part-6_25.html
	
	// GL prep
	glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_SRC_COLOR);
	//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); // use for png
	
	// make texture name
	GLuint texture[1];
	glGenTextures(1, &texture[0]);
	glBindTexture(GL_TEXTURE_2D, texture[0]);
	
#ifdef kPixellyScaleups	// for pixelly scale-ups
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);	
#else
	// configure (for smooth scaleups)
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
#endif

	// load image
	NSString *path = [[NSBundle mainBundle] pathForResource:fn ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *originalImage = [[UIImage alloc] initWithData:texData]; // from disk.
	UIImage *image; // to be used...
	
	// make sure it loaded
    if (originalImage == nil) {
        NSLog(@"Failed load of %@!", fn);
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
		glBindTexture(GL_TEXTURE_2D, 0);		
		return;
	}
	
	
	// doublecheck that it's a power of two in dimensions
	sourceWidth = CGImageGetWidth(originalImage.CGImage);
	sourceHeight = CGImageGetHeight(originalImage.CGImage);
	
	GLuint width = sourceWidth;
	GLuint height = sourceHeight;
	
	if( ![self isPowerOfTwo:sourceWidth] || ![self isPowerOfTwo:sourceHeight] )
	{
		// it's not.  Lets now create a power-of-2 canvas and draw the image onto it.
		width = [self nextPowerOfTwo:sourceWidth];
		height = [self nextPowerOfTwo:sourceHeight];
		
		// shove it into a larger image.
		CGSize newSize = CGSizeMake(width, height); // power of 2 new size
		UIGraphicsBeginImageContext(newSize);
		[originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		
		UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[originalImage release];
		[newImage retain];
		
		image = newImage;
	} else {
		image = originalImage;
	}
	sourceWidthP = (float)sourceWidth/(float)width;
	sourceHeightP = (float)sourceHeight/(float)height;
	
	// okay.  now, let's load that in to a GL Texture
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
	
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
    CGContextRelease(context);
	
    free(imageData);
    [image release];
    [texData release];
	
	glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
	glBindTexture(GL_TEXTURE_2D, 0);


	// store it aside	
	image_width = width;
	image_height = height;
	
	glHandle = texture[0];
}

- (void) computePercentages
{
    // for tiled use
    
	// horizontals/verticals: (this might be premature optimization.)
	//  take image_width/tilesWide - this number +1 is the number of entries to alloc
	percentsW = (float *)calloc( tilesWide+1, sizeof( float ));	
	for( int i=0 ; i<tilesWide+1 ; i++ ) 
	{
		percentsW[i] = (float)i/(float) tilesWide;
	}

	percentsH = (float *)calloc( tilesHigh+1 , sizeof( float ));	
	for( int i=0 ; i<tilesHigh+1 ; i++ ) 
	{
		percentsH[i] = (float)i/(float) tilesHigh;
	}
}


#pragma mark -
#pragma mark gl rendering helpers

- (void) glActivate
{	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, glHandle);	
}

- (void) glDeactivate
{
	glDisable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, 0);	
}

- (int) getXTileForIndex:(int)index
{
    if( isTiled ) {
        return index % tilesWide;
    }
    
    return 0;
}

- (int) getYTileForIndex:(int)index
{
    if( isTiled ) {
        int nTiles = tilesHigh * tilesWide;
        if( index >= ( nTiles )) index = index % nTiles;
        
        return index / tilesWide;
    }
    
    return 0;
}


#pragma mark -
#pragma mark rendering

- (void) fillQuadIn:(GLfloat *)buffer forTile:(int)index
{
	if( isTiled ) {
        int xTile = [self getXTileForIndex:index];
        int yTile = [self getYTileForIndex:index];
        
        // top left
        buffer[0] = percentsW[xTile];
        buffer[1] = percentsH[yTile];
        
        // bottom left
        buffer[2] = percentsW[xTile];
        buffer[3] = percentsH[yTile+1];
        
        // top right
        buffer[4] = percentsW[xTile+1];
        buffer[5] = percentsH[yTile];
        
        // bottom right
        buffer[6] = percentsW[xTile+1];
        buffer[7] = percentsH[yTile+1];

        // bottom right (repeated)
        buffer[8] = percentsW[xTile+1];
        buffer[9] = percentsH[yTile+1];
    } else {
        // compute the proper sizes based on the image and the sprite widths
        
        // 1. find the item
        
        BL2D_tilegeom * g = geom;
        while( g && g->idx != -1 && g->idx != index ) {
            g++;
        }
        if( !g || g->idx == -1 ) {
            NSLog( @"ERROR: Sprite %d not found!", index );
            return;
        }
        
        // 2. get percents
        float xs = (float)g->x / (float)image_width;
        float ys = (float)g->y / (float)image_height;
        
        float xe = (float)(g->x + g->w) / (float)image_width;
        float ye = (float)(g->y + g->h) / (float)image_height;
                
        // 3. fill the buffer
        buffer[0] = xs;
        buffer[1] = ys;
        
        buffer[2] = xs;
        buffer[3] = ye;
        
        buffer[4] = xe;
        buffer[5] = ys;

        buffer[6] = xe;
        buffer[7] = ye;
        
        buffer[8] = xe;
        buffer[9] = ye;
        
        // hack for now
        pxWidth = g->w;
        pxHeight = g->h;

    }
	
}


- (void) setupBufferForTile:(int)index into:(GLfloat *)buffer	/* [15] */
{
	if( !buffer ) return;

	// generate a backwards-n format	
	if( index == kRenderEntireImage )
	{
		// top left
		buffer[0] = 0.0;	buffer[1] = 0.0;

		// bottom left
		buffer[2] = 0.0;	buffer[3] = 1.0;

		// top right
		buffer[4] = 1.0;	buffer[5] = 0.0;

		// bottom right
		buffer[6] = 1.0;	buffer[7] = 1.0;
		buffer[8] = 1.0;	buffer[9] = 1.0;
		
		return;
	}

	// otherwise the index is pseudovalid
	[self fillQuadIn:buffer forTile:index];
}

- (void) setupSpriteBuffer:(GLfloat *)buffer flipX:(BOOL)fx flipY:(BOOL)fy
{	
	GLfloat w = (GLfloat) pxWidth;
	GLfloat h = (GLfloat) pxHeight;
	
	/* this is the nice way to look at this...
	buffer[0] = 0.0;	buffer[1] = 0.0;	buffer[2] = 0.0;
	buffer[3] = 0.0;	buffer[4] = h;		buffer[5] = 0.0;
	buffer[6] = w;		buffer[7] = 0.0;	buffer[8] = 0.0;
	buffer[9] = w;		buffer[10] = h;		buffer[11] = 0.0;
	 */
	
	// but this way makes more sense, code-wise
	if( fx ) {
		buffer[0] = buffer[3] = w;
		buffer[6] = buffer[9] = 0.0;
	} else {
		buffer[0] = buffer[3] = 0.0;
		buffer[6] = buffer[9] = w;
	}
	
	if( fy ) {
		buffer[1] = buffer[7] = h;
		buffer[4] = buffer[10] = 0.0;
	} else {
		buffer[1] = buffer[7] = 0.0;
		buffer[4] = buffer[10] = h;
	}
	
	// Z
	buffer[2] = buffer[5] = buffer[8] = buffer[11] = 0.0;
	
	// final point
	buffer[12] = buffer[9];
	buffer[13] = buffer[10];
	buffer[14] = buffer[11];
}

- (void) renderSingle:(int)index flipX:(BOOL)fx flipY:(BOOL)fy
{
	GLfloat textureBuffer[10];
	GLfloat spriteBuffer[15];

	[self setupBufferForTile:index into:textureBuffer];
	[self setupSpriteBuffer:spriteBuffer flipX:fx flipY:fy ];

	[self glActivate];
	
	// place it on the gl canvas
	
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_FLOAT, 0, textureBuffer );
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, spriteBuffer );
	
	// set it up so we can do transparency
	
	glColor4f( 1.0, 1.0, 1.0, 1.0 );
	glEnable(GL_BLEND);
	//	glBlendFunc (GL_ONE, GL_SRC_COLOR);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisable(GL_BLEND);
	glColor4f( 1.0, 1.0, 1.0, 1.0 );
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	// unbind
	[self glDeactivate];
}


- (void)renderSolidAlpha:(GLfloat)alpha  R:(GLfloat)r G:(GLfloat)g B:(GLfloat)b
{
	GLfloat buffer[12];
	[self setupSpriteBuffer: buffer flipX:NO flipY:NO];
	
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, buffer);
	
	// set it up so we can do transparency
	glColor4f( r, 0.0, b, alpha );
	glEnable(GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisable( GL_BLEND );
	glDisableClientState(GL_VERTEX_ARRAY);	
}

@end
