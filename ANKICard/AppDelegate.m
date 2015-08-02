//
//  AppDelegate.m
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

static int i = 0;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud floatForKey:@"fontsize"]) {
        [ud setFloat:12.0 forKey:@"fontsize"];
        [ud synchronize];
    }
    
    [_label setTextContainerInset:NSMakeSize(0, 10)]; // Padding NSTextView
    
    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"test" ofType:@"plist"];
    
    NSArray *items = [NSArray arrayWithObjects:@"coin", @"1up", @"exit", nil];
    
    for (NSString *filename in items) {
        NSString *sound_path = [bundle pathForResource:filename ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:sound_path];
        
        if([filename isEqualToString:items[0]])
            AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &start);
        else if([filename isEqualToString:items[1]])
            AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &up);
        else
            AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &exit);
    }
    
    
    dic = [NSDictionary dictionaryWithContentsOfFile:path];
    keys = [[dic allKeys] mutableCopy];
    keysize = [keys count];
    
    [self shuffle];
    [_progress setMaxValue:keysize];
    AudioServicesPlaySystemSound(start);
    
    str = keys[i]; i++;
    fixed = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [self.window makeFirstResponder:self];
    
    [_label setFont:[NSFont systemFontOfSize:fontsize]];
    [_btn setTitle:@"Answer"];
    [_back setTitle:@"Back"];
    [_increment setTitle:@"+"];
    [_decrement setTitle:@"-"];
    [_pc setStringValue:[NSString stringWithFormat:@"0 %%"]];
    _back.hidden = true;
    
    [_label setString:fixed];
    
    [_btn setAction:@selector(pushtonext:)];
    [_back setAction:@selector(pushtoback:)];
    [_increment setAction:@selector(fontsizeincrement:)];
    [_decrement setAction:@selector(fontsizedecrement:)];
    
}

-(void)fontsizeincrement:(id)sender {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    
    if ((fontsize + 1) < 26)
        fontsize += 1;
    
    [self store:fontsize data:ud];
}

-(void)fontsizedecrement:(id)sender {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    
    if (8 < (fontsize - 1))
        fontsize -= 1;
    [self store:fontsize data:ud];
}

-(void)store:(CGFloat)fontsize data:(NSUserDefaults*)ud {
    [_label setFont:[NSFont systemFontOfSize:fontsize]];
    [ud setFloat:fontsize forKey:@"fontsize"];
    [ud synchronize];
    [self.window makeFirstResponder:self];
}

-(void)pushtonext:(id)sender {
    
    if ([_btn.title isEqualToString:@"Next"]) {
        i++;
        if (!(i % keysize)) {
            [self shuffle];
            AudioServicesPlaySystemSound(up);
            i = 0;
            [_progress setDoubleValue:i];
        } else [_progress incrementBy:1.0];
        
        str = keys[i];
        fixed = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [_label setString:fixed];
        double prgrs = i / (double)keysize * 100;
        [_pc setStringValue:[NSString stringWithFormat:@"%1.f %%", prgrs]];
        [_btn setTitle:@"Answer"];
        _back.hidden = true;
    } else {
        [_label setString:dic[str]];
        [_btn setTitle:@"Next"];
        _back.hidden = false;
    }
        
    [self.window makeFirstResponder:self];
}
    
-(void)pushtoback:(id)sender {

    if ([_btn.title isEqualToString:@"Next"]) {
        [_label setString:fixed];
        [_btn setTitle:@"Answer"];
        _back.hidden = true;
    } else if (![_back isHidden]) {
        [_label setString:dic[str]];
        [_btn setTitle:@"Next"];
    }

    [self.window makeFirstResponder:self];
}
    
- (void)shuffle {
    for (NSUInteger ui = 0; ui < keysize - 1; ++ui) {
        NSInteger remainingCount = keysize - ui;
        NSInteger exchangeIndex = ui + arc4random_uniform((u_int32_t )remainingCount);
        [keys exchangeObjectAtIndex:ui withObjectAtIndex:exchangeIndex];
    }
}
    
    
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    AudioServicesPlaySystemSound(exit);
    [NSThread sleepForTimeInterval:3.1f];
    NSLog(@"Good Bye!!");
}
    
-(void)keyDown:(NSEvent*)event {
    NSInteger i = [event keyCode];
    NSUInteger modifierFlags = [event modifierFlags];
    switch(i) {
        case 126:	// up arrow
            [self fontsizeincrement:self];
            break;
        case 125:	// down arrow
            [self fontsizedecrement:self];
            break;
        case 124:	// right arrow
            [self pushtonext:self];
            break;
        case 123:	// left arrow
            [self pushtoback:self];
            break;
        default:
            if (i == 13 && modifierFlags & NSCommandKeyMask)
                [NSApp terminate:self];
            break;
    }
}
    
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}
    
@end