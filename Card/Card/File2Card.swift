//
//  File2Card.swift
//  Card
//
//  Created by CodeHex on 2015/11/20.
//  Copyright © 2015年 CodeHex. All rights reserved.
//

import Cocoa

class File2Card: NSObject {

    var now_setFile = ""
    var filelist = [String]()
    var speech = NSSpeechSynthesizer()
    var keysize = 0
    
    var keys: [String] {
        get {
            return self.keys
        }
        set(array) {
            self.keys = array
            self.keysize = self.keys.count
        }
    }
    
    override init() {
        super.init()
        let voice_name = "com.apple.speech.synthesis.voice.kyoko.premium"
        self.speech = NSSpeechSynthesizer(voice: voice_name)!
        let ary = self.getFileList(".plist")
        self.filelist = ary.sort()
        print("init")
    }
    
    func getFileList(ext: String) -> [String] {
        var array: [String] = []
        let fileManager = NSFileManager()
        let path = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Contents/Resources/")
        let paths = try! fileManager.contentsOfDirectoryAtPath(path)
        
        for content in paths {
            if content.hasSuffix(ext) {
                let contents = content.stringByDeletingPathExtension
                print(contents)
                array.append(contents)
            }
        }
        return array
    }
    
    func shuffle() {
        for var ui = 0; ui < keysize - 1; ++ui {
            let remainingCount = keysize - ui
            let exchangeIndex = ui + Int(arc4random_uniform(UInt32(remainingCount)))
            exchange(&keys, i: ui, j: exchangeIndex)
        }
    }
    
    func exchange<T>(inout data: [T], i: Int, j: Int) {
        swap(&data[i], &data[j])
    }
}