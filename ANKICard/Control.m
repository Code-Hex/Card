//
//  Control.m
//  ANKICard
//
//  Created by CodeHex on 2015/07/28.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//


#import "Control.h"

@implementation EventDelegatingView

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {return YES;}

// The following two methods allow a view to accept key input events. (literally they say, YES, please send me those events if I'm the center of attention.)
- (BOOL)acceptsFirstResponder {return YES;}
- (BOOL)canBecomeKeyView {return YES;}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self.fillColor set];
    NSRectFill(self.bounds);
    
    [self.strokeColor set];
    NSFrameRect(self.bounds);
}

// Notice these don't do anything but call the eventDelegate. I could do whatever here, but I didn't.
// The NICE thing about delgation is, the originating object stays in control of it sends to its delegate.
// However, true to the meaning of the word 'delegate', once you pass something to the delegate, you have delegated some decision making power to that delegate object and no longer have any control (if you did, you might have a bad code smell in terms of the delegation design pattern.)
- (void)mouseDown:(NSEvent *)theEvent
{
    [self.eventDelegate view:self didHandleEvent:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent
{
    [self.eventDelegate view:self didHandleEvent:theEvent];
    NSLog(@"Down!!");
}

@end