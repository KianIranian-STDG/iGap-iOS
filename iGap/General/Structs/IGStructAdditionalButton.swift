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

    var actionType : Int!
    var label : String!
    var imageUrl : URL!
    var value : String!
    var width : Int!
    var height : Int!
    
    init(json: JSON) {
        self.actionType = json["actionType"].intValue
        self.label = json["lable"].stringValue
        self.imageUrl = json["imageUrl"].url
        self.value = json["value"].stringValue
        self.width = json["width"].intValue
        self.height = json["height"].intValue
    }
}
