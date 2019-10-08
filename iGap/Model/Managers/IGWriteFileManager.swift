/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */
import UIKit
import RealmSwift

class IGWriteFileManager: NSObject {
    
    static let shared = IGWriteFileManager()
    private var fileThread: DMThread!
    
    private override init() {
        super.init()
        fileThread = DMThread(start: true, queue: nil)
    }
    
    func perfrmOnWriteFileThread(_ block: @escaping ()->()) {
        fileThread.enqueue {
            block()
        }
    }
    
    func emptyQueue() {
        fileThread.emptyQueue()
    }
}
