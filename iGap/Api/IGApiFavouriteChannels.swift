//
//  IGApiFavouriteChannels.swift
//  iGap
//
//  Created by hossein nazari on 9/1/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire

public class IGApiFavouriteChannels {
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
    
    private func getHeaders() -> HTTPHeaders {
        let authorization = "Bearer " + IGAppManager.sharedManager.getAccessToken()!
        let headers: HTTPHeaders = ["Authorization": authorization]
        return headers
    }
    
    func homeItems(completion: @escaping ((_ success: Bool, _ items: [FavouriteChannelHomeItem]) -> Void) ) {
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.homePage.url)
        debugPrint("=========Request Headers=========")
        debugPrint(getHeaders())
        
        Alamofire.request(Endpoint.homePage.url, headers: getHeaders()).responseFavouriteChannelsArray(type: FavouriteChannelHomeItem.self) { response in
            
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
        debugPrint(getHeaders())
        
        Alamofire.request(Endpoint.categoryInfo(id: categoryId, page: page).url, headers: getHeaders()).responseCategoryInfo { response in
            
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
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try JSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseFavouriteChannelsArray<T: Decodable>(type: T.Type, queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FavouriteChannelsArray<T>>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseCategoryInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<FavouriteChannelCategoryInfo>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
