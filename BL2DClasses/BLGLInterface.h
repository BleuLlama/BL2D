//
//  GLInterface
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


// there's probably a better way of doing this (and like, nearly everything in this code :D)
// each texture you load will have grids of texture coordinates generated for tiles of each of these sizes.
// it's not very efficient atm because it's all automated - it will generate 16x16 grid even for an image
// you're only using 8x8 tiles for. this does allow for different sized tiles/sprites on the same image though.
// - the reason it generates new grids for each texture is in case the pngs are different sizes.
// if all your pngs are the same size you can just generate a single set of grids.

#define NUM_FRAME_SIZES 2

enum { SIZE_8x8, SIZE_16x16 };


#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

#include "BLRenderBuffer.h"

// may need to tweak these for your project
#define kNumberOfTextures	(16)
#define kNumberOfLayers		(16)

typedef struct TTexture
{
	unsigned int w, h;
	GLuint name; // the ID passed to openGL when binding this texture
	TRect* texRects[ NUM_FRAME_SIZES ]; // rects splitting up the texture into a grid of each possible frame size
} TTexture;

typedef struct TRenderLayer
{
	BLRenderBuffer * buffer;
	unsigned int textureNum; // which entry in the _textures vector will be bound when this renderbuffer is drawn
} TRenderLayer;


@interface BLGLInterface : NSObject
{
	/* privateish */
	unsigned int _w, _h;
	TTexture _textures[ kNumberOfTextures ];
	unsigned int _texturesCount;
	TRenderLayer _layers[ kNumberOfLayers ];
	unsigned int _layersCount;
	unsigned int _currentlyBoundTexture;
	TColour _white;
}

- (id) init;


// openGL commands to setup the view for 2d drawing with proper screen-pixel coords (320x480 on iphone)
- (void) initGLWithWidth:(int)w andHeight:(int)h;

// loads .png, returns which entry in _textures vector it was loaded to
- (unsigned int) loadTexture:(NSString *)filename;

// adds a drawing layer. textureNum tells it which entry in _textures to bind for this layer
// each layer can only use a single texture. you can have multiple layers using the same texture.
// (layers don't HAVE to use only a single texture, it's just how i use it.. the less texture binding, the faster)
- (unsigned int) addLayer:(unsigned int) textureNum;

- (void) drawImage:(unsigned int)layerNum 
			  size:(unsigned int)size
			 frame:(unsigned int)frame
				 x:(float)x
				 y:(float)y
			hscale:(float)hScale /*=1.0 */
			vscale:(float)vScale /*=1.0*/
			 angle:(float)angle /* 0.0 */
            colour:(const TColour *)colour; /* NULL */

- (void) render:(unsigned int)layerNum;

@end