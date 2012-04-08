//
//  RFOpenGLView.h
//
//  Created by Ross Franklin on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreVideo/CoreVideo.h>

@interface RFOpenGLView : NSOpenGLView {
@private
	CVDisplayLinkRef _displayLink;
	CFTimeInterval _deltaTime;
}

@property (readonly) CFTimeInterval deltaTime;

- (void)animate;
- (void)drawFrame;

@end
