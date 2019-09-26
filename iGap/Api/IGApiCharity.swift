//
//  IGApiCharity.swift
//  iGap
//
//  Created by MacBook Pro on 6/27/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class IGApiCharity: IGApiBase {
    enum Endpoint {
        case help(charityId: String)
        
        var url: String {
            var urlString = IGApiCharity.charityBaseUrl
            
            switch self {
            case .help(charityId: let id):
                urlString += "/help/\(id)"
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiCharity()
    private static let charityBaseUrl = "https://api.igap.net/services/v1.0/charity"
    
    func getHelpPaymentToken(charityId: String, amount: Int, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["amount" : amount]

        AF.request(Endpoint.help(charityId: charityId).url, method: .post, parameters: parameters, headers: getHeaders).responseJSON { (response) in
      
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
                completion(false, nil)
            }
        }
    }
}
