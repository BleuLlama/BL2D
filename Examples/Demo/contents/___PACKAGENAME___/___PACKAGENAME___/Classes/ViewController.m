//
//  ViewController.m
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 7/14/17.
//  Copyright © 2017 Scott Lawrence. All rights reserved.
//

#import "ViewController.h"
#import "BL2D.h"
#import "EAGLView.h"

#define kPreferredFPS (60)

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


@interface ViewController ()

@end


@implementation ViewController

@synthesize statusText;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self.view setBackgroundColor:[UIColor redColor]];
    [self.statusText setText:@"Ready!"];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@synthesize bl2de, animating;


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

@synthesize tilegfx, spritegfx, builtgfx, rawgfx;
@synthesize backgroundTiles, backgroundTiles2, raw;
@synthesize sprite0, sprite1, sprite2, sprite3;
@synthesize poly0, poly1;


#pragma mark - BL2D Setup

- (void)startupBL2DEngine
{
    EAGLView * v = (EAGLView *)self.view;
    
    // BL2D addition - create our BL2D instance
    self.bl2de = [[BL2D alloc] initWithEffectiveScreenWidth:v.framebufferWidth
                                                Height:v.framebufferHeight];
    
    // load the two graphics banks.  (only two banks for now.)
    self.tilegfx = [bl2de addPNGGraphics:@"graphics1" tilesWide:32 tilesHigh:8];
    self.spritegfx = [bl2de addPNGGraphics:@"graphics2" tilesWide:16 tilesHigh:4];
    self.builtgfx = [bl2de addPlistGraphics:@"test_sprites"];
    self.rawgfx = [bl2de addRawGraphicsW:150 H:256];
    
    // now load the tilemap to be used
    int tw, th;
    float sp;
    if( !isRetina && !isPad ) {
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
    self.sprite0 = [bl2de addSprite:self.spritegfx]; // from gridded texture
    self.sprite1 = [bl2de addSprite:self.spritegfx]; // from gridded texture
    self.sprite2 = [bl2de addSprite:self.spritegfx]; // from gridded texture
    self.sprite3 = [bl2de addSprite:self.builtgfx];  // from plist-texture
    
    // and try out some polygon stuff
    
    self.poly0 = [bl2de addPoly:30];                        // filled triangles
    self.poly1 = [bl2de addPoly:260 withDrawMode:GL_LINES]; // line segments
    
    self.raw = [bl2de addSprite:rawgfx];
}

/////////////////////////////////////////////////////////

#pragma mark -
#pragma mark view startup and shutdown stuff

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSLog( @"%s", __FUNCTION__ );
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
    
    [(EAGLView *)self.view setContext:self.context];
    [(EAGLView *)self.view setFramebuffer];
    
    if ([self.context API] == kEAGLRenderingAPIOpenGLES2)
        [self loadShaders];
    
    EAGLView * v = (EAGLView *)self.view;
    // set up our sizing flags
    isPad = NO;
    isRetina = NO;
    if( v.contentScaleFactor >= 2.0 ) {
        isRetina = YES;
    }
    if( v.framebufferHeight == 1024 && v.framebufferWidth == 768 ) { isPad = YES; }
    if( v.framebufferHeight == 1024*2 && v.framebufferWidth == 768*2 ) { isPad = YES; }
    
    
    
    // BL2D - start the engine
    [self startupBL2DEngine];
    
    self.animating = FALSE;
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
    self.bl2de = nil;
    
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
    
    self.context = nil;
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
    if ([EAGLContext currentContext] == self.context)
        [EAGLContext setCurrentContext:nil];
    self.context = nil;
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
            //[displayLink setFrameInterval:animationFrameInterval];
            [displayLink setPreferredFramesPerSecond:kPreferredFPS];
            
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

- (void)drawState0
{
    self.sprite0.active = NO;
    self.sprite1.active = NO;
    self.sprite2.active = NO;
    self.sprite3.active = NO;
    self.backgroundTiles.active = NO;
    self.backgroundTiles2.active = NO;
    self.poly0.active = NO;
    self.poly1.active = YES;
    self.raw.active = NO;
    
    
    // okay! have at it!
    EAGLView * v = (EAGLView *)self.view;
    
    [self.poly1 clearData];
    [self.poly1 setUseAlpha:NO];
    [self.poly1 setUseSmoothing:NO]; // doesn't look right anyway
    
    //self.poly1.spy = v.framebufferHeight/4;
    
    // experiment with the turtle
    
    [self.poly1.turtle set_colorR:1.0 G:1.0 B:0.0 A:1.0];
    
    
    [self.poly1.turtle set_posX:v.framebufferWidth/2 Y:v.framebufferHeight/2];
    for( int xx = 0; xx < 20 ; xx++ ) {
        [self.poly1.turtle set_angle:frameCount]; // make the whole thing rotate
        
        [self.poly1.turtle applyPoint];
        
        [self.poly1.turtle push]; // use the stack here, for fun.
        
        [self.poly1.turtle turn:xx*(360/20)];
        [self.poly1.turtle move:100.0];
        [self.poly1.turtle applyPoint];
        
        [self.poly1.turtle pop];
    }
    
    // and a "point north" for the heck of it
    [self.poly1.turtle reset];
    [self.poly1.turtle set_posX:v.framebufferWidth/2 Y:v.framebufferHeight/4];
    [self.poly1.turtle set_colorR:0.0 G:0.0 B:0.0];
    [self.poly1.turtle applyPoint];
    [self.poly1.turtle set_colorR:1.0 G:1.0 B:1.0];
    [self.poly1.turtle move:100];
    [self.poly1.turtle applyPoint];
    
    // now do some direct stuff.
    
    [self.poly1 setColorR:255 G:frameCount&255 B:[self.poly1 rand255]];
    
    int ts = 30;
    if( v.contentScaleFactor < 2.0 ) {
        [self.poly1 setTextSize:20];
        ts = 30;
    } else {
        // show that we can set this all by hand if we want to also
        [self.poly1 setTextHeight:40];
        [self.poly1 setTextWidth:20];
        [self.poly1 setTextKern:10];
        ts = 60;
    }
    [self.poly1 addText:@"Touch to advance" atX:0 atY:0];
    [self.poly1 addText:@"to next example." atX:0 atY:ts];
    
    do {
        [self.poly1 setRandomColor];
    } while ( [self.poly1 addRandomPointW:v.framebufferWidth H:v.framebufferHeight] > 0 );
}


- (void)drawState1
{
    static float an;
    static long index = 0;
    
    index++;
    an+= 0.5;
    
    self.sprite0.active = YES;
    self.sprite1.active = YES;
    self.sprite2.active = YES;
    self.sprite3.active = YES;
    self.backgroundTiles.active = NO;
    self.backgroundTiles2.active = NO;
    self.poly0.active = NO;
    self.poly1.active = NO;
    self.raw.active = NO;
    
    // draw the tilemaps and sprites
    [self.sprite0 setSpriteIndex:((int)index)>>3];
    self.sprite0.spx = 100;
    self.sprite0.spy = 100;
    self.sprite0.scale = 1.0 + 2.0 + (2.0 * cos( an/8 ));
    
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
    
    // sprite 2 will be the croc going the other way
    [self.sprite2 setSpriteIndex:crocframe];
    self.sprite2.spy = crocY + 50;
    self.sprite2.spx = v.framebufferWidth - crocX;
    self.sprite2.scale = 1.0;
    self.sprite2.flipX = YES;
    
    
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
}


- (void)drawState2
{
    self.sprite0.active = NO;
    self.sprite1.active = NO;
    self.sprite2.active = NO;
    self.sprite3.active = NO;
    
    self.backgroundTiles.active = YES;
    self.backgroundTiles2.active = YES;
    self.poly0.active = NO;
    self.poly1.active = NO;
    self.raw.active = NO;
    
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
    
}


- (void)drawState3
{
    self.sprite0.active = NO;
    self.sprite1.active = NO;
    self.sprite2.active = NO;
    self.sprite3.active = NO;
    self.backgroundTiles.active = NO;
    self.backgroundTiles2.active = NO;
    self.poly0.active = YES;
    self.poly1.active = NO;
    self.raw.active = NO;
    
    
    // okay! have at it!
    EAGLView * v = (EAGLView *)self.view;
    
    [self.poly0 clearData];
    [self.poly0 setUseAlpha:NO];
    
    int p=0;
    
    // fill the background with a gradient.
    [self.poly0 setColorR:0 G:0 B:0];
    p += [self.poly0 addX:0 Y:0];
    [self.poly0 setColorR:[self.poly0 rand255] G:[self.poly0 rand255] B:[self.poly0 rand255]];
    p += [self.poly0 addX:0 Y:v.framebufferHeight];
    p += [self.poly0 addX:v.framebufferWidth Y:v.framebufferHeight];
    
    p += [self.poly0 addX:v.framebufferWidth Y:v.framebufferHeight];
    [self.poly0 setColorR:0 G:0 B:0];
    p += [self.poly0 addX:v.framebufferWidth Y:0];
    p += [self.poly0 addX:0 Y:0];
    
    // manually add a square
#define kBoxSz  60
    // use the point functions
    [self.poly0 setColorR:255 G:0 B:0];
    p += [self.poly0 addX:20 Y:20];
    [self.poly0 setColorR:255 G:255 B:0];
    p += [self.poly0 addX:20 Y:20+kBoxSz];
    [self.poly0 setColorR:0 G:0 B:255];
    p += [self.poly0 addX:20+kBoxSz Y:20+kBoxSz];
    
    // use the triangle function
    [self.poly0 setColorR:255 G:255 B:255];
    p += [self.poly0 addTriangleX0:20 Y0:20 X1:20+kBoxSz Y1:20+kBoxSz X2:20+kBoxSz Y2:20];
    
    // and the rect.  Why not!
    [self.poly0 setColorR:0 G:255 B:255];
    p += [self.poly0 addRectangleX0:120 Y0:20 X1:120+kBoxSz Y1:20+kBoxSz];
    
    
    // add in some turtle fanciness
    
    [self.poly0.turtle set_posX:v.framebufferWidth/2 Y:v.framebufferHeight/2];
    [self.poly0.turtle set_angle:-frameCount/2]; // make the whole thing rotate
    
    [self.poly0.turtle push];  // store the center?
    // we're making triangles, so we need 3 points
    [self.poly0.turtle set_colorR:1.0 G:0.0 B:1.0];
    [self.poly0.turtle applyPoint];
    
    [self.poly0.turtle move:200];
    [self.poly0.turtle set_colorR:0.0 G:1.0 B:1.0];
    [self.poly0.turtle applyPoint];
    [self.poly0.turtle turn:78];
    [self.poly0.turtle move:142];
    [self.poly0.turtle set_colorR:0.0 G:1.0 B:0.0];
    [self.poly0.turtle applyPoint];
    
    // next, draw as many random triangles as we can
    do {
        [self.poly0 setRandomColor];
    } while ( [self.poly0 addRandomPointW:v.framebufferWidth H:v.framebufferHeight] > 0 );
    /*
     for( ; p<=(kTestNVerts-4) ; p+= 3 ) {
     [self.poly0 setRandomColor];
     [self.poly0 setColorR:255 G:255 B:0];
     [self.poly0 addRandomPointW:v.framebufferWidth H:v.framebufferHeight/2];
     [self.poly0 addRandomPointW:v.framebufferWidth H:v.framebufferHeight/2];
     [self.poly0 setRandomColor];
     [self.poly0 addRandomPointW:v.framebufferWidth H:v.framebufferHeight/2];
     }
     */
}

- (void)drawState4
{
    self.sprite0.active = NO;
    self.sprite1.active = NO;
    self.sprite2.active = NO;
    self.sprite3.active = NO;
    self.backgroundTiles.active = NO;
    self.backgroundTiles2.active = NO;
    self.poly0.active = NO;
    self.poly1.active = NO;
    self.raw.active = YES;
    
    self.raw.spy = 50;
    self.raw.spx = 50;
    self.raw.scale = 1.0;
    
    // some stuff to hack with the framebuffer on it
    size_t iw = self.raw.gfx.image_width;
    size_t ih = self.raw.gfx.image_height;
    GLubyte * imageData = self.raw.gfx.imageData;
    
    for( int y = 0 ; y < ih ; y++ )
    {
        int rv = [self.raw rand255];
        for( int x=0 ; x < iw ; x++ )
        {
            unsigned long p = ((y * iw) + x ) * 4;
            imageData[p+0] = (frameCount * 2) & 0x0ff; // R
            imageData[p+1] = (x+y)&0x0ff; // G
            imageData[p+2] = rv; // B
            imageData[p+3] = 0x0ff; // A
            
            p += 4;
        }
    }
    self.raw.gfx.isLiveEditable = YES;
    self.raw.gfx.changed = YES;
    
}


- (void)drawFrame
{
    
    [(EAGLView *)self.view setFramebuffer];
    
    // adjust for playState
    switch( playState % 5 ) {
        case( 0 ): [self drawState0]; break;
        case( 1 ): [self drawState1]; break;
        case( 2 ): [self drawState2]; break;
        case( 3 ): [self drawState3]; break;
        case( 4 ): [self drawState4]; break;
    }
    
    // and draw it all!
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


#pragma mark - Touch events

- (void) handleTouchAtPoint:(CGPoint)pt
{
    //NSLog( @"Touch at %f %f", pt.x, pt.y );
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    [self handleTouchAtPoint:pt];
    
    playState++;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    [self handleTouchAtPoint:pt];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    [self handleTouchAtPoint:pt];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
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
