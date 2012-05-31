//
//  ___PACKAGENAME___ViewController.m
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 9/18/10.
//  Copyright 2010-2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "___PACKAGENAME___ViewController.h"
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

@interface ___PACKAGENAME___ViewController ()
@property (nonatomic, retain) EAGLContext *context;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ___PACKAGENAME___ViewController

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

#ifdef NEVER
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
#endif


#pragma mark -
#pragma mark BL2D interface stuff

@synthesize tilegfx, spritegfx, builtgfx;
@synthesize backgroundTiles, backgroundTiles2, sprite0, sprite1, sprite2, sprite3; 

- (void)startupBL2DEngine
{
	// BL2D addition - create our BL2D instance
	EAGLView * v = (EAGLView *)self.view;
	bl2de = [[BL2D alloc] initWithEffectiveScreenWidth:v.framebufferWidth
												Height:v.framebufferHeight];
	[bl2de retain];
	
	// load the two graphics banks.  (only two banks for now.)
	self.tilegfx = [bl2de addPNGGraphics:@"graphics1" tilesWide:32 tilesHigh:8];
	self.spritegfx = [bl2de addPNGGraphics:@"graphics2" tilesWide:16 tilesHigh:4];
    self.builtgfx = [bl2de addPlistGraphics:@"test_sprites"];

	// now load the tilemap to be used

    int tw, th;
    float sp;
    if( v.contentScaleFactor < 2.0 ) {
        // old
        tw = v.framebufferWidth/8;
        th = v.framebufferHeight/8;
        sp = 0.0;
    } else {
        // retina
        tw = 20;
        th = 20;
        sp = 200.0;
    }
    
    // background tiles 2 is bottom layer
    self.backgroundTiles2 = [bl2de addTilemapLayerUsingGraphics:self.tilegfx
													  tilesWide:tw
													  tilesHigh:th];
    self.backgroundTiles2.spx = sp; // adjust start point
    self.backgroundTiles2.spy = sp; // adjust start point
	
    // next is the tilemap above that
	self.backgroundTiles = [bl2de addTilemapLayerUsingGraphics:self.tilegfx
													 tilesWide:tilemapWidth 
													 tilesHigh:tilemapHeight];

	// and the sprite to be used
	self.sprite0 = [bl2de addSprite:self.spritegfx];
	self.sprite1 = [bl2de addSprite:self.spritegfx];
	self.sprite2 = [bl2de addSprite:self.spritegfx];
    
	self.sprite3 = [bl2de addSprite:self.builtgfx];
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
    displayLinkSupported = FALSE; // probably unnecessary aince we're 3.1+
    animationFrameInterval = 1;
    displayLink = nil;
    animationTimer = nil;
    
    // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
    NSString *reqSysVer = @"3.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
        displayLinkSupported = TRUE;
    
    // fps display
    startTime = 0l;
    frameCount = 0l;
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
	static float an;
	static long index = 0;
	
	index++;
	an+= 0.5;
	
    [(EAGLView *)self.view setFramebuffer];
	
	// draw the tilemaps and sprites
	[self.sprite0 setSpriteIndex:index>>3];
	self.sprite0.spx = 100;
	self.sprite0.spy = 100;
	self.sprite0.scale = 1.0 + 2.0 + (2.0 * cos( an/8 ));
	self.sprite0.active = YES;
	
    EAGLView * v = (EAGLView *)self.view;
	
	// draw the walking crocodile
	static int crocFrameTimer = 3;
	static unsigned int crocframe = 21;
	static float crocX = -16.0, crocY = 240;
	if( crocFrameTimer-- <= 0 ) {
		crocframe++; if ( crocframe > 23 ) { crocframe = 21; }
		crocFrameTimer = 3;
	}
	crocX += 3; if ( crocX > v.framebufferWidth + 20 ) { crocX = -16; }
	crocY += -2 + rand() % 5;
	
	// keep the crocodile on screen
	if( crocY < 140 ) crocY = 140;
	if( crocY > 340 ) crocY = 340;

	[self.sprite1 setSpriteIndex:crocframe];
	self.sprite1.spy = crocY;
	self.sprite1.spx = crocX;
	self.sprite1.scale = 2.0;
	self.sprite1.active = YES;
	
	// sprite 2 will be the croc going the other way
	[self.sprite2 setSpriteIndex:crocframe];
	self.sprite2.spy = crocY + 50;
	self.sprite2.spx = v.framebufferWidth - crocX;
	self.sprite2.scale = 1.0;
	self.sprite2.flipX = YES;
	self.sprite2.active = YES;
    
    
    // sprite 3 will show off the plist-based graphics
    static int s3frame = 0;
    static int s3FrameTimer = 4;
    if( s3FrameTimer-- <= 0 ) {
        s3frame++;
        if( s3frame > 19 ) s3frame = 0;
        s3FrameTimer = 4;
    }
    
    [self.sprite3 setSpriteIndex:s3frame];
    self.sprite3.spx = 200;
    self.sprite3.spy = 100;
    self.sprite3.scale = 2.0;
    self.sprite3.active = YES;
    
	
	// set up the background tilemap
	[self.backgroundTiles copyNewTilesBuffer:tilemapArray];
	
    [self.backgroundTiles commitChanges];	// regenerate the tilemap
	self.backgroundTiles.scale = 4.0;
	
    // random chars
	[self.backgroundTiles2 fillWithRandom];
    // render text
    [self.backgroundTiles2 drawTextAtX:1 atY:1 txt:@"Hello!"];
    [self.backgroundTiles2 drawTextAtX:2 atY:30 txt:@"Hello!"];
    
    [self.backgroundTiles2 drawCenteredTextAt:3 txt:@"Centered."];

    [self.backgroundTiles2 drawLeftTextAtX:1 atY:5 txt:@"Left!"];

	[self.backgroundTiles2 commitChanges];
	
	[bl2de render];
    [(EAGLView *)self.view presentFramebuffer];
    
    
    // update the FPS display
    long currentTime = time( NULL );
    if( frameCount == 0 || currentTime == startTime ) {
        startTime = currentTime;
    } else {
        fpsLabel.text = [NSString stringWithFormat:@"%0.1f fps", (float)frameCount/(float)(currentTime - startTime ) ];
    }
    frameCount++;
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
