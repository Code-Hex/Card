//
//  Control.h
//  ANKICard
//
//  Created by CodeHex on 2015/07/28.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol EventDelegatingViewDelegate <NSObject>

- (void)view:(NSView *)aView didHandleEvent:(NSEvent *)anEvent;

@end

IB_DESIGNABLE
@interface EventDelegatingView : NSView

@property IBOutlet id<EventDelegatingViewDelegate> eventDelegate;
@property IBInspectable NSColor *fillColor;
@property IBInspectable NSColor *strokeColor;

@end