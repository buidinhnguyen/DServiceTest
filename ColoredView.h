//
//  ColoredView.h
//  Flow
//
//  Created by Trung Nguyen on 11/25/13.
//  Copyright (c) 2013 LeftCoastLogic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColoredView : NSControl

@property (strong, nonatomic) NSColor *backgroundColor;

- (void) changeFrame:(NSRect)frame;

//- (id)initWithFrame:(NSRect)frame andCornerRadius:(float) cornerRadius;

//- (NSImage *) imageRepresentation;

@end
