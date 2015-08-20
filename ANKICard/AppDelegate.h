//
//  AppDelegate.h
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioServices.h>
#import "INAppStoreWindow.h"
#import "INWindowButton.h"
#import "KGNoise.h"

@interface AppDelegate : NSWindow <NSApplicationDelegate,NSSpeechSynthesizerDelegate,NSTextViewDelegate> {
    SystemSoundID start, up, exit;
    NSInteger keysize;
    NSMutableDictionary *dic;
    NSMutableArray *filelist, *keys;
    NSString *ans, *now_setFile, *fixed, *status, *copy;
    NSSpeechSynthesizer *speech;
    BOOL isVoice;
}

@property (weak) IBOutlet INAppStoreWindow *window;
@property (weak) IBOutlet KGNoiseRadialGradientView *View;
@property (weak) IBOutlet NSButton *decrement;
@property (weak) IBOutlet NSButton *increment;
@property (unsafe_unretained) IBOutlet NSTextView *textview;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSTextField *pc;
@property (weak) IBOutlet NSButton *play;
@property (weak) IBOutlet NSMenu *filemenu;
@property (weak) IBOutlet KGNoiseRadialGradientView *barview;
@property (weak) IBOutlet NSSegmentedCell *bfbutton;

- (void)fontsizeincrement;
- (void)fontsizedecrement;
- (void)pushtoback;
- (void)pushtonext;
- (void)CopyOntextView;

@end

