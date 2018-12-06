/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import RealmSwift

class ShareConfig {

    internal static func configRealm(){
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.im.iGap")!
            .appendingPathComponent("default.realm")
        
        let config = Realm.Configuration(fileURL: fileURL,
                                         schemaVersion: 19,
                                         
                                         // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                } else if (oldSchemaVersion < 2) {
                    //Logout users. due to the missing of authorHash
                } else if (oldSchemaVersion < 3) {
                    //version 0.0.5 build 290
                } else if (oldSchemaVersion < 4) {
                    //version 0.0.6 build 291
                } else if (oldSchemaVersion < 5) {
                    //version 0.0.7 build 292
                } else if (oldSchemaVersion < 6) {
                    //version 0.0.8 build 293
                } else if (oldSchemaVersion < 7) { //version 0.1.0 : 7
                    //version 0.0.11
                } else if (oldSchemaVersion < 8) {
                    //version 0.1.5 build 449
                } else if (oldSchemaVersion < 9) {
                    //version 0.2.0 build 452
                } else if (oldSchemaVersion < 10) {
                    //version 0.3.0 build 453
                } else if (oldSchemaVersion < 11) {
                    //version 0.3.1 build 454
                } else if (oldSchemaVersion < 12) {
                    //version 0.3.2 build 455
                } else if (oldSchemaVersion < 13) {
                    //version 0.4.6 build 461
                } else if (oldSchemaVersion < 14) {
                    //version 0.4.7 build 462
                } else if (oldSchemaVersion < 15) {
                    //version 0.4.8 build 463
                } else if (oldSchemaVersion < 16) {
                    //version 0.6.0 build 467
                } else if (oldSchemaVersion < 17) {
                    //version 0.6.5 build 472
                } else if (oldSchemaVersion < 18) {
                    //version 0.6.7 build 474
                } else if (oldSchemaVersion < 19) {
                    //version 0.7.0 build 477, add priority in IGRoom , add IGShareInfo
                }
        })
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
    }
}
