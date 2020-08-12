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

class IGApiPayment: IGApiBase {
    
    enum Endpoint {
        case orderCheck(token: String)
        case orderStatus(orderId: String)
        
        var url: String {
            var urlString = IGApiPayment.paymentBaseUrl
            
            switch self {
            case .orderCheck(_):
                urlString += ""
            case .orderStatus(_):
                urlString += ""
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiPayment()
    private static let paymentBaseUrl = ""
    private var getStatusCount = 0
    
    func orderCheck(token: String, completion: @escaping ((_ success: Bool, _ response: IGStructPayment?, _ errorMessage: String?) -> Void) ) {
        
    }
    
    func orderStatus(orderId: String, completion: @escaping ((_ success: Bool, _ response: IGStructPaymentStatus?) -> Void) ) {
        
    }
}

extension DataRequest {
    
    @discardableResult
    func responsePayment(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructPayment>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
}
