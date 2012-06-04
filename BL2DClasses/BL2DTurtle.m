//
//  BL2DTurtle.m
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
#import "BL2DTurtle.h"
#import "BL2DPoly.h"


// BEGIN SIN.C
float _sine_table[SINLUT_MAX];

void init_sine_table(void)
{
	int i;
	
	for(i = 0; i < SINLUT_MAX; i++)
	{
		_sine_table[i] = sin(i * (360.0 / (float)(SINLUT_MAX)) * DEG2RAD);
	}
}

// END SIN.C



@implementation BL2DTurtle


#pragma mark - class stuff

-(id)init
{
	self = [super init];
    if (self)
    {
		init_sine_table();
        turtleStack = 0;
		[self reset];
	}
	return self;	
}

-(id)initWithRenderable:(id)renderableParam
{
    
    self = [super init];
    if( self )
    {
        init_sine_table();
        theRenderable = renderableParam;
        turtleStack = 0;
        [self reset];
    }
    return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"Turtle:{ x:%f y:%f  sx:%f sy:%f  a:%f  c:%f,%f,%f,%f }",
			turtle[turtleStack].x, turtle[turtleStack].y,
			turtle[turtleStack].scalex, turtle[turtleStack].scaley,
			turtle[turtleStack].angle,
			turtle[turtleStack].r, turtle[turtleStack].g, turtle[turtleStack].b, turtle[turtleStack].a ];
}

#pragma mark - starters

-(void) home
{
	turtle[turtleStack].x = 0;
	turtle[turtleStack].y = 0;
	turtle[turtleStack].angle = 0;
	turtle[turtleStack].scalex = 1;
	turtle[turtleStack].scaley = 1;
	[self turn:0];
}


-(void) reset
{
    turtleStack = 0;
	[self home];
	turtle[turtleStack].r = 1;
	turtle[turtleStack].g = 1;
	turtle[turtleStack].b = 1;
	turtle[turtleStack].a = 1;
    
    turtleStack = 0;
}

#pragma mark - stack

-(int) push
{
    if( turtleStack >= kTurtleStackMax ) {
        NSLog( @"TURTLE ERROR: Max stack reached! FIX THIS BEFORE DEPLOYING!" );
        return 0;
    }
    
    // copy current turtle to the next one
    turtle[turtleStack+1].x = turtle[turtleStack].x;
    turtle[turtleStack+1].y = turtle[turtleStack].y;
    turtle[turtleStack+1].scalex = turtle[turtleStack].scalex;
    turtle[turtleStack+1].scaley = turtle[turtleStack].scaley;
    turtle[turtleStack+1].angle = turtle[turtleStack].angle;
    turtle[turtleStack+1].xcos = turtle[turtleStack].xcos;
    turtle[turtleStack+1].xsin = turtle[turtleStack].xsin;
    turtle[turtleStack+1].ycos = turtle[turtleStack].ycos;
    turtle[turtleStack+1].ysin = turtle[turtleStack].ysin;
    turtle[turtleStack+1].r = turtle[turtleStack].r;
    turtle[turtleStack+1].g = turtle[turtleStack].g;
    turtle[turtleStack+1].b = turtle[turtleStack].b;
    turtle[turtleStack+1].a = turtle[turtleStack].a;

    // advance the stack
    turtleStack++;
    return 1;
}

-(void) pop
{
    if( turtleStack <= 0 ) {
        // overpopped
        turtleStack = 0;
        return;
    }
    
    // just move the index. everything will access it properly
    turtleStack--;
}

#pragma mark - setters

-(void) set_colorR:(float)rr G:(float)gg B:(float)bb A:(float)aa
{
	turtle[turtleStack].r = rr;
	turtle[turtleStack].g = gg;
	turtle[turtleStack].b = bb;
	turtle[turtleStack].a = aa;
}


-(void) set_colorR:(float)rr G:(float)gg B:(float)bb
{
	turtle[turtleStack].r = rr;
	turtle[turtleStack].g = gg;
	turtle[turtleStack].b = bb;
	turtle[turtleStack].a = 1.0;
}

-(float) getR { return turtle[turtleStack].r; }
-(float) getG { return turtle[turtleStack].g; }
-(float) getB { return turtle[turtleStack].b; }
-(float) getA { return turtle[turtleStack].a; }

-(void) turn:(TURTLE_FLOAT) addangle
{
	TURTLE_FLOAT angle = turtle[turtleStack].angle += addangle;
	
	turtle[turtleStack].ysin = SIN(angle);
	turtle[turtleStack].ycos = COS(angle);
	turtle[turtleStack].xsin = SIN(angle + 90);
	turtle[turtleStack].xcos = COS(angle + 90);
	
	turtle[turtleStack].angle = angle;
}


-(void) set_angle:(TURTLE_FLOAT) angle
{
	turtle[turtleStack].angle = 0;
	[self turn:angle];
}


-(void) set_posX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y
{
	turtle[turtleStack].x = x * turtle[turtleStack].scalex;
	turtle[turtleStack].y = y * turtle[turtleStack].scaley;
}


-(void) set_scale:(TURTLE_FLOAT) scale
{
	turtle[turtleStack].scalex = scale;
	turtle[turtleStack].scaley = scale;
}

-(void) set_scalex:(TURTLE_FLOAT) scale
{
	turtle[turtleStack].scalex = scale;
}

-(void) set_scaley:(TURTLE_FLOAT) scale
{
	turtle[turtleStack].scaley = scale;
}


-(void) transX:(TURTLE_FLOAT)x Y:(TURTLE_FLOAT)y
{
	TURTLE_FLOAT xoff, yoff;
	
	x *= turtle[turtleStack].scalex;
	y *= turtle[turtleStack].scaley;
	
	xoff = (turtle[turtleStack].ysin * y + turtle[turtleStack].xsin * x);
	yoff = -(turtle[turtleStack].ycos * y + turtle[turtleStack].xcos * x);
	
	turtle[turtleStack].x += xoff;
	turtle[turtleStack].y += yoff;
}

-(void) move:(TURTLE_FLOAT) amount
{
	[self transX:0 Y:amount];
}



-(void) point_atX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y
{
	TURTLE_FLOAT a = (atan2(turtle[turtleStack].y - y, turtle[turtleStack].x - x) * RAD2DEG) - 90;
	[self set_angle:a];
}

-(TURTLE_FLOAT) angle_toX:(TURTLE_FLOAT) x Y:(TURTLE_FLOAT) y
{
	TURTLE_FLOAT a = (atan2(turtle[turtleStack].y - y, turtle[turtleStack].x - x) * RAD2DEG) - 90;
	
	a = fmod((a - turtle[turtleStack].angle), 360);
	
	if(a >= 180) a = -(360 - a);
	else if (a <= -180) a = 360 + a;
	
	return a;
}

#pragma mark - accessorificators

-(TURTLE_FLOAT) turtle_dx
{
	return -turtle[turtleStack].xcos;
}

-(TURTLE_FLOAT) turtle_dy
{
	return -turtle[turtleStack].xsin;
}

-(TURTLE_FLOAT) getX
{
	return turtle[turtleStack].x;
}

-(TURTLE_FLOAT) getY
{
	return turtle[turtleStack].y;
}

#pragma mark - poly applicators

-(int) applyPoint
{
    BL2DPoly * p = theRenderable;
    if( !p ) return 0;
    
    [p setColorR:(GLubyte) (turtle[turtleStack].r * 255.0) 
               G:(GLubyte) (turtle[turtleStack].g * 255.0) 
               B:(GLubyte) (turtle[turtleStack].b * 255.0)
               A:(GLubyte) (turtle[turtleStack].a * 255.0)];
    
    [p addX:turtle[turtleStack].x Y:turtle[turtleStack].y];
    
    return 0;
}

-(int) applyColor
{
    BL2DPoly * p = theRenderable;
    if( !p ) return 0;
    
    [p setColorR:(GLubyte) (turtle[turtleStack].r * 255.0) 
               G:(GLubyte) (turtle[turtleStack].g * 255.0) 
               B:(GLubyte) (turtle[turtleStack].b * 255.0)
               A:(GLubyte) (turtle[turtleStack].a * 255.0)];
    
    return 0;
}

@end
