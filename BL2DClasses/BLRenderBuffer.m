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

#import "BLRenderBuffer.h"

@implementation BLRenderBuffer

- (id) initWithMaxVerts:(int)mv
{
	if ((self = [super init]))
	{
		_maxVerts = mv;
		
		_pVertData = nil;
		_pFaceData = nil;
		
		_pVertData = (TVertexData*)malloc( sizeof( TVertexData ) * _maxVerts );
		_pFaceData = (unsigned short*)malloc( sizeof( int ) * 3 * _maxVerts );
		
		_stride = sizeof( TVertexData );
		
		[self reset];
	}
	return self;
}


-(id) init
{
	return [self initWithMaxVerts:kMaxVerts_Tile];
}

-(void) dealloc
{
	free( _pVertData );
	free( _pFaceData );
	[super dealloc];
}

-(void) reset
{
	_numVerts = 0;
	_numFaces = 0;
}

- (void) addQuad:(const TRect*)quad tex:(const TRect *)tex col:(const TColour *)col
{
	int faceIndex = _numFaces * 3;
	
	if ( _numVerts < _maxVerts )
	{
		int vertIndex = _numVerts;
		int x = 0;
		int y = 0;
		_pVertData[ vertIndex ].vert.x = quad->x[ x ];
		_pVertData[ vertIndex ].vert.y = quad->y[ y ];
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		vertIndex++;
		x = 1;
		y = 0;
		_pVertData[ vertIndex ].vert.x = quad->x[ x ];
		_pVertData[ vertIndex ].vert.y = quad->y[ y ];
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		vertIndex++;
		x = 0;
		y = 1;
		_pVertData[ vertIndex ].vert.x = quad->x[ x ];
		_pVertData[ vertIndex ].vert.y = quad->y[ y ];
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		vertIndex++;
		x = 1;
		y = 1;
		_pVertData[ vertIndex ].vert.x = quad->x[ x ];
		_pVertData[ vertIndex ].vert.y = quad->y[ y ];
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		
		_pFaceData[ faceIndex + 0 ] = _numVerts + 0;
		_pFaceData[ faceIndex + 1 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 2 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 3 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 4 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 5 ] = _numVerts + 3;
		
		_numVerts += 4;
		_numFaces += 2;
	}	
}

- (void) addQuadX0:(const float)x0 Y0:(const float)y0
				X1:(const float)x1 Y1:(const float)y1
				X2:(const float)x2 Y2:(const float)y2
				X3:(const float)x3 Y3:(const float)y3
			   tex:(const TRect *)tex col:(const TColour *)col
{
	int faceIndex = _numFaces * 3;
	
	if ( _numVerts < _maxVerts )
	{
		int vertIndex = _numVerts;
		int x = 0;
		int y = 0;
		_pVertData[ vertIndex ].vert.x = x0;
		_pVertData[ vertIndex ].vert.y = y0;
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		vertIndex++;
		x = 1;
		y = 0;
		_pVertData[ vertIndex ].vert.x = x1;
		_pVertData[ vertIndex ].vert.y = y1;
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		vertIndex++;
		x = 0;
		y = 1;
		_pVertData[ vertIndex ].vert.x = x2;
		_pVertData[ vertIndex ].vert.y = y2;
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		vertIndex++;
		x = 1;
		y = 1;
		_pVertData[ vertIndex ].vert.x = x3;
		_pVertData[ vertIndex ].vert.y = y3;
		_pVertData[ vertIndex ].tex.x = tex->x[ x ];
		_pVertData[ vertIndex ].tex.y = tex->y[ y ];
		_pVertData[ vertIndex ].colour.r = col->r;
		_pVertData[ vertIndex ].colour.g = col->g;
		_pVertData[ vertIndex ].colour.b = col->b;
		_pVertData[ vertIndex ].colour.a = col->a;
		
		
		_pFaceData[ faceIndex + 0 ] = _numVerts + 0;
		_pFaceData[ faceIndex + 1 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 2 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 3 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 4 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 5 ] = _numVerts + 3;
		
		_numVerts += 4;
		_numFaces += 2;
		
	}	
}

- (void) render
{
	glEnableClientState(GL_VERTEX_ARRAY);	
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glVertexPointer( 2, GL_FLOAT, _stride, &_pVertData->vert );
	glTexCoordPointer( 2, GL_FLOAT, _stride, &_pVertData->tex );
	glColorPointer( 4, GL_FLOAT, _stride, &_pVertData->colour );
	
	glDrawElements( GL_TRIANGLES, _numFaces * 3, GL_UNSIGNED_SHORT, _pFaceData );
	
	[self reset];
}

@end

#ifdef NOTHINGDKGJKDGJ
RenderBuffer::RenderBuffer( int maxVerts )
{
	_maxVerts = maxVerts;
	Init();
	Reset();
}

RenderBuffer::~RenderBuffer()
{
	Reset();
	
	delete _pVertData;
	delete _pFaceData;
}

void RenderBuffer::Init()
{
	_pVertData = nil;
	_pFaceData = nil;
	
	_pVertData = (TVertexData*)malloc( sizeof( TVertexData ) * _maxVerts );
	_pFaceData = (unsigned short*)malloc( sizeof( int ) * 3 * _maxVerts );
	
	_stride = sizeof( TVertexData );
}

void RenderBuffer::Reset()
{
	_numVerts = 0;
	_numFaces = 0;
}



void RenderBuffer::AddQuad( const TRect& quad, const TRect& tex, const TColour& col )
{
	int faceIndex = _numFaces * 3;
	
	if ( _numVerts < _maxVerts )
	{
		int vertIndex = _numVerts;
		int x = 0;
		int y = 0;
		_pVertData[ vertIndex ].vert.x = quad.x[ x ];
		_pVertData[ vertIndex ].vert.y = quad.y[ y ];
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;

		vertIndex++;
		x = 1;
		y = 0;
		_pVertData[ vertIndex ].vert.x = quad.x[ x ];
		_pVertData[ vertIndex ].vert.y = quad.y[ y ];
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;

		vertIndex++;
		x = 0;
		y = 1;
		_pVertData[ vertIndex ].vert.x = quad.x[ x ];
		_pVertData[ vertIndex ].vert.y = quad.y[ y ];
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;

		vertIndex++;
		x = 1;
		y = 1;
		_pVertData[ vertIndex ].vert.x = quad.x[ x ];
		_pVertData[ vertIndex ].vert.y = quad.y[ y ];
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;
		
		
		_pFaceData[ faceIndex + 0 ] = _numVerts + 0;
		_pFaceData[ faceIndex + 1 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 2 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 3 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 4 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 5 ] = _numVerts + 3;

		_numVerts += 4;
		_numFaces += 2;
	}
}

void RenderBuffer::AddQuad( const float x0, const float y0, const float x1, const float y1, const float x2, const float y2, const float x3, const float y3, const TRect& tex, const TColour& col )
{
	int faceIndex = _numFaces * 3;

	if ( _numVerts < _maxVerts )
	{
		int vertIndex = _numVerts;
		int x = 0;
		int y = 0;
		_pVertData[ vertIndex ].vert.x = x0;
		_pVertData[ vertIndex ].vert.y = y0;
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;

		vertIndex++;
		x = 1;
		y = 0;
		_pVertData[ vertIndex ].vert.x = x1;
		_pVertData[ vertIndex ].vert.y = y1;
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;

		vertIndex++;
		x = 0;
		y = 1;
		_pVertData[ vertIndex ].vert.x = x2;
		_pVertData[ vertIndex ].vert.y = y2;
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;

		vertIndex++;
		x = 1;
		y = 1;
		_pVertData[ vertIndex ].vert.x = x3;
		_pVertData[ vertIndex ].vert.y = y3;
		_pVertData[ vertIndex ].tex.x = tex.x[ x ];
		_pVertData[ vertIndex ].tex.y = tex.y[ y ];
		_pVertData[ vertIndex ].colour.r = col.r;
		_pVertData[ vertIndex ].colour.g = col.g;
		_pVertData[ vertIndex ].colour.b = col.b;
		_pVertData[ vertIndex ].colour.a = col.a;
		
		
		_pFaceData[ faceIndex + 0 ] = _numVerts + 0;
		_pFaceData[ faceIndex + 1 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 2 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 3 ] = _numVerts + 1;
		_pFaceData[ faceIndex + 4 ] = _numVerts + 2;
		_pFaceData[ faceIndex + 5 ] = _numVerts + 3;

		_numVerts += 4;
		_numFaces += 2;

	}
	
}



void RenderBuffer::Render()
{
	glEnableClientState(GL_VERTEX_ARRAY);	
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glVertexPointer( 2, GL_FLOAT, _stride, &_pVertData->vert );
	glTexCoordPointer( 2, GL_FLOAT, _stride, &_pVertData->tex );
	glColorPointer( 4, GL_FLOAT, _stride, &_pVertData->colour );

	glDrawElements( GL_TRIANGLES, _numFaces * 3, GL_UNSIGNED_SHORT, _pFaceData );

	Reset();
}

#endif