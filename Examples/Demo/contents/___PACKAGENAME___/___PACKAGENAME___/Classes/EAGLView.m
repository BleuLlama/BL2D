//
//  EAGLView.m
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 9/18/10 - 7/18/17
//  Copyright 2010-2017 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"

@interface EAGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation EAGLView

@synthesize framebufferWidth, framebufferHeight;
@synthesize context;
@synthesize defaultFramebuffer;
@synthesize colorRenderbuffer;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self)
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
		
		// BL2D Change: color format changed to RGB565
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        // addition for retina
        if([[UIScreen mainScreen] respondsToSelector: NSSelectorFromString(@"scale")])
        {
            if([self respondsToSelector: NSSelectorFromString(@"contentScaleFactor")])
            {
                self.contentScaleFactor = [[UIScreen mainScreen] scale];
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];
    //[super dealloc]; // compiler does this now
}


- (void)setTheContext:(EAGLContext *)newContext
{
    if (self.context != newContext)
    {
        [self deleteFramebuffer];
        
        self.context = newContext;
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    GLuint temp;
    
    if (self.context && !self.defaultFramebuffer)
    {
        [EAGLContext setCurrentContext:self.context];
        
        // Create default framebuffer object.
        temp = self.defaultFramebuffer;
        glGenFramebuffers(1, &temp);
        self.defaultFramebuffer = temp;
        glBindFramebuffer(GL_FRAMEBUFFER, self.defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        temp = self.colorRenderbuffer;
        glGenRenderbuffers(1, &temp);
        self.colorRenderbuffer = temp;
        glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    GLuint temp;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (self.defaultFramebuffer)
        {
            temp = self.defaultFramebuffer;
            glDeleteFramebuffers(1, &temp);
            self.defaultFramebuffer = 0;
        }
        
        if (self.colorRenderbuffer)
        {
            temp = self.colorRenderbuffer;
            glDeleteRenderbuffers(1, &temp);
            self.colorRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (!self.defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, self.defaultFramebuffer);
        
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

@end
