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
import Alamofire
import SwiftyJSON

//typealias PSBaseResponse = (_ message: String?, _ error: String?) -> Void
typealias PSLastTopUpsResponse = (_ list: [IGPSLastTopUpPurchases]?, _ error: String?) -> Void

class IGApiTopup: IGApiBase {
    
    enum Endpoint {
        case purchase
        case MCITopUp
        case rightelTopUp
        case MTNTopUp
        case LastPurchases
        var url: String {
            var urlString = IGApiTopup.topupPurchasesBaseUrl
            
            switch self {
            case .purchase:
                urlString += "/purchase"
            case .MTNTopUp:
                urlString += "/mtn/topup/purchase"
            case .rightelTopUp:
                urlString += "/rightel/topup/purchase"
            case .MCITopUp:
                urlString += "/mci/topup/purchase"
            case .LastPurchases:
                urlString += "/topup/get-favorite"
            }
                
            return urlString
        }
    }
    
    static let shared = IGApiTopup()
//    private static let topupBaseUrl = "https://api.igap.net/services/v1.0"
    private static let topupPurchasesBaseUrl = "https://api.igap.net/operator-services/v1.0"

    func getLastPurchases(completion: @escaping PSLastTopUpsResponse){
        let url = Endpoint.LastPurchases.url
        AF.request(url,  method: .get, headers: self.getHeader()).responseGetLastTopUps {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.getLastPurchases(completion: completion)
            }) {
                
            } else {
                
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, IGStringsManager.ServerError.rawValue.localized)
                    return
                }

                if statusCode != 200 {
                    do {
                        let json = try JSON(data: response.data!)
                        guard let msg = json["message"].string else {
                            completion(nil, IGStringsManager.ServerError.rawValue.localized)
                            return
                        }
                        completion(nil, msg)
                        return

                    }catch {
                        completion(nil, IGStringsManager.ServerError.rawValue.localized)
                        return
                    }
                }


                guard let data = response.value else {
                    completion(nil, IGStringsManager.ServerError.rawValue.localized)
                    return
                }
                
  
                
                completion(data.data, nil)
                return

            }
        }
        
    }
    
    func chargeSimCard(opType : String, telNum: String, cost: Int64,type: String, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum.dropFirst(), "cost" : cost, "type" : type]
        var url = Endpoint.purchase.url
        switch opType {
        case "MCI" : url = Endpoint.MCITopUp.url
        case "MTN" : url = Endpoint.MTNTopUp.url
        case "RIGHTEL" : url = Endpoint.rightelTopUp.url
        default : url = Endpoint.purchase.url
        }
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseJSON { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.purchase(opType: opType, telNum: telNum, cost: cost, type: type, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard let token = json["token"].string else {
                        guard let message = json["message"].string else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            
                            completion(false, nil)
                            return
                        }
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    completion(true, token)
                    
                case .failure(_):
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    func purchase(opType : String, telNum: String, cost: Int64,type: String, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum.dropFirst(), "cost" : cost, "type" : type]
        var url = Endpoint.purchase.url
        switch opType {
        case "MCI" : url = Endpoint.MCITopUp.url
        case "MTN" : url = Endpoint.MTNTopUp.url
        case "RIGHTEL" : url = Endpoint.rightelTopUp.url
        default : url = Endpoint.purchase.url
        }
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseJSON { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.purchase(opType: opType, telNum: telNum, cost: cost, type: type, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard let token = json["token"].string else {
                        guard let message = json["message"].string else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            
                            completion(false, nil)
                            return
                        }
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    completion(true, token)
                    
                case .failure(_):
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
}



extension DataRequest {
    
    @discardableResult
    func responseGetLastTopUps(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseResponseArrayModel<IGPSLastTopUpPurchases>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
}
