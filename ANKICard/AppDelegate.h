//
//  AppDelegate.h
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioServices.h>

@interface AppDelegate : NSWindow <NSApplicationDelegate,NSSpeechSynthesizerDelegate,NSMenuDelegate> {
    SystemSoundID start, up, exit;
    NSInteger keysize;
    NSMutableDictionary *dic;
    NSMutableArray *filelist;
    NSMutableArray *keys;
    NSString *ans;
    NSString *fixed;
    NSSpeechSynthesizer *speech;
}

@property (weak) IBOutlet NSButton *btn;
@property (weak) IBOutlet NSButton *back;
@property (weak) IBOutlet NSButton *decrement;
@property (weak) IBOutlet NSButton *increment;
@property (unsafe_unretained) IBOutlet NSTextView *label;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *pc;
@property (weak) IBOutlet NSButton *play;
@property (weak) IBOutlet NSMenu *filemenu;



@end

