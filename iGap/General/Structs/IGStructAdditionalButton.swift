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
    
    var json : String?
    var actionType : Int?
    var label : String?
    var imageUrl : URL?
    var value : String?
    var valueJson : Any? // use this param when value is json
    
    init(json: JSON) {
        self.json = json.description
        self.actionType = json["actionType"].intValue
        self.label = json["label"].stringValue
        self.imageUrl = json["imageUrl"].url
        self.value = json["value"].stringValue
        self.valueJson = json["value"].object
    }
}
class IGStructAdditional {
    
    var json : String!
    var amount : String!
    var cardNumber : String!
    var value : String!
    
    init(json: JSON) {
        self.json = json.description
        self.amount = json["amount"].stringValue
        self.cardNumber = json["cardNumber"].stringValue
        self.value = json["value"].stringValue
    }
}


class IGStructAdditionalPayDirect {
    
    var title : String!
    var invoiceNumber : String!
    var price : String!
    var description : String!
    var toId : Int64!
    var inquiry : Bool!
    
    init(json: JSON) {
        self.title = json["title"].stringValue
        self.invoiceNumber = json["invoiceNumber"].stringValue
        self.price = json["price"].stringValue
        self.description = json["description"].stringValue
        self.toId = json["toId"].int64
        self.inquiry = json["inquiry"].bool
    }
}

class IGStructAdditionalCardToCard {
    
    var cardNumber : String!
    var userId : Int64!
    var amount : Int!
    
    init(json: JSON) {
        self.cardNumber = json["cardNumber"].stringValue
        self.userId = json["userId"].int64Value
        self.amount = json["amount"].intValue
    }
}

class IGStructBillInfo {
    
    var PID : String!
    var BID : String!
    
    init(json: JSON) {
        self.PID = json["PID"].stringValue
        self.BID = json["BID"].stringValue
    }
}
