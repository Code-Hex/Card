//
//  AppDelegate.h
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSWindow <NSApplicationDelegate> {
    NSInteger keysize;
    NSDictionary *dic;
    NSArray *keys;
    NSString *str;
    NSString *fixed;
}
@property (weak) IBOutlet NSButton *btn;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSButton *back;
@property (weak) IBOutlet NSButton *decrement;
@property (weak) IBOutlet NSButton *increment;

@end

