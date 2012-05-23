//
//  BL2DGraphics.h
//  Basic2DEngine
//
//  Copyright 2010 Scott Lawrence. All rights reserved.
//

/*
 Copyright (c) 2010 Scott Lawrence
 
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

/*
    NOTE: PNG graphic files loaded in must be (power of 2)x(power of 2) resolution
			PNG files may have transparency
 */

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface BL2DGraphics : NSObject {
	size_t image_width;		// width in pixels of the source image
	size_t image_height;	// height in pixels of the source image
	int tilesWide;			// number of tiles wide in the source image
	int tilesHigh;			// number of tiles high in the source image
	
	GLuint sourceWidth;
	GLuint sourceHeight;
	float sourceWidthP;		// percentage of the width of the final image that is from the file loaded
	float sourceHeightP;	// percentage of the height of the final image that is from the file loaded
	
	GLuint glHandle;		// GL handle for the sprite sheet
	
	float *percentsW;		// precomputed percentages across
	float *percentsH;		// precomputed percentages down
	
	int pxHeight;
	int pxWidth;
}
@property (nonatomic, readonly) GLuint glHandle;
@property (nonatomic, readonly) int pxHeight;
@property (nonatomic, readonly) int pxWidth;
@property (nonatomic, readonly) int tilesWide;
@property (nonatomic, readonly) int tilesHigh;
@property (nonatomic, readonly) float sourceWidthP;
@property (nonatomic, readonly) float sourceHeightP;

// create a new instance, with the PNG selected. (needs to be pow2 x pow2
- (id) initWithPNG:(NSString *)filenameWithoutPNGExtenstion 
		 tilesWide:(int)across
		 tilesHigh:(int)slurp;

// enable our texture with GL.
- (void) glActivate;
- (void) glDeactivate;

// rendering helpers
#define kRenderEntireImage	(-1)
- (void) fillQuadIn:(GLfloat *)buffer forTile:(int)index;
- (void) setupBufferForTile:(int)index into:(GLfloat *)buffer;	/* [12] */
- (void) renderSingle:(int)index flipX:(BOOL)fx flipY:(BOOL)fy;

- (void) renderSolidAlpha:(GLfloat)alpha  R:(GLfloat)r G:(GLfloat)g B:(GLfloat)b;

@end
