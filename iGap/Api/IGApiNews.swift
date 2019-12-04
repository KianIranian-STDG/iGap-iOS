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

class IGApiNews: IGApiBase {
    enum Endpoint {
        
        case mainPageData
        case newsByID(page: String, perPage: String, serviceId: String)
        case mostHitNewsByID(page: String, perPage: String, serviceId: String)
        case mostControversialNewsByID(page: String, perPage: String, serviceId: String)
        case getNewsDetail(articleId: String)
        var url: String {
            var urlString = IGApiNews.newsBaseUrl
            
            switch self {
            case .mainPageData:
                urlString += "/getFirstPageData/igap"
                break
                
            case .newsByID(let page, let perPage, let serviceId):
                urlString += "/getNewsList/igap/?page=\(page)&perpage=\(perPage)&serviceId=\(serviceId)"
                break
            case .mostHitNewsByID(let page, let perPage, let serviceId):
                urlString += "/getHitNewsList/igap/?page=\(page)&perpage=\(perPage)&serviceId=\(serviceId)"
                break
            case .mostControversialNewsByID(let page, let perPage, let serviceId):
                urlString += "/getHighlyControversialNewsList/igap/?page=\(page)&perpage=\(perPage)&serviceId=\(serviceId)"
                break
                
            case .getNewsDetail(let articleId):
                                urlString += "/getNews/igap/?articleId=\(articleId)"
                break

            }
            
            return urlString
        }
    }
    
    static let shared = IGApiNews()
    private static let newsBaseUrl = "https://api.cafetitle.com"
    
    
    func getHomeItems(completion: @escaping ((_ success: Bool, _ token: [IGStructNewsMainPage]?) -> Void) ) {
        
        AF.request(Endpoint.mainPageData.url, method: .get, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getHomeItems(completion: completion)
            }) {
            } else {
                let json = try? JSON(data: response.data ?? Data())
                
                debugPrint("=========Response Headers=========")
                debugPrint(response.response ?? "no headers")
                debugPrint("=========Response Body=========")
                debugPrint(json ?? "NO RESPONSE BODY")
                
                switch response.result {
                    
                case .success(let value):
                    
                    do {
                        let classData = try JSONDecoder().decode([IGStructNewsMainPage].self, from: value)
                        completion(true, classData)
                        
                    } catch _ {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        print(error.localizedDescription)
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
        
    }
    
    //getInner news by categoryID
    
    func getNewsByID(serviceId: String, page: String, perPage: String, completion: @escaping ((_ success: Bool, _ categoryNews: IGStructNewsInnerByID?) -> Void) ) {
        
        AF.request(Endpoint.newsByID(page: page, perPage: perPage, serviceId: serviceId).url, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getNewsByID(serviceId: serviceId, page: page, perPage: perPage, completion: completion)
            }) {
            } else {
                let json = try? JSON(data: response.data ?? Data())
                
                debugPrint("=========Response Headers=========")
                debugPrint(response.response ?? "no headers")
                debugPrint("=========Response URL=========")
                debugPrint(Endpoint.newsByID(page: page, perPage: perPage, serviceId: serviceId).url ?? "no url")
                debugPrint("=========Response Body=========")
                debugPrint(json ?? "NO RESPONSE BODY")
                switch response.result {
                case .success(let value):
                    do {
                        let classData = try JSONDecoder().decode(IGStructNewsInnerByID.self, from: value)
                        completion(true, classData)
                    } catch _ {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        print(error.localizedDescription)
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
    //getInner MostHit news by categoryID
    
    func getMostHitNewsByID(serviceId: String, page: String, perPage: String, completion: @escaping ((_ success: Bool, _ categoryNews: IGStructNewsInnerByID?) -> Void) ) {
        
        AF.request(Endpoint.mostHitNewsByID(page: page, perPage: perPage, serviceId: serviceId).url, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getMostHitNewsByID(serviceId: serviceId, page: page, perPage: perPage, completion: completion)
            }) {
            } else {
                let json = try? JSON(data: response.data ?? Data())
                
                debugPrint("=========Response Headers=========")
                debugPrint(response.response ?? "no headers")
                debugPrint("=========Response URL=========")
                debugPrint(Endpoint.newsByID(page: page, perPage: perPage, serviceId: serviceId).url ?? "no url")
                debugPrint("=========Response Body=========")
                debugPrint(json ?? "NO RESPONSE BODY")
                switch response.result {
                case .success(let value):
                    do {
                        let classData = try JSONDecoder().decode(IGStructNewsInnerByID.self, from: value)
                        completion(true, classData)
                    } catch _ {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        print(error.localizedDescription)
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
    
    //getInner MostHit news by categoryID
    
    func getMostControversialNewsByID(serviceId: String, page: String, perPage: String, completion: @escaping ((_ success: Bool, _ categoryNews: IGStructNewsInnerByID?) -> Void) ) {
        
        AF.request(Endpoint.mostControversialNewsByID(page: page, perPage: perPage, serviceId: serviceId).url, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getMostControversialNewsByID(serviceId: serviceId, page: page, perPage: perPage, completion: completion)
            }) {
            } else {
                let json = try? JSON(data: response.data ?? Data())
                
                debugPrint("=========Response Headers=========")
                debugPrint(response.response ?? "no headers")
                debugPrint("=========Response URL=========")
                debugPrint(Endpoint.newsByID(page: page, perPage: perPage, serviceId: serviceId).url ?? "no url")
                debugPrint("=========Response Body=========")
                debugPrint(json ?? "NO RESPONSE BODY")
                switch response.result {
                case .success(let value):
                    do {
                        let classData = try JSONDecoder().decode(IGStructNewsInnerByID.self, from: value)
                        completion(true, classData)
                    } catch _ {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        print(error.localizedDescription)
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
    
    //getInner news Detail by newsID
    
    func getNewsDetail(articleId: String, completion: @escaping ((_ success: Bool, _ categoryNews: IGStructNewsDetail?) -> Void) ) {
        
        AF.request(Endpoint.getNewsDetail(articleId: articleId).url, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getNewsDetail(articleId: articleId, completion: completion)
            }) {
            } else {
                let json = try? JSON(data: response.data ?? Data())
                

                switch response.result {
                case .success(let value):
                    do {
                        let classData = try JSONDecoder().decode(IGStructNewsDetail.self, from: value)
                        completion(true, classData)
                    } catch _ {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        print(error.localizedDescription)
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
    
}
