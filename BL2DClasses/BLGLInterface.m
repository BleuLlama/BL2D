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

#import "BLGLInterface.h"

const unsigned int frameSizes[ NUM_FRAME_SIZES ] = { 8, 16 };

@interface BLGLInterface ()

- (void) killTextures;
- (void) killLayers;
- (void) generateTexRects:(TTexture *) tex;
- (void) bindTexture:(unsigned int)textureNum;	
@end

@implementation BLGLInterface

- (id) init
{
	if ((self = [super init]))
	{
		_w = 0;
		_h = 0;
		
		_texturesCount = 0;
		_layersCount = 0;
		
		_white.r = 1.0; _white.g = 1.0; _white.b = 1.0; _white.a = 1.0;
	}
	return self;
}

- (void) initGLWithWidth:(int)w andHeight:(int)h
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof( 0.0f, w, 0.0f, h, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// these are probably all disabled by default anyway.. it's just stuff not needed for pure 2D 		
	//	glDisable( GL_DITHER );
	//	glDisable( GL_ALPHA_TEST );
	//	glDisable( GL_STENCIL_TEST );
	//	glDisable( GL_FOG );
	//	glDisable( GL_DEPTH_TEST );
	
	_w = w;
	_h = h;	
}

- (void) dealloc
{
	[self killLayers];
	[self killTextures];
	[super dealloc];
}


#pragma mark -

void GetFrameTopLeft( int frame, int frameW, int frameH, int imageW, int imageH, int * topleft )
{
	if (frame == 0)
	{
		topleft[0] = 0;
		topleft[1] = 0;
	}
	else
	{
		int hFrames = imageW / frameW;
		int vFrames = imageH / frameH;
		int curFrame = 0;
		
		for (int y = 0; y < vFrames; y++)
			for (int x = 0; x < hFrames; x++)
			{
				if (curFrame == frame)
				{
					topleft[0] = (x * frameW);
					topleft[1] = (y * frameH);
				}
				curFrame++;
			}
	}
}



- (void) killTextures
{
	for (unsigned int i = 0; i < _texturesCount; i++)
	{
		for (unsigned int i2 = 0; i2 < NUM_FRAME_SIZES; i2++)
		{
			free(  _textures[ i ].texRects[ i2 ] );
		}
	}
	_texturesCount = 0;
}

- (void) killLayers
{
	for (int i = 0; i < _layersCount; i++)
	{
		[_layers[i].buffer release];
		_layers[i].buffer = nil;
	}
	_layersCount = 0;
}



- (void) generateTexRects:(TTexture *) tex
{
	float w = tex->w;
	float h = tex->h;
	
	for (unsigned int i = 0; i < NUM_FRAME_SIZES; i++)
	{
		unsigned int numRects = ( w / frameSizes[ i ] ) * ( h / frameSizes[ i ] );
		tex->texRects[ i ] = (TRect*)malloc( sizeof( TRect ) * numRects );
		
		for (int i2 = 0; i2 < numRects; i2++)
		{
			int topleft[2];
			GetFrameTopLeft( i2, frameSizes[ i ], frameSizes[ i ], w, h, topleft );
			
			tex->texRects[ i ][ i2 ].x[0] = topleft[0] / w;
			tex->texRects[ i ][ i2 ].y[1] = topleft[1] / h;
			tex->texRects[ i ][ i2 ].x[1] = ( topleft[0] + frameSizes[ i ] ) / w;
			tex->texRects[ i ][ i2 ].y[0] = ( topleft[1] + frameSizes[ i ] ) / h;
		}
	}
}

- (void) bindTexture:(unsigned int)textureNum
{
	// checks to see if specified texture is already bound. if not, binds it.
	// apparently glBindTexture is relatively 'expensive'
	// if you're always drawing everything in the same order etc you probably don't need this check
	if ( textureNum != _currentlyBoundTexture )
	{
		_currentlyBoundTexture = textureNum;
		glBindTexture( GL_TEXTURE_2D, _textures[ textureNum ].name );
	}
}



#pragma mark -

- (unsigned int) loadTexture:(NSString *)filename
{
	CGImageRef spriteImage;
	CGContextRef spriteContext;
	GLubyte *spriteData;
	size_t width, height;
	GLuint spriteTexture;
	
	// make sure we're OK
	if( _texturesCount >= kNumberOfTextures ) return _texturesCount-1;
	
	spriteImage = [UIImage imageNamed:filename].CGImage;
	
	assert( spriteImage );


	width = CGImageGetWidth(spriteImage);
	height = CGImageGetHeight(spriteImage);
	
	spriteData = (GLubyte *) calloc(width * height * 4, 1);
	spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
	CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
	CGContextRelease(spriteContext);
	
	//spriteTexture = new GLuint;
	glGenTextures(1, &spriteTexture);
	
	glBindTexture(GL_TEXTURE_2D, spriteTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
	
	free(spriteData);
	
	// nearest neighbour filtering. crisp!
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	/// linear filtering. blurry!
	// if you want to rotate sprites, using this setting might look better for them, less jaggies..
	// magnet & razor in MSD use this, everything else uses nearest neighbour
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	// it's been ages since i originally did this code, IIRC, without these lines, you might get artifacts on
	// the edge of textures. not 100% sure it's even necessary for this, oh well!
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glEnable(GL_TEXTURE_2D);
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); // use for png
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); // use for pvrt
	
	glEnable(GL_BLEND);
	
	_textures[ _texturesCount ].name = spriteTexture;
	_textures[ _texturesCount ].w = width;
	_textures[ _texturesCount ].h = height;
	
	[self generateTexRects:&_textures[ _texturesCount ]];
	_texturesCount++;
	
	return _texturesCount-1;	
}

- (unsigned int) addLayer:(unsigned int) textureNum
{
	assert( textureNum < _texturesCount );
	
//	TRenderLayer* layer = new TRenderLayer;
	_layers[ _layersCount ].textureNum = textureNum;
	_layers[ _layersCount ].buffer = [[BLRenderBuffer alloc] init];
	_layersCount++;
	
	return _layersCount - 1;
}

- (void) drawImage:(unsigned int)layerNum 
			  size:(unsigned int)size
			 frame:(unsigned int)frame
				 x:(float)x
				 y:(float)y
			hscale:(float)hScale /*=1.0 */
			vscale:(float)vScale /*=1.0*/
			 angle:(float)angle /* 0.0 */
            colour:(const TColour *)colour /* NULL */
{
	// i bet this is all horribly inefficient. :)
	
	assert( layerNum < _layersCount );
	
	y = _h - y;
	
	float w = frameSizes[ size ] * hScale;
	float h = frameSizes[ size ] * vScale;
	
	float xOfs = w * 0.5;
	float yOfs = h * 0.5;
	
	TRect quad;
	quad.x[ 0 ] = x - xOfs;
	quad.y[ 0 ] = y - yOfs;
	quad.x[ 1 ] = quad.x[ 0 ] + w;
	quad.y[ 1 ] = quad.y[ 0 ] + h;
	
	TRect* texRect = &_textures[ _layers[ layerNum ].textureNum ].texRects[ size ][ frame ];
	
	if ( angle == 0.0 )  // add non-rotated quad
	{
		[_layers[ layerNum ].buffer addQuad:&quad tex:texRect col:&_white ];
	}
	else  // add rotated quad.
	{
		// all this stuff is what rotates the corners. probably a way faster way to do it.. affine matrices? i dunno
		float newX[ 4 ];
		float newY[ 4 ];
		
		newX[ 0 ] = cosf( angle ) * ( quad.x[ 0 ] - x ) - sinf( angle ) * ( quad.y[ 0 ] - y ) + x;
		newY[ 0 ] = sinf( angle ) * ( quad.x[ 0 ] - x ) + cosf( angle ) * ( quad.y[ 0 ] - y ) + y;
		
		newX[ 1 ] = cosf( angle ) * ( quad.x[ 1 ] - x ) - sinf( angle ) * ( quad.y[ 0 ] - y ) + x;
		newY[ 1 ] = sinf( angle ) * ( quad.x[ 1 ] - x ) + cosf( angle ) * ( quad.y[ 0 ] - y ) + y;
		
		newX[ 2 ] = cosf( angle ) * ( quad.x[ 0 ] - x ) - sinf( angle ) * ( quad.y[ 1 ] - y ) + x;
		newY[ 2 ] = sinf( angle ) * ( quad.x[ 0 ] - x ) + cosf( angle ) * ( quad.y[ 1 ] - y ) + y;
		
		newX[ 3 ] = cosf( angle ) * ( quad.x[ 1 ] - x ) - sinf( angle ) * ( quad.y[ 1 ] - y ) + x;
		newY[ 3 ] = sinf( angle ) * ( quad.x[ 1 ] - x ) + cosf( angle ) * ( quad.y[ 1 ] - y ) + y;
		
		[_layers[ layerNum ].buffer addQuadX0:newX[ 0 ] Y0:newY[ 0 ] 
										   X1:newX[ 1 ] Y1:newY[ 1 ] 
										   X2:newX[ 2 ] Y2:newY[ 2 ] 
										   X3:newX[ 3 ] Y3:newY[ 3 ] 
										  tex:texRect col:&_white];		
	}
}

- (void) render:(unsigned int)layerNum
{
	assert( layerNum < _layersCount );
	
	[self bindTexture:_layers[ layerNum ].textureNum ];
	[_layers[ layerNum ].buffer render];
}

@end