//
//  BL2DDemoViewController.m
//  BL2DDemo
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BL2DDemoViewController.h"
#import "EAGLView.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface BL2DDemoViewController ()
@property (nonatomic, retain) EAGLContext *context;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation BL2DDemoViewController

@synthesize animating, context;

#pragma mark -
#pragma mark BL2D various data

static int tilemapWidth = 4;
static int tilemapHeight = 5;

static int tilemapArray[4 * 5] = 
{
	// this is the simulated contents of memory - tilemap data 
	'S', 'C', 'O', 'T',
	'T',   5,   6,   7,
	10,   11,  12,  13,
	14,   15,  16,  17,
	18,   19,  20,  21
};

static int tilemapOrdering[ 4 * 5 ] = 
{
	// this is how the memory gets mapped to the screen
	// this should not reference outside of 0..[4*6] or segfault
	3,	12,	6,	0,
	3,	13,	7,	1,
	3,	14,	8,	2,
	3,	15,	9,	3,
	0,	 1,	2,	4
};


#pragma mark -
#pragma mark BL2D interface stuff

- (void)startupBL2DEngine
{
	// BL2D addition - create our BL2D instance
	bl2de = [[BL2D alloc] init];
	[bl2de retain];
	
	// load the two graphics banks.  (only two banks for now.)
	[bl2de loadGraphicsBank:kGraphicsBank_Tilemap withPng:@"graphics1.png"];
	[bl2de loadGraphicsBank:kGraphicsBank_Sprite withPng:@"graphics2.png"];
}


- (void) renderTilemap
{
	// there's a lot in here, but it's mostly just being silly
	
	// junk to make the middle one get bigger and smaller for fun
	static BOOL bigger = YES;
	static float scale = 1.0;
	
	if( bigger ) {
		scale += 0.02;
		
		if( scale > 10.0 ) {
			bigger = NO;
		}
	} else {
		scale -= 0.02;
		if( scale < 0.2 ) {
			bigger = YES;
		}
	}
	
	// draw the top left one
	// this one uses the 'tilemapOrdering' to determine placement of the tiles.
	bl2de.tsc = 1.0; // scale
	bl2de.txO = 0.0; // x start pos
	bl2de.tyO = 0.0; // y start pos
	[bl2de renderTilemap:tilemapArray xTiles:tilemapWidth yTiles:tilemapHeight usingOrdering:tilemapOrdering];
	
	// draw the random one, spinning around the center.
	bl2de.txO = 160 + 100 * sin( scale );
	bl2de.tyO = 240 + 100 * cos( scale );
	[bl2de renderTilemap:NULL /* NULL for random tiles */ xTiles:10 yTiles:10];
	
	// draw the scaling one, which uses the raw memory as if it was the buffer itself.
	bl2de.tsc = scale;
	bl2de.txO = 50.0;
	bl2de.tyO = 50.0;
	[bl2de renderTilemap:tilemapArray xTiles:tilemapWidth yTiles:tilemapHeight];
	
	// apply the tilemap
	[bl2de renderTilemapApply];
}


- (void) renderSprites
{
	// increasingly larger sprites
	static int xx = 0; // junk counter to fly through sprites
	
	[bl2de renderSprite:1 x:50 y:50];
	[bl2de renderSprite:3 x:100 y:100];
	[bl2de renderSprite:4 x:150 y:150];
	[bl2de renderSprite:5 x:200 y:200];
	[bl2de renderSprite:(xx++)&0x01f x:300 y:300];
	
	
	// stupid brute force animation
	static int crocFrameTimer = 3;
	static unsigned int crocframe = 21;
	static float crocX = -16.0, crocY = 240;
	if( crocFrameTimer-- <= 0 ) {
		crocframe++; if ( crocframe > 23 ) { crocframe = 21; }
		crocFrameTimer = 3;
	}
	crocX += 3; if ( crocX > 336 ) { crocX = -16; }
	crocY += -2 + rand() % 5;
	
	// keep the crocodile on screen
	if( crocY < 140 ) crocY = 140;
	if( crocY > 340 ) crocY = 340;
	
	// draw the crocodile to the buffer
	[bl2de renderSprite:crocframe x:crocX y:crocY];
	
	// swarm of things around him
	[bl2de renderSprite:crocframe+1 x:crocX-32+rand()%64 y:crocY-32+rand()%64];
	[bl2de renderSprite:crocframe+2 x:crocX-32+rand()%64 y:crocY-32+rand()%64];
	[bl2de renderSprite:crocframe+3 x:crocX-32+rand()%64 y:crocY-32+rand()%64];
	[bl2de renderSprite:crocframe+4 x:crocX-32+rand()%64 y:crocY-32+rand()%64];
	
	// render the sprite layer
	[bl2de renderSpriteApply];
}


#pragma mark -
#pragma mark view startup and shutdown stuff

- (void)awakeFromNib
{
	// BL2D - Force an OpenGLES 1 context
    EAGLContext *aContext = nil; // [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!aContext)
    {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2)
        [self loadShaders];
	
	// BL2D - start the engine
	[self startupBL2DEngine];
    
    animating = FALSE;
    displayLinkSupported = FALSE;
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
}

- (void)dealloc
{	
	// BL2D addition
	[bl2de release];
	
	if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


#pragma mark -
#pragma mark Animation stuff


- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
            */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

#pragma mark -
#pragma mark render graphics to the screen and stuff

- (void)drawFrame
{	
    [(EAGLView *)self.view setFramebuffer];
	
	// start a new frame (clear the screen)
	[bl2de renderFrameStart];
	
	// BL2D addition
	[self renderTilemap];
	[self renderSprites];
    
    [(EAGLView *)self.view presentFramebuffer];
}



#pragma mark -
#pragma mark GLES2 stuff that we're ignoring anyway.


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

@end
