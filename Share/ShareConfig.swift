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
        
        let config = Realm.Configuration (
            fileURL: fileURL,
            schemaVersion: 21,
            
            /**
             * Set the block which will be called automatically when opening a Realm with a schema version lower than the one set above
             **/
            migrationBlock: { migration, oldSchemaVersion in }
        )
        
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
    }
}
