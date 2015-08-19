//
//  ANKITextView.m
//  ANKICard
//
//  Created by CodeHex on 2015/08/19.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import "ANKITextView.h"

@implementation NSTextView (ANKITextView)

- (void)keyDown:(NSEvent *)event
{
    AppDelegate *delegate = (AppDelegate *) [[NSApplication sharedApplication] delegate];
    
    NSInteger i = [event keyCode];
    NSUInteger modifierFlags = [event modifierFlags];
    switch(i) {
        case 126:	// up arrow
            [delegate fontsizeincrement];
            break;
        case 125:	// down arrow
            [delegate fontsizedecrement];
            break;
        case 124:	// right arrow
            [delegate pushtonext];
            break;
        case 123:	// left arrow
            [delegate pushtoback];
            break;
        default:
            if ((i == 8 || i == 7) && modifierFlags & NSCommandKeyMask)
                [delegate CopyOntextView];
            else if (i == 13 && modifierFlags & NSCommandKeyMask)
                [NSApp terminate:delegate];
            
            break;
    }
}

@end
