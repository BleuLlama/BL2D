//
//  BL2DTurtle.h
//  Basic2DEngine
//
//  Copyright 2012 Scott Lawrence. All rights reserved.
//

// Many thanks to Paul Pridham, madgarden on Freenode IRC for code, pointers, suggestions and ideas and original code
// Supported by Trilobyte Games, as it was ported to Obj-C in its current form under contract for them


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



#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import <Foundation/Foundation.h>



////////////////////////////////////////////////////////////////////////////////
// BEGIN SIN.H
#ifndef M_PI
#define M_PI            3.141592654
#endif

#ifndef DEG2RAD
#define DEG2RAD                 (M_PI / 180.0)
#endif

#ifndef RAD2DEG
#define RAD2DEG                 (180.0 / M_PI)
#endif

#define SINLUT_MAX      8192
#define SINSCALE        (SINLUT_MAX / 360.0)

#define SIN(a) _sine_table[((int)((a) * SINSCALE) & (SINLUT_MAX - 1))]
#define COS(a) _sine_table[((int)(((a) + 90) * SINSCALE) & (SINLUT_MAX - 1))]

extern float _sine_table[SINLUT_MAX];

void init_sine_table(void);

//END SIN.H
////////////////////////////////////////////////////////////////////////////////


typedef double TURTLE_FLOAT;

// Turtle
typedef struct
{
	TURTLE_FLOAT x, y;
	TURTLE_FLOAT scalex, scaley;
	TURTLE_FLOAT angle;
	TURTLE_FLOAT xcos, xsin, ycos, ysin;
	TURTLE_FLOAT r, g, b, a;
}TURTLEDATA;

#define kTurtleStackMax 16

@interface BL2DTurtle : NSObject {
	TURTLEDATA turtle[kTurtleStackMax];
    id theRenderable;
    
    int turtleStack;
}

-(id)init;
-(id)initWithRenderable:(id)renderableParam;


-(void) home;			// return to 0,0, rotation 0, scale 1.0
-(void) reset;			// same as home, but reset color too.


-(int) push;        // push the current turtle onto the stack, returns 0 if success
-(void) pop;        // pop the current turtle off the stack

-(void) turn:(TURTLE_FLOAT) addangle;						// accumulate angle

-(void) set_angle:(TURTLE_FLOAT) angle;						// set absolute angle
-(void) set_posX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y;		// set absolute position, scaled
-(void) set_scale:(TURTLE_FLOAT) scale;						// x,y scale
-(void) set_scalex:(TURTLE_FLOAT) scale;					// x scale
-(void) set_scaley:(TURTLE_FLOAT) scale;					// y scale

-(void) transX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y;			// translate to X,Y with current rotation
-(void) move:(TURTLE_FLOAT) amount;							// move forward

-(void) point_atX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y;			// make the turtle point towards X,Y
-(TURTLE_FLOAT) angle_toX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y;	// determine the angle to X,Y

-(TURTLE_FLOAT) turtle_dx;
-(TURTLE_FLOAT) turtle_dy;

-(TURTLE_FLOAT) getX;
-(TURTLE_FLOAT) getY;
-(float) getR;
-(float) getG;
-(float) getB;
-(float) getA;

-(void) set_colorR:(float)rr G:(float)gg B:(float)bb A:(float)aa;
-(void) set_colorR:(float)rr G:(float)gg B:(float)bb;

// applying them to the poly
-(int) applyPoint;
-(int) applyColor;
@end
