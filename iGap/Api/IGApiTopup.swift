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

class IGApiTopup: IGApiBase {
    
    enum Endpoint {
        case purchase
        
        var url: String {
            var urlString = IGApiTopup.topupBaseUrl
            
            switch self {
            case .purchase:
                urlString += "/purchase"
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiTopup()
    private static let topupBaseUrl = "https://api.igap.net/services/v1.0/mci/topup"
    
    func purchase(telNum: String, cost: Int64, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "cost" : cost]
        
        AF.request(Endpoint.purchase.url, method: .post, parameters: parameters, headers: self.getHeader()).responseJSON { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.purchase(telNum: telNum, cost: cost, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard let token = json["token"].string else {
                        guard let message = json["message"].string else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            
                            completion(false, nil)
                            return
                        }
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    completion(true, token)
                    
                case .failure(_):
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
}


