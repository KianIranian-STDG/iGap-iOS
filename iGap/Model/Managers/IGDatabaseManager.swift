/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */
import RealmSwift

//class IGDatabaseManager: NSObject {
//    static let shared = IGDatabaseManager()
//
//    private var databaseThread: DMThread!
//    var realm: Realm {
//        return try! Realm()
//    }
//
//    private override init() {
//        super.init()
//        databaseThread = DMThread(start: true, queue: nil)
//    }
//
//    func perfrmOnDatabaseThread(_ block: @escaping ()->()) {
//
//        print("=-=-=-=-=-=-=-=-", Thread.current)
//
//        databaseThread.enqueue {
//            autoreleasepool {
//                block()
//            }
//        }
//    }
//
//    func emptyQueue() {
//        databaseThread.emptyQueue()
//    }
//}


class IGDatabaseManager: NSObject {
    
    typealias Block = () -> Void
//    private(set) var queue = [Block]()
    
    var realm: Realm {
        return try! Realm()
    }
    
    static let shared = IGDatabaseManager()
    
    private var databaseThread : DispatchQueue?
    
    func perfrmOnDatabaseThread(_ block: @escaping Block) {
        
        if databaseThread == nil {
            databaseThread = DispatchQueue(label: "serial.queue.database", qos: .userInteractive)
        }
        databaseThread!.async {
            block()
        }
    }
    
    func emptyQueue() {
        if databaseThread == nil {
            return
        }
        databaseThread!.suspend()
//        databaseThread = nil
    }
    
}
