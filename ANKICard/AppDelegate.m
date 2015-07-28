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
static int rnd;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud floatForKey:@"fontsize"]) {
        [ud setFloat:12.0 forKey:@"fontsize"];
        [ud synchronize];
    }

    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"test" ofType:@"plist"];
    
    
    dic = [NSDictionary dictionaryWithContentsOfFile:path];
    keys = [dic allKeys];
    keysize = [keys count];
    
    rnd = (int)arc4random_uniform((int)keysize);
    str = keys[rnd];
    
    
    fixed = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    [self.window makeFirstResponder:self];
    
    [_label setFont:[NSFont systemFontOfSize:fontsize]];
    [_btn setTitle:@"Answer"];
    [_back setTitle:@"Back"];
    [_increment setTitle:@"+"];
    [_decrement setTitle:@"-"];
    _back.hidden = true;

    [_label setStringValue:fixed];

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
    i++;
    if (!(i % 2)) {
        str = keys[rnd];
        fixed = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [_label setStringValue:fixed];
        [_btn setTitle:@"Answer"];
        _back.hidden = true;
        rnd = (int)arc4random_uniform((int)keysize);
    } else {
        [_label setStringValue:dic[str]];
        [_btn setTitle:@"Next"];
        _back.hidden = false;
    }
    [self.window makeFirstResponder:self];
}

-(void)pushtoback:(id)sender {
        i--;
        if (!(i % 2)) {
            [_label setStringValue:fixed];
            [_btn setTitle:@"Answer"];
            _back.hidden = true;
        } else {
            [_label setStringValue:dic[str]];
            [_btn setTitle:@"Next"];
        }
    [self.window makeFirstResponder:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"Good Bye!!");
}

-(void)keyDown:(NSEvent*)event
{
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
