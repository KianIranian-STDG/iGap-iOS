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
    
    func orderChech(telNum: String, cost: Int64, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "cost" : cost]

        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.purchase.url)
        debugPrint("=========Request Headers=========")
        debugPrint(getHeaders)
        debugPrint("=========Request Parameters=========")
        debugPrint(parameters)
        
        Alamofire.request(Endpoint.purchase.url, method: .post, parameters: parameters, headers: getHeaders).responseJSON { (response) in
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(response.result.value ?? "NO RESPONSE BODY")
            
            
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                guard let token = json["token"].string else {
                    guard let message = json["message"].string else {
                        IGHelperAlert.shared.showErrorAlert()
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                    completion(false, nil)
                    return
                }
                completion(true, token)
                
            case .failure(let error):
                print(error.localizedDescription)
                IGHelperAlert.shared.showErrorAlert()
            }
        }
    }
}


