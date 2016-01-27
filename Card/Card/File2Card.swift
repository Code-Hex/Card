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
    var isVoice = false
    
    
    override init() {
        super.init()
        
        let voicelist = NSSpeechSynthesizer.availableVoices()
        let voice_name = "com.apple.speech.synthesis.voice.kyoko.premium"
        
        for voice: String in voicelist {
            if voice == voice_name {
                isVoice = true
                self.speech = NSSpeechSynthesizer(voice: voice_name)!
            }
        }
        
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
    
    func shuffle<T>(inout k: [T]) {
        for var ui = k.count - 1; ui > 0; ui-- {
            let exchangeIndex = Int(arc4random_uniform(UInt32(ui + 1)))
            if ui != exchangeIndex {
                swap(&k[ui], &k[exchangeIndex])
            }
        }
    }
}