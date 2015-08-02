//
//  AppDelegate.h
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioServices.h>

@interface AppDelegate : NSWindow <NSApplicationDelegate> {
    SystemSoundID start, up, exit;
    NSInteger keysize;
    NSDictionary *dic;
    NSMutableArray *keys;
    NSString *str;
    NSString *fixed;
}

@property (weak) IBOutlet NSButton *btn;
@property (weak) IBOutlet NSButton *back;
@property (weak) IBOutlet NSButton *decrement;
@property (weak) IBOutlet NSButton *increment;
@property (unsafe_unretained) IBOutlet NSTextView *label;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *pc;


@end

