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
import Foundation

class IGRealmElectroBill: Object {
    
    @objc dynamic var billNumber: String?
    
    override static func primaryKey() -> String {
        return "billNumber"
    }
    
    convenience init(bill: DataStruct) {
        self.init()

        self.billNumber = bill.billIdentifier
    }
}