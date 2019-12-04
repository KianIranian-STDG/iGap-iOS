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
        case categoryInfo(id: String, start: Int, display: Int)
        
        var url: String {
            var urlString = IGApiFavouriteChannels.beeptunesBaseUrl
            
            switch self {
            case .homePage:
                break
            case .categoryInfo(let id, let start, let display):
                urlString += "/category/\(id)?start=\(start)&display=\(display)"
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiFavouriteChannels()
    private static let beeptunesBaseUrl = "https://api.igap.net/services/v1.0/channel"
    
    func homeItems(completion: @escaping ((_ success: Bool, _ items: [FavouriteChannelHomeItem]) -> Void) ) {
        AF.request(Endpoint.homePage.url, headers: self.getHeader()).responseFavouriteChannelsArray(type: FavouriteChannelHomeItem.self) { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.homeItems(completion: completion)
            }) {
            } else {
                guard let items = response.value?.data else {
                    completion(false, [])
                    print("error", response.error ?? "")
                    return
                }
                completion(true, items)
            }
        }
    }
    
    func getCategoryInfo(for categoryId: String, start: Int, display: Int, completion: @escaping ((_ success: Bool, _ categoryInfo: FavouriteChannelCategoryInfo?) -> Void) ) {
        AF.request(Endpoint.categoryInfo(id: categoryId, start: start, display: display).url, headers: self.getHeader()).responseCategoryInfo { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getCategoryInfo(for: categoryId, start: start, display: display, completion: completion)
            }) {
            } else {
                guard let categoryInfo = response.value else {
                    completion(false, nil)
                    print("error", response.error ?? "")
                    return
                }
                completion(true, categoryInfo)
            }
        }
    }
}

extension DataRequest {
    
    @discardableResult
    func responseFavouriteChannelsArray<T: Decodable>(type: T.Type, queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<FavouriteChannelsArray<T>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseCategoryInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<FavouriteChannelCategoryInfo>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseNewsByID(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructNewsInnerByID>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
}
