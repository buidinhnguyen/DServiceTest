//
//  ColoredView.m
//  Flow
//
//  Created by Trung Nguyen on 11/25/13.
//  Copyright (c) 2013 LeftCoastLogic. All rights reserved.
//

#import "ColoredView.h"

@implementation ColoredView

@synthesize backgroundColor;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroundColor = [NSColor clearColor]; //[[NSColor whiteColor] colorWithAlphaComponent:0.3];
    }
    return self;
}

- (BOOL) isFlipped
{
    return YES;
}


- (void) changeFrame:(NSRect)frame
{
    self.frame = frame;
}

- (void) setBackgroundColor:(NSColor *)backgroundColorParam
{
    backgroundColor = backgroundColorParam;
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    // Drawing code here.
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.bounds];
    [self.backgroundColor setFill];
    [path fill];
}

@end
