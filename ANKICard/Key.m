//
//  Key.m
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

@implementation Key
#pragma mark    -   NSResponder

- (void)keyDown:(NSEvent *)theEvent
{
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    
    switch (code)
    {
        case NSUpArrowFunctionKey:
        {
            break;
        }
        case NSDownArrowFunctionKey:
        {
            break;
        }
        case NSLeftArrowFunctionKey:
        {
            NSLog(@"Hello!");
            break;
        }
        case NSRightArrowFunctionKey:
        {
            NSLog(@"Hello!");
            break;
        }
    }
}

@end
