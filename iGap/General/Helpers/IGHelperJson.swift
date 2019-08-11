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
    
    /*************************************************************************/
    /**************************** Popular Method *****************************/
    
    private static func getJson(data: String) -> JSON? {
        do {
            if let dataFromString = data.data(using: .utf8, allowLossyConversion: false) {
                return try JSON(data: dataFromString)
            }
        } catch let error {
            print(error)
        }
        return nil
    }

    /*************************************************************************/
    /*************************** Additional Button ***************************/
    
    internal static func parseAdditionalButton(data: String?) -> [[IGStructAdditionalButton]]? {
        
        if data == nil {return nil}
        
        do {
            if let dataFromString = data!.data(using: .utf8, allowLossyConversion: false) {
                let jsonArrayMain = try JSON(data: dataFromString)
                
                var arrayMain = [[IGStructAdditionalButton]]()
                for (_, jsonArray):(String, JSON) in jsonArrayMain {
                    var subArray:[IGStructAdditionalButton] = []
                    for (_, subJson):(String, JSON) in jsonArray {
                        let structAdt = IGStructAdditionalButton(json: subJson)
                        subArray.append(structAdt)
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
    
    internal static func parseAdditionalPayDirect(data: Any) -> IGStructAdditionalPayDirect? {
        return IGStructAdditionalPayDirect(json: JSON(arrayLiteral: data)[0])
    }
    internal static func parseAdditionalCardToCardInChat(data: Any) -> IGStructAdditionalCardToCard? {
        return IGStructAdditionalCardToCard(json: JSON(arrayLiteral: data)[0])
    }
    
    internal static func parseBillInfo(data: String) -> IGStructBillInfo? {
        do {
            if let dataFromString = data.data(using: .utf8, allowLossyConversion: false) {
                let jsonBillInfo = try JSON(data: dataFromString)
                return IGStructBillInfo(json: jsonBillInfo)
            }
        } catch let error {
            print(error)
        }
        return nil
    }
    internal static func parseAdditional(data: String?) -> [[IGStructAdditional]]? {
        
        if data == nil {return nil}
        
        do {
            if let dataFromString = data!.data(using: .utf8, allowLossyConversion: false) {
                let jsonArrayMain = try JSON(data: dataFromString)
                
                var arrayMain = [[IGStructAdditional]]()
                for (_, jsonArray):(String, JSON) in jsonArrayMain {
                    var subArray:[IGStructAdditional] = []
                    for (_, subJson):(String, JSON) in jsonArray {
                        let structAdt = IGStructAdditional(json: subJson)
                        subArray.append(structAdt)
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

    
    /*************************************************************************/
    /******************************** Sticker ********************************/
    
    /* convert message additional data to sticker struct */
    internal static func parseStickerMessage(data: String) -> IGStructStickerMessage? {
        if let json = getJson(data: data) {
            return IGStructStickerMessage(json)
        }
        return nil
    }
    
    /* convert message additional data to sticker struct */
    internal static func convertRealmToJson(stickerItem: IGRealmStickerItem) -> String? {
      
        let dict = ["id" : stickerItem.id,
                    "refId" : stickerItem.refID,
                    "name" : stickerItem.name,
                    "token" : stickerItem.token,
                    "fileName" : stickerItem.fileName,
                    "fileSize" : stickerItem.fileSize,
                    "sort" : stickerItem.sort,
                    "groupId": stickerItem.groupID] as [String: Any?]
        
        let json = JSON(dict).rawString()
        return json
    }
    
}
