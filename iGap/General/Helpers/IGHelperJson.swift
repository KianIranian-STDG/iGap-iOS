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

    internal static func parseAdditionalButton(data: String?) -> [[IGStructAdditionalButton]]? {
        
        if data == nil {return nil}
        
        do {
            if let dataFromString = data!.data(using: .utf8, allowLossyConversion: false) {
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
    
    internal static func getAdditionalButtonRowCount(data: String) -> Int {
        do {
            if let dataFromString = data.data(using: .utf8, allowLossyConversion: false) {
                let jsonArrayMain = try JSON(data: dataFromString)
                return jsonArrayMain.count
            }
        } catch let error {
            print(error)
        }
        return 0
    }
}
