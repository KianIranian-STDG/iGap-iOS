/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import SwiftyJSON

class IGStructAdditionalButton {

    var json : String!
    var actionType : Int!
    var label : String!
    var imageUrl : URL!
    var value : String!
    
    init(json: JSON) {
        self.json = json.description
        self.actionType = json["actionType"].intValue
        self.label = json["label"].stringValue
        self.imageUrl = json["imageUrl"].url
        self.value = json["value"].stringValue
    }
}
