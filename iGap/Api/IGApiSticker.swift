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

class IGApiSticker: IGApiBase {
    
    static let shared = IGApiSticker()
    private let urlSticker = "https://api.igap.net/sticker/v1.0"
    private let urlStickerCategory = "https://api.igap.net/sticker/v1.0/category"
    
    private func getStickerHeaders() -> HTTPHeaders {
        return IGApiBase.sharedApiBase.getHeader()
    }
    
    func stickerCategories(completion: @escaping ((_ stickerCategories :[StickerCategory]) -> Void)) {
        AF.request(urlStickerCategory, headers: self.getStickerHeaders()).responseStickerCategories { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.stickerCategories(completion: completion)
            }) {
            } else if let stickerApi = response.value {
                completion(stickerApi.data)
            }
        }
    }
    
    func stickerCategory(categoryId: String, offset: Int, limit: Int, completion: @escaping ((_ stickers :[StickerTab]) -> Void)) {
        let parameters: Parameters = ["skip" : offset, "limit" : limit]
        let url: String! = urlStickerCategory + "/" + categoryId
        AF.request(url, parameters: parameters, headers: self.getStickerHeaders()).responseStickerApi { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.stickerCategory(categoryId: categoryId, offset: offset, limit: limit, completion: completion)
            }) {
            } else if let stickerApi = response.value {
                completion(stickerApi.data)
            }
        }
    }
    
    func stickerGroup(groupId: String, completion: @escaping ((_ stickers :[StickerTab]) -> Void)) {
        let url: String! = urlSticker + "/main/" + groupId
        AF.request(url!, headers: self.getStickerHeaders()).responseStickerGroup { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.stickerGroup(groupId: groupId, completion: completion)
            }) {
            } else if let stickerApi = response.value {
                completion([stickerApi])
            }
        }
    }
    
    func fetchMySticker(){
        let url = urlSticker + "/user-list"
      
        AF.request(url, headers: self.getStickerHeaders()).responseStickerApi { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.fetchMySticker()
            }) {
            } else if let stickerApi = response.value {
                IGFactory.shared.removeAllSticker()
                IGFactory.shared.addSticker(stickers: stickerApi.data)
            }
        }
    }
    
    func addSticker(groupId: String, completion: @escaping ((_ success :Bool) -> Void)) {
        let urlAddSticker = urlSticker + "/user-list/" + groupId
        AF.request(urlAddSticker, method: .post, headers: self.getStickerHeaders()).responseJSON { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.addSticker(groupId: groupId, completion: completion)
            }) {
            } else {
                completion(true) // TODO - Check success
            }
        }
    }
    
    func removeSticker(groupId: String, completion: @escaping ((_ success :Bool) -> Void)) {
        let urlRemoveSticker = urlSticker + "/user-list/delete"
        AF.request(urlRemoveSticker, method: .post, parameters: IGHelperJson.makeStickerGroupIds(id: groupId), encoding: JSONEncoding.default, headers: self.getStickerHeaders()).responseJSON { response in
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.removeSticker(groupId: groupId, completion: completion)
            }) {
            } else {
                completion(true) // TODO - Check success
            }
        }
    }
    
    func checkNationalCode(nationalCode: String?, mobileNumber: String, completion: @escaping ((_ success :Bool) -> Void)){
    }
    
    func getGiftableStickerGroups(offset: Int, limit: Int, completion: @escaping ((_ stickers :[StickerTab]) -> Void)){
    }
    
    func checkBuyGiftCard(stickerId: String, nationalCode: String, mobileNumber: String, count: Int, completion: @escaping ((_ buyGiftSticker : BuyGiftSticker) -> Void), error: @escaping (() -> Void)){
    }
    
    func giftStickerPaymentRequest(token: String, completion: @escaping ((_ giftCardPayment : IGStructGiftCardPayment) -> Void), error: @escaping (() -> Void)){
    }
    
    func giftStickerFirstPageInfo(completion: @escaping ((_ giftFirstPageInfo : IGStructGiftFirstPageInfo) -> Void)){
    }
    
    func giftStickerCardsList(status: GiftStickerListType, completion: @escaping ((_ giftCardList : IGStructGiftCardList) -> Void)){
    }
    
    func getGiftCardGetStatus(stickerId: String, completion: @escaping ((_ giftCardStatus : IGStructGiftCardStatus) -> Void), error: @escaping (() -> Void)){
    }
    
    func giftCardActivate(stickerId: String, nationalCode: String, mobileNumber: String, completion: @escaping ((_ giftCardEncryptedData : IGStructStickerEncryptData) -> Void), error: @escaping (() -> Void)){
    }
    
    func getGiftCardInfo(stickerId: String, nationalCode: String, mobileNumber: String, completion: @escaping ((_ giftCardEncryptedData : IGStructGiftCardInfo) -> Void), error: @escaping (() -> Void)){
    }
    
    func giftStickerForward(userId: String, stickerId: String, completion: @escaping ((_ success :Bool) -> Void)){
    }
    
    func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
    
    func newJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            encoder.dateEncodingStrategy = .iso8601
        }
        return encoder
    }
}

extension DataRequest {
    
    @discardableResult
    func responseStickerCategories(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<StickerCategories>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseStickerApi(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<StickerApi>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseStickerGroup(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<StickerTab>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseCheckBuyGiftCard(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<BuyGiftSticker>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseGiftCardPayment(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructGiftCardPayment>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseGiftFirstPageInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructGiftFirstPageInfo>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseGiftCardsList(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructGiftCardList>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseGiftCardStatus(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructGiftCardStatus>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseGiftCardEncryptData(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGStructStickerEncryptData>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
}
