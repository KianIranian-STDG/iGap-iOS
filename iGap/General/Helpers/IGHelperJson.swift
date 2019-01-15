/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation
import SwiftyRSA
import SwiftyJSON

class IGHelperJson {

    internal static func parseAdditionalButton() -> [[IGStructAdditionalButton]]? {
        
        let jsonString = "[[{\"actionType\" : 3,\"lable\":\"کانال آی گپ\",\"imageUrl\":\"https://lh3.googleusercontent.com/crtxcLqrnVf47QG6LBjQbn5ZeXJBBGO4xCmAZC-e8afPMe0oV1sJktNALFP2mTM83Q\\u003ds360-rw\",\"value\":\"@official\",\"width\":100,\"height\":100}],[{\"actionType\":2,\"lable\":\"دستور بات\",\"imageUrl\":\"\",\"value\":\"/start\",\"width\":0,\"height\":0},{\"actionType\":2,\"lable\":\"دستور بات\",\"imageUrl\":\"\",\"value\":\"/start\",\"width\":0,\"height\":0},{\"actionType\":3,\"lable\":\"کانال آی گپ\",\"imageUrl\":\"https://lh3.googleusercontent.com/crtxcLqrnVf47QG6LBjQbn5ZeXJBBGO4xCmAZC-e8afPMe0oV1sJktNALFP2mTM83Q\\u003ds360-rw\",\"value\":\"@official\",\"width\":100,\"height\":100}],[{\"actionType\":2,\"lable\":\"دستور بات\",\"imageUrl\":\"\",\"value\":\"/start\",\"width\":0,\"height\":0},{\"actionType\":3,\"lable\":\"کانال آی گپ\",\"imageUrl\":\"https://lh3.googleusercontent.com/crtxcLqrnVf47QG6LBjQbn5ZeXJBBGO4xCmAZC-e8afPMe0oV1sJktNALFP2mTM83Q\\u003ds360-rw\",\"value\":\"@official\",\"width\":100,\"height\":100}]]"
        
        do {
            if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
                let jsonArrayMain = try JSON(data: dataFromString)
                
                var arrayMain = [[IGStructAdditionalButton]]()
                for (_, jsonArray):(String, JSON) in jsonArrayMain {
                    var subArray:[IGStructAdditionalButton] = []
                    for (_, subJson):(String, JSON) in jsonArray {
                        subArray.append(IGStructAdditionalButton(json: subJson))
                    }
                    arrayMain.append(subArray)
                }
                
                return arrayMain
            }
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
