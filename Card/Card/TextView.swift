//
//  ANKITextView.swift
//  Card
//
//  Created by CodeHex on 2015/11/20.
//  Copyright © 2015年 CodeHex. All rights reserved.
//

import Cocoa

class TextView: NSTextView {
    override func keyDown(theEvent: NSEvent) {
        let delegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let i = theEvent.keyCode
        let modifierFlags = theEvent.modifierFlags
        switch(i) {
        case 126:	// up arrow
            delegate.fontsizeincrement()
            break
        case 125:	// down arrow
            delegate.fontsizedecrement()
            break
        case 124:	// right arrow
            delegate.pushtonext()
            break
        case 123:	// left arrow
            delegate.pushtoback()
            break
        default:
            if (i == 7 || i == 8) && modifierFlags.contains(.CommandKeyMask) {
                delegate.CopyOntextView()
            } else if (i == 12 || i == 13) && modifierFlags.contains(.CommandKeyMask) {
                NSApp.terminate(delegate)
            }
            break
        }
    }
}
