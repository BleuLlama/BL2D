//
//  EAGLView.h
//  ___PACKAGENAME___
//
//  Created by Scott Lawrence on 9/18/10 - 7/18/17
//  Copyright 2010-2017 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{
}

// The pixel dimensions of the CAEAGLLayer.
@property (nonatomic) GLint framebufferWidth;
@property (nonatomic) GLint framebufferHeight;

// The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
@property (nonatomic, assign) GLuint defaultFramebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;


// the graphics context
@property (nonatomic, retain) EAGLContext *context;

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
- (void)setTheContext:(EAGLContext *)newContext;

@end
