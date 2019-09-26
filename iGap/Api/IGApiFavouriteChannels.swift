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

class IGApiFavouriteChannels: IGApiBase {
    enum Endpoint {
        case homePage
        case categoryInfo(id: String, page: Int)
        
        var url: String {
            var urlString = IGApiFavouriteChannels.beeptunesBaseUrl
            
            switch self {
            case .homePage:
                break
            case .categoryInfo(let id, let page):
                urlString += "/category/\(id)?page=\(page)"
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiFavouriteChannels()
    private static let beeptunesBaseUrl = "https://api.igap.net/services/v1.0/channel"
    
    func homeItems(completion: @escaping ((_ success: Bool, _ items: [FavouriteChannelHomeItem]) -> Void) ) {
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.homePage.url)
        debugPrint("=========Request Headers=========")
        debugPrint(self.getHeaders)
        
        AF.request(Endpoint.homePage.url, headers: self.getHeaders).responseFavouriteChannelsArray(type: FavouriteChannelHomeItem.self) { response in
            
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
    
    func getCategoryInfo(for categoryId: String, page: Int, completion: @escaping ((_ success: Bool, _ categoryInfo: FavouriteChannelCategoryInfo?) -> Void) ) {
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.homePage.url)
        debugPrint("=========Request Headers=========")
        debugPrint(self.getHeaders)
        
        AF.request(Endpoint.categoryInfo(id: categoryId, page: page).url, headers: self.getHeaders).responseCategoryInfo { response in
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(response.result.value ?? "NO RESPONSE BODY")
            
            guard let categoryInfo = response.result.value else {
                completion(false, nil)
                print("error", response.error ?? "")
                return
            }
            completion(true, categoryInfo)
        }
    }
}

extension DataRequest {
    
    @discardableResult
    func responseFavouriteChannelsArray<T: Decodable>(type: T.Type, queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FavouriteChannelsArray<T>>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseCategoryInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FavouriteChannelCategoryInfo>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
