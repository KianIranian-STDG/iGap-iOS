/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

struct IGApiStruct {
    
    var favoriteValue : String!
    var favoriteOrderId : String!
    var favoriteBgColor : String!
    var favoriteColor : String!
    var favoriteEnable : String!
    var favoriteImage : String!
    var favoriteName : String!
    
    init(_ dictionary: [String: AnyObject]) {
        self.favoriteValue = dictionary["favoriteValue"] as? String
        self.favoriteOrderId = dictionary["favoriteOrderId"] as? String
        self.favoriteBgColor = dictionary["favoriteBgColor"] as? String
        self.favoriteColor = dictionary["favoriteColor"] as? String
        self.favoriteEnable = dictionary["favoriteEnable"] as? String
        self.favoriteImage = dictionary["favoriteImage"] as? String
        self.favoriteName = dictionary["favoriteName"] as? String
    }
}
