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

class IGApiTopup {
    
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
    
    static let shared = IGApiPayment()
    private static let topupBaseUrl = "https://api.igap.net/services/v1.0/mci/topup"
    
    private func getHeaders() -> HTTPHeaders {
        let authorization = "Bearer " + IGAppManager.sharedManager.getAccessToken()!
        let headers: HTTPHeaders = ["Authorization": authorization]
        return headers
    }
    
    func orderChech(telNum: String, cost: Int, completion: @escaping ((_ success: Bool, _ items: [FavouriteChannelHomeItem]) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "cost" : cost]

        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.purchase.url)
        debugPrint("=========Request Headers=========")
        debugPrint(getHeaders())
        debugPrint("=========Request Parameters=========")
        debugPrint(parameters)

        Alamofire.request(Endpoint.purchase.url, method: .post, parameters: parameters, headers: getHeaders()).responseFavouriteChannelsArray(type: FavouriteChannelHomeItem.self) { response in

            debugPrint("=========Response Headers=========")
            debugPrint(response.response ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(response.result.value ?? "NO RESPONSE BODY")

            guard let items = response.result.value?.data else {
                completion(false, [])
                print("error", response.error ?? "")
                return
            }
            completion(true, items)
        }
    }
}
