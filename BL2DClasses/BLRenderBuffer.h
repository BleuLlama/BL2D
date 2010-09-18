//
//  BLRenderBuffer
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


#pragma once

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

// 4096 verts will allow for 1024 quads per buffer of course.
// in MSD i have this set at 2048, and i'm using like 6 layers
// not sure what the maximum usable amount would be...

#define kMaxVerts_Sprite		(4*256)		/* allow for 256 sprites */
#define kMaxVerts_Tile			(40*60*4)	/* allow for 320x240 at 8x8 */

typedef struct TRect
{
	float x[2];
	float y[2];
} TRect;

typedef struct TVec2
{
	float x, y;
} TVec2;

typedef struct TColour
{
	float r, g, b, a;
} TColour;

typedef struct TVertexData
{
	TVec2 vert;
	TVec2 tex;
	TColour colour;
} TVertexData;



@interface BLRenderBuffer : NSObject
{
	int _numVerts, _numFaces, _stride, _maxVerts;
	TVertexData* _pVertData;
	unsigned short* _pFaceData;	
}

- (id) init;
- (id) initWithMaxVerts:(int)mv;

- (void) reset;

// adds a textured quad to the buffer, using TRect quad for vertex coords (used for non-rotated quads)
- (void) addQuad:(const TRect*)quad tex:(const TRect *)tex col:(const TColour *)col;

// adds a quad using x0,y0,x1,y1 etc for vertex coords (used for rotated quads)
- (void) addQuadX0:(const float)x0 Y0:(const float)y0
				X1:(const float)x1 Y1:(const float)y1
				X2:(const float)x2 Y2:(const float)y2
				X3:(const float)x3 Y3:(const float)y3
			   tex:(const TRect *)tex col:(const TColour *)col;

- (void) render;

@end

#ifdef _USE_CPLUSPLUS_STUFF
class RenderBuffer
{

private:
	int _numVerts, _numFaces, _stride, _maxVerts;
	TVertexData* _pVertData;
	unsigned short* _pFaceData;	

public:
	RenderBuffer( int maxVerts = kMaxVerts_Tile );
	~RenderBuffer();

	void Init();
	void Reset();

	// adds a textured quad to the buffer, using TRect quad for vertex coords (used for non-rotated quads)
	void AddQuad( const TRect& quad, const TRect& tex, const TColour& col );

	// adds a quad using x0,y0,x1,y1 etc for vertex coords (used for rotated quads)
	void AddQuad( const float x0, const float y0, const float x1, const float y1, const float x2, const float y2, const float x3, const float y3, const TRect& tex, const TColour& col );

	void Render();
};
#endif

