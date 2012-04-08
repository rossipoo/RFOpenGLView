//
//  RFOpenGLView.m
//
//  Created by Ross Franklin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RFOpenGLView.h"

@implementation RFOpenGLView

@synthesize deltaTime = _deltaTime;

- (CVReturn)getFrameForTime:(const CVTimeStamp *)outputTime {
	double deltaTime = 1.0 / (outputTime->rateScalar * (double)outputTime->videoTimeScale / (double)outputTime->videoRefreshPeriod);
	_deltaTime = deltaTime;
	
	[self animate];
	[self drawRect:[self bounds]];
	
	return kCVReturnSuccess;
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext) {
	@autoreleasepool {
		return [(__bridge RFOpenGLView *)displayLinkContext getFrameForTime:outputTime];
	}
}

- (id)initWithFrame:(NSRect)frameRect {
	NSOpenGLPixelFormatAttribute attr[] = {
		NSOpenGLPFAWindow,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 24,
		NSOpenGLPFAAlphaSize, 8,
		NSOpenGLPFADepthSize, 8,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFASingleRenderer,
		0
	};
	
	NSOpenGLPixelFormat *pix = [[NSOpenGLPixelFormat alloc] initWithAttributes:attr];
	
	self = [super initWithFrame:frameRect pixelFormat:pix];
	if (self) {
		GLint swapInt = 1;
		[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
		
		CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
		CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
		
		// Display link:
		CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
		CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
		CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback, (__bridge void *)self);
	}
	
	return self;
}

- (void)awakeFromNib {
	NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.6 constant:0];
	[self addConstraint:constraint];
}

- (void)dealloc {
	CVDisplayLinkStop(_displayLink);
	CVDisplayLinkRelease(_displayLink);
}

- (void)animate {
	// Animate
}

- (void)prepareOpenGL {
	if ([self lockFocusIfCanDraw]) {
		[[self openGLContext] makeCurrentContext];
		CGLLockContext([[self openGLContext] CGLContextObj]);
		
		[[self openGLContext] update];
		
		CGLUnlockContext([[self openGLContext] CGLContextObj]);
		[self unlockFocus];
	}
	
	CVDisplayLinkStart(_displayLink);
}

- (void)reshape {
	if ([self lockFocusIfCanDraw]) {
		[[self openGLContext] makeCurrentContext];
		CGLLockContext([[self openGLContext] CGLContextObj]);
		
		[[self openGLContext] update];
		
		CGLUnlockContext([[self openGLContext] CGLContextObj]);
		[self unlockFocus];
	}
}

- (void)drawRect:(NSRect)dirtyRect {
	if ([self lockFocusIfCanDraw]) {
		[[self openGLContext] makeCurrentContext];
		CGLLockContext([[self openGLContext] CGLContextObj]);
		
		[self drawFrame];
		[[self openGLContext] flushBuffer];
		
		CGLUnlockContext([[self openGLContext] CGLContextObj]);
		[self unlockFocus];
	}
}

- (void)drawFrame {
		glClearColor(sin(2.0 * CFAbsoluteTimeGetCurrent()),
					 0,
					 0, 0);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

@end