//
//  AppDelegate.m
//  ANKICard
//
//  Created by CodeHex on 2015/07/27.
//  Copyright (c) 2015年 CodeHex. All rights reserved.
//

#import "AppDelegate.h"
#import "CardMakerViewController.h"
#import "ANKITextView.h"

@implementation AppDelegate

static int i = 0;

-(id)init {
    if (self = [super init]) {
        NSLog(@"init");
        NSString *voice_name = @"com.apple.speech.synthesis.voice.kyoko.premium";
        isVoice = NO;
        NSUInteger index = [[NSSpeechSynthesizer availableVoices] indexOfObject:voice_name];
        if (index != NSNotFound) {
            speech = [[NSSpeechSynthesizer alloc] initWithVoice:voice_name];
            isVoice = YES;
        }
        
        keys = [[NSMutableArray alloc] init];
        
        NSArray *ary = [self getFileList:@".plist"];
        filelist = [[NSMutableArray alloc] initWithArray:
                    [ary sortedArrayUsingComparator:
                     ^(id o1, id o2) {
                         return [o1 compare:o2];
                     }]];
        speech.delegate = self;
    }
    
    return self;
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.window.delegate = self;
    self.window.movableByWindowBackground = YES;
    self.window.hasShadow = YES;
    self.window.titleBarHeight = 60.0;
    self.window.trafficLightButtonsTopMargin = 5;
    self.window.centerTrafficLightButtons = NO;
    self.window.showsBaselineSeparator = NO;
    /*
    NSShadow* shadow = NSShadow.alloc.init;
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1]];
    [shadow setShadowOffset:NSMakeSize(0.1, 10)];
    [shadow setShadowBlurRadius:0.5];
    self.window.titleBarView.shadow = shadow;
     */
    self.window.representedURL = nil; // hide document proxy icon
    self.barview.noiseBlendMode = kCGBlendModeMultiply;
    self.barview.noiseOpacity = 0.15;
    self.barview.backgroundColor = NSColor.clearColor;
    
    [self.window.titleBarView addSubview:self.barview];
    
    [self.window setTitleBarDrawingBlock:^(BOOL drawsAsMainWindow, CGRect drawingRect, CGRectEdge edge, CGPathRef clippingPath){

        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        if (clippingPath) {
            CGContextAddPath(ctx, clippingPath);
            CGContextClip(ctx);
        }
        
        NSGradient *gradient = [NSGradient.alloc
                                initWithStartingColor:[NSColor colorWithRed:0.60 green:0.06 blue:0.06 alpha:1.0]
                                endingColor:[NSColor colorWithRed:0.60 green:0.06 blue:0.06 alpha:1.0]];
        [gradient drawInRect:drawingRect angle:90];
        
        CGFloat lineheight = 3;
        NSBezierPath *Path = NSBezierPath.bezierPath;
        
        [Path moveToPoint:NSMakePoint(drawingRect.size.width, lineheight)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(50,100.5) toPoint:NSMakePoint(150,100.5)];
        [Path lineToPoint:NSMakePoint(0, lineheight)];
        [Path setLineCapStyle:NSRoundLineCapStyle];
        [Path setLineJoinStyle: NSRoundLineJoinStyle];

        [Path setLineWidth:2];
        CGFloat bezierPattern[] = {16, 4};
        [Path setLineDash:bezierPattern count:2 phase:5];
        [NSColor.whiteColor set];
        [Path stroke];
        
    }];
    
    self.View.noiseBlendMode = kCGBlendModeMultiply;
    self.View.noiseOpacity = 0.05;
    self.View.backgroundColor = NSColor.whiteColor;
    
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    if (![ud floatForKey:@"fontsize"]) {
        [ud setFloat:12.0 forKey:@"fontsize"];
        [ud synchronize];
    }
    
    self.play.enabled = isVoice;
    self.textview.editable = NO;
    self.textview.delegate = self;
    [self.textview setTextContainerInset:NSMakeSize(0, 10)]; // Padding NSTextView

    // from popupmenu
    NSInteger cnt = 0;
    for(NSString *title in filelist){
        NSMenuItem *menuItem = [[NSMenuItem alloc]
                                initWithTitle:title
                                action:@selector(fileswitch:)
                                keyEquivalent:@""];
        [menuItem setTarget:self];
        [_filemenu insertItem:menuItem atIndex:cnt];
        cnt++;
    }
    // NSLog(@"%@",_filemenu);
    // to
    
    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    
    NSBundle *bundle = [NSBundle mainBundle];
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
    
    [self fileswitch:[_filemenu itemAtIndex:0]];
    now_setFile = [_filemenu itemAtIndex:0].title;

    AudioServicesPlaySystemSound(start);
    
    [self.window makeFirstResponder:self];
    
    status = @"Answer";
    [self.textview setFont:[NSFont systemFontOfSize:fontsize]];
    [self.increment setTitle:@"+"];
    [self.decrement setTitle:@"-"];

    [self.bfbutton setAction:@selector(navigate:)];
    [self.increment setAction:@selector(fontsizeincrement)];
    [self.decrement setAction:@selector(fontsizedecrement)];
    [self.play setAction:@selector(say)];
}

- (void)cardmaker {
    //CardMakerViewController *cardmaker = [[CardMakerViewController alloc] init];
}

- (void)navigate:(NSSegmentedControl*)control {
    
    switch (control.selectedSegment) {
        case 0:
            [self pushtoback];
            break;
        case 1:
            [self pushtonext];
            break;
        default:
            NSLog(@"Navigate Error");
            break;
    }
}

-(void)pushtonext {
    
    if ([status isEqualToString:@"Next"]) {
        i++;
        if (!(i % keysize)) {
            [self shuffle];
            AudioServicesPlaySystemSound(up);
            i = 0;
            [_progress setDoubleValue:i];
        } else [_progress incrementBy:1.0];
        
        ans = keys[i];
        fixed = [dic[ans] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [self.textview setString:fixed];
        double prgrs = i / (double)keysize * 100;
        [_pc setStringValue:[NSString stringWithFormat:@"%1.f %%", prgrs]];
        [self.bfbutton setEnabled:NO forSegment:0];
        status = @"Answer";
    } else {
        [self.textview setString:ans];
        [self.bfbutton setEnabled:YES forSegment:0];
        status = @"Next";
        
    }
}

-(void)pushtoback {
    
    if ([status isEqualToString:@"Next"]) {
        [self.textview setString:fixed];
        [self.bfbutton setEnabled:NO forSegment:0];
        status = @"Answer";
    } else if ([self.bfbutton isEnabledForSegment:0]) {
        [self.textview setString:ans];
        status = @"Next";
    }
}

- (void)fileswitch:(NSMenuItem *)ItemName {
    NSString *filename = ItemName.title;
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:@"plist"];
    
    if (![now_setFile isEqualToString:filename]) {
        now_setFile = filename;
        dic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        keys = [[dic allKeys] mutableCopy];
        keysize = [keys count];
        
        [self shuffle]; i = 0;
        [_progress setMaxValue:keysize];
        [_progress setDoubleValue:i];
    
        ans = keys[i]; i++;
        fixed = [dic[ans] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [self.bfbutton setEnabled:NO forSegment:0];
        [self.textview setString:fixed];
        [_pc setStringValue:[NSString stringWithFormat:@"0 %%"]];
    }
}

- (void)say {
    [speech startSpeakingString:fixed];
    [self.play setAction:@selector(stop)];
    [self.play setTitle:@"Stop"];
}

- (void)stop {
    [speech stopSpeaking];
    [self.play setTitle:@"Say"];
    [self.play setAction:@selector(say)];
}

- (void)speechSynthesizer:(NSSpeechSynthesizer *)sender didFinishSpeaking:(BOOL)finishedSpeaking {
    [self stop];
}

-(void)fontsizeincrement {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    
    if ((fontsize + 1) < 26)
        fontsize += 1;
    
    [self store:fontsize data:ud];
}

-(void)fontsizedecrement {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    CGFloat fontsize = [ud floatForKey:@"fontsize"];
    
    if (8 < (fontsize - 1))
        fontsize -= 1;
    [self store:fontsize data:ud];
}

-(void)store:(CGFloat)fontsize data:(NSUserDefaults*)ud {
    [self.textview setFont:[NSFont systemFontOfSize:fontsize]];
    [ud setFloat:fontsize forKey:@"fontsize"];
    [ud synchronize];
}
    
- (void)shuffle {
    for (NSUInteger ui = 0; ui < keysize - 1; ++ui) {
        NSInteger remainingCount = keysize - ui;
        NSInteger exchangeIndex = ui + arc4random_uniform((u_int32_t )remainingCount);
        [keys exchangeObjectAtIndex:ui withObjectAtIndex:exchangeIndex];
    }
}

-(NSArray *)getFileList:(NSString *)extension {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    path = [path stringByAppendingPathComponent:@"Contents/Resources/"];
    // NSLog(@"%@",path);
    for(NSString *content in [fileManager contentsOfDirectoryAtPath:path error:nil]) {
        if ([content hasSuffix:extension]) {
            NSString *contents = [content stringByDeletingPathExtension];
            [array addObject:contents];
        }
    }
    return array;
}

- (void)textViewDidChangeSelection:(NSNotification *)aNotification {
    copy = [self.textview.string substringWithRange:self.textview.selectedRange];
}

- (void)CopyOntextView {
    [self writeToPasteBoard:copy];
}

- (BOOL)writeToPasteBoard:(NSString *)stringToWrite {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    return [pasteBoard setString:stringToWrite forType:NSStringPboardType];
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    AudioServicesPlaySystemSound(exit);
    NSDate *Start = [NSDate date]; // time
    NSPoint pos;
    pos.x = self.window.frame.origin.x;
    pos.y = self.window.frame.origin.y;
    NSRect frame = [[NSScreen mainScreen] visibleFrame];
    CGFloat max_height = frame.origin.y + frame.size.height - self.window.frame.size.height;
    CGFloat min_height = frame.origin.y - frame.size.height + self.window.frame.size.height;

    // from animation
    for (NSInteger i = 1; max_height >= pos.y; i++) {
        pos.y += i;
        [self.window setFrame:CGRectMake(pos.x,
                                         pos.y,
                                         self.window.frame.size.width,
                                         self.window.frame.size.height) display:YES];
    }
    
    for (NSInteger i = 1; pos.y >= (min_height - 200); i++) {
        pos.y -= i;
        [self.window setFrame:CGRectMake(pos.x,
                                         pos.y,
                                         self.window.frame.size.width,
                                         self.window.frame.size.height) display:YES];
    }
    // to
    [self.window close];
    CGFloat stop = [[NSDate date] timeIntervalSinceDate:Start];
    [NSThread sleepForTimeInterval:3.1f - stop];
    NSLog(@"Good Bye!!");
}

-(void)keyDown:(NSEvent*)event {
    NSInteger i = [event keyCode];
    NSUInteger modifierFlags = [event modifierFlags];
    switch(i) {
        case 126:	// up arrow
            [self fontsizeincrement];
            break;
        case 125:	// down arrow
            [self fontsizedecrement];
            break;
        case 124:	// right arrow
            [self pushtonext];
            break;
        case 123:	// left arrow
            [self pushtoback];
            break;
        default:
            if (i == 13 && modifierFlags & NSCommandKeyMask)
                [NSApp terminate:self];
            break;
    }
}

@end