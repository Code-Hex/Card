//
//  AppDelegate.swift
//  Card
//
//  Created by CodeHex on 2015/11/20.
//  Copyright © 2015年 CodeHex. All rights reserved.
//

import Cocoa
import AudioToolbox

extension String {
    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).stringByDeletingPathExtension
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(path)
    }
}

extension NSProgressIndicator {
    public override func drawRect(dirtyRect: NSRect) {
        var rect = NSInsetRect(self.bounds, 1.0, 1.0)
        rect = NSInsetRect(rect, 3.0, 3.0)
        let radius = rect.size.height / 2
        let barbz = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        barbz.lineWidth = 1.0
        barbz.addClip()
        rect.size.width = floor(CGFloat(rect.size.width) * (CGFloat(self.doubleValue) / CGFloat(self.maxValue)))
        NSColor(calibratedRed: 0.000, green: 0.478, blue: 1.000, alpha: 1).set()
        NSRectFill(rect)
    }
}

class preferenceview: NSView {
    override func drawRect(dirtyRect: NSRect) {
        NSColor.clearColor().set()
        NSRectFill(dirtyRect)
    }
}

@NSApplicationMain
class AppDelegate: NSWindow,NSApplicationDelegate,NSWindowDelegate,NSSpeechSynthesizerDelegate,NSTextViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var filemenu: NSMenu!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var play: NSButtonCell!
    @IBOutlet weak var control: NSSegmentedCell!
    @IBOutlet weak var fontcontrol: NSSegmentedCell!
    @IBOutlet weak var windowbar: NSToolbar!
    @IBOutlet weak var config: NSButtonCell!
    @IBOutlet weak var alphaslider: NSSlider!
    @IBOutlet weak var preference: NSWindow!
    @IBOutlet weak var PreferenceView: preferenceview!
    @IBOutlet weak var setSwitch: ITSwitch!
    @IBOutlet weak var apptitle: NSTextField!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var author: NSTextField!
    @IBOutlet weak var modelabel: NSTextField!
    @IBOutlet weak var statusmenu: NSMenu!
    
    var i = 0
    var keysize = 0
    var cp = ""
    var ans = ""
    var fixed = ""
    var status = "Answer"
    var isVoice = false
    var keys = [NSString]()
    var start = SystemSoundID()
    var up = SystemSoundID()
    var exit = SystemSoundID()
    var dic = NSDictionary()
    let file2card = File2Card()
    let systembaritem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        systembaritem.highlightMode = true
        systembaritem.title = "\u{f28f}"
        let attricon = NSMutableAttributedString(string:"\u{f28f}", attributes: [NSFontAttributeName : NSFont(name: "Material-Design-Iconic-Font", size: 18.0)!])
        systembaritem.attributedTitle = attricon
        systembaritem.menu = statusmenu
        
        
        self.window.makeKeyAndOrderFront(self)
        self.window.delegate = self
        self.window.backgroundColor = NSColor(calibratedRed: 0.969, green: 0.969, blue: 0.969, alpha: 1)
        self.window.movableByWindowBackground = true
        self.window.titleVisibility = .Hidden
        self.window.styleMask |= NSFullSizeContentViewWindowMask
        self.window.titlebarAppearsTransparent = false
        self.preference.movableByWindowBackground = true
        
        self.progress.wantsLayer = true
        self.alphaslider.minValue = 0.2
        self.alphaslider.maxValue = 1.0
        self.alphaslider.action = "setalpha:"
        self.config.font = NSFont(name: "FontAwesome", size: 16)
        self.config.title = "\u{f013}"
        self.config.action = "preferenceAppear"

        self.textView.editable = false
        self.textView.delegate = self
        self.textView.backgroundColor = NSColor.clearColor()
        
        let ud = NSUserDefaults.standardUserDefaults()
        
        if ud.floatForKey("fontsize").isZero { // Is first launch this app??
            ud.setFloat(12.0, forKey: "fontsize")
            ud.setBool(false, forKey: "isdark")
            ud.synchronize()
        }
        
        var cnt = 0
        keysize = file2card.keysize
        let fontsize = CGFloat(ud.floatForKey("fontsize"))
        for title: String in file2card.filelist {
            let menuItem: NSMenuItem = NSMenuItem(title: title, action: "fileswitch:", keyEquivalent: "")
            menuItem.target = self
            filemenu.insertItem(menuItem, atIndex: cnt)
            cnt++
        }
        
        let bundle = NSBundle.mainBundle()
        var items = ["coin", "1up", "exit"]
        
        for filename in items {
            let sound_path: String = bundle.pathForResource(filename, ofType: "wav")!
            let url = NSURL.fileURLWithPath(sound_path)
            if (filename == items[0]) {
                AudioServicesCreateSystemSoundID(url, &start)
            } else if (filename == items[1]) {
                AudioServicesCreateSystemSoundID(url, &up)
            } else {
                AudioServicesCreateSystemSoundID(url, &exit)
            }
        }
        
        self.window.makeFirstResponder(self)
        
        fileswitch(filemenu.itemAtIndex(0)!)
        file2card.now_setFile = filemenu.itemAtIndex(0)!.title
        AudioServicesPlaySystemSound(start)
        
        file2card.speech.delegate = self
        self.textView.font = NSFont.systemFontOfSize(fontsize)
        self.play.action = "say"
        self.control.action = "navigate:"
        self.fontcontrol.action = "fontresize:"
        setColorTheme(ud.boolForKey("isdark"))
        self.setSwitch.checked = ud.boolForKey("isdark")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        AudioServicesPlaySystemSound(exit)

        let Start = NSDate()
        var pos = NSPoint()
        pos.x = self.window.frame.origin.x
        pos.y = self.window.frame.origin.y
        let frame: NSRect = NSScreen.mainScreen()!.visibleFrame
        let max_height: CGFloat = frame.origin.y + frame.size.height - self.window.frame.size.height
        let min_height: CGFloat = frame.origin.y - frame.size.height + self.window.frame.size.height
        var newframe = self.window.frame
        newframe.origin.y = max_height
        
        let windowResizemax: [String : AnyObject] = [
            NSViewAnimationTargetKey : self.window,
            NSViewAnimationEndFrameKey : NSValue(rect: newframe)
        ]
        
        var animations = [windowResizemax]
        var animation = NSViewAnimation(viewAnimations: animations)
        animation.animationBlockingMode = .Blocking
        animation.animationCurve = .EaseIn
        animation.duration = Double(max_height / 1000)
        animation.startAnimation()
        
        newframe.origin.y = min_height
        
        let windowResizemin: [String : AnyObject] = [
            NSViewAnimationTargetKey : self.window,
            NSViewAnimationEndFrameKey : NSValue(rect: newframe)
        ]
        
        animations = [windowResizemin]
        animation = NSViewAnimation(viewAnimations: animations)
        animation.animationBlockingMode = .Blocking
        animation.animationCurve = .EaseIn
        animation.duration = Double(-min_height / 1000)
        animation.startAnimation()

        let windowFadeout: [String : AnyObject] = [
            NSViewAnimationTargetKey : self.window,
            NSViewAnimationEffectKey : NSViewAnimationFadeOutEffect
        ]
        
        animations = [windowFadeout]
        animation = NSViewAnimation(viewAnimations: animations)
        animation.animationBlockingMode = .Blocking
        animation.animationCurve = .EaseIn
        animation.duration = 0.1
        animation.startAnimation()
        
        let stop = Double(NSDate().timeIntervalSinceDate(Start))
        NSThread.sleepForTimeInterval(3.1 - stop)
    }
    
    @IBAction func isDark(sender: ITSwitch) {
        let isdark = sender.checked
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setBool(isdark, forKey: "isdark")
        setColorTheme(isdark)
    }
    
    func setColorTheme(isdark: Bool) {
        if isdark {
            self.window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            self.preference.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            self.apptitle.textColor = NSColor.whiteColor()
            self.version.textColor = NSColor.whiteColor()
            self.author.textColor = NSColor.whiteColor()
            self.modelabel.textColor = NSColor.whiteColor()
            self.textView.textColor = NSColor.whiteColor()
        } else {
            self.window.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            self.preference.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            self.apptitle.textColor = NSColor.blackColor()
            self.version.textColor = NSColor.blackColor()
            self.author.textColor = NSColor.blackColor()
            self.modelabel.textColor = NSColor.blackColor()
            self.textView.textColor = NSColor.blackColor()
        }
    }
    
    func setalpha(sender: NSSlider) {
        let val = CGFloat(sender.floatValue)
        self.window.alphaValue = val
    }
    
    func preferenceAppear() {
        self.preference.makeKeyAndOrderFront(self)
    }
    
    func say() {
        file2card.speech.startSpeakingString(fixed)
        self.play.title = "Stop"
        self.play.action = "stop"
    }
    
    func stop() {
        file2card.speech.stopSpeaking()
        self.play.title = "Say"
        self.play.action = "say"
    }
    
    func navigate(control: NSSegmentedControl) {
        switch control.selectedSegment {
        case 0:
            pushtoback()
        case 1:
            pushtonext()
        default:
            self.print("Navigate Error")
        }
    }
    
    func fontresize(control: NSSegmentedControl) {
        switch control.selectedSegment {
        case 0:
            fontsizeincrement()
        case 1:
            fontsizedecrement()
        default:
            self.print("Resize Error")
        }
    }

    
    func textViewDidChangeSelection(aNotification: NSNotification) {
        let r = self.textView.selectedRange
        cp = (self.textView.string! as NSString).substringWithRange(r)
    }
    
    func CopyOntextView() {
        writeToPasteBoard(cp)
    }
    
    func writeToPasteBoard(stringToWrite: String) -> Bool {
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.declareTypes([NSStringPboardType], owner: nil)
        return pasteBoard.writeObjects([stringToWrite])
    }
    
    func windowWillClose(notification: NSNotification) {
        NSApp.terminate(self)
    }

    func pushtonext() {
        if status == "Next" {
            i++
            if i % keysize == 0 {
                i = 0
                file2card.shuffle()
                AudioServicesPlaySystemSound(up)
                progress.doubleValue = Double(i)
            } else {
                progress.incrementBy(1.0)
            }
            ans = keys[i] as String
            fixed = dic[ans]!.stringByReplacingOccurrencesOfString("\n", withString: "") as String
            self.textView.string = fixed
            status = "Answer"
        } else {
            self.textView.string = ans
            status = "Next"
        }
    }
    
    func pushtoback() {
        if status == "Next" {
            self.textView.string = fixed
            status = "Answer"
        } else if status == "Answer" {
            self.textView.string = ans
            status = "Next"
        }
    }
    
    func fileswitch(ItemName: NSMenuItem) {
        let filename = ItemName.title
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(filename, ofType: "plist")
        
        if file2card.now_setFile != filename {
            file2card.now_setFile = filename
            dic = NSDictionary(contentsOfFile: path!)!
            keys = dic.allKeys as! [String]
            keysize = keys.count
            file2card.shuffle()
            i = 0
            progress.maxValue = Double(keysize)
            progress.doubleValue = Double(i)
            ans = keys[i] as String
            i++
            fixed = dic[ans]!.stringByReplacingOccurrencesOfString("\n", withString: "")
            self.textView.string = fixed
        }
    }
    
    func fontsizeincrement() {
        let ud = NSUserDefaults.standardUserDefaults()
        var fontsize = CGFloat(ud.floatForKey("fontsize"))
        if (fontsize + 1) < 26 {
            fontsize += 1
        }
        store(fontsize, data: ud)
    }
    
    func fontsizedecrement() {
        let ud = NSUserDefaults.standardUserDefaults()
        var fontsize = CGFloat(ud.floatForKey("fontsize"))
        if 8 < (fontsize - 1) {
            fontsize -= 1
        }
        store(fontsize, data: ud)
    }
    
    func store(fontsize: CGFloat, data ud: NSUserDefaults) {
        self.textView.font = NSFont.systemFontOfSize(fontsize)
        ud.setFloat(Float(fontsize), forKey: "fontsize")
        ud.synchronize()
    }
    
    override func keyDown(theEvent: NSEvent) {
        let i = theEvent.keyCode
        let modifierFlags = theEvent.modifierFlags
        switch(i) {
            case 126:	// up arrow
                fontsizeincrement()
                break
            case 125:	// down arrow
                fontsizedecrement()
                break
            case 124:	// right arrow
                pushtonext()
                break
            case 123:	// left arrow
                pushtoback()
                break
            default:
                if (i == 12 || i == 13) && modifierFlags.contains(.CommandKeyMask) {
                    NSApp.terminate(delegate)
                }
                break;
        }
    }
    
    func speechSynthesizer(sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        stop()
    }

}

