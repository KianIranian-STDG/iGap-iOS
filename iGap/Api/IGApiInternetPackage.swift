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

class IGApiInternetPackage: IGApiBase {
    
    enum Endpoint {
        case categories
        case packages
        case purchase
        
        var url: String {
            var urlString = IGApiInternetPackage.internetPackageBaseUrl
            
            switch self {
            case .categories:
                urlString += "/categories"
                
            case .packages:
                urlString += "/packages/categorized"
                
            case .purchase:
                urlString += "/purchase"
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiInternetPackage()
    private static let internetPackageBaseUrl = "https://api.igap.net/services/v1.0/mci/internet-package"
    
    func getCategories(completion: @escaping ((_ success: Bool, _ token: [IGStructInternetCategory]?) -> Void) ) {
        
        AF.request(Endpoint.categories.url, method: .get, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getCategories(completion: completion)
            }) {
            } else {
                switch response.result {
                    
                case .success(let value):
                    
                    do {
                        let dataString = String(data: value, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                        print(dataString)
                        let classData = try JSONDecoder().decode([FailableDecodable<IGStructInternetCategory>].self, from: value).compactMap { $0.base }
                        completion(true, classData)
                    } catch _ {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        print(error.localizedDescription)
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
        
    }
    
    func getPackages(completion: @escaping ((_ success: Bool, _ token: IGStructInternetPackageCategorized?) -> Void) ) {
        
        AF.request(Endpoint.packages.url, method: .get, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getPackages(completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    
                    do {
                        let classData = try JSONDecoder().decode(IGStructInternetPackageCategorized.self, from: value)
                        completion(true, classData)
                    } catch {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(_):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
    func purchase(telNum: String, type: String, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "type" : type]
       
        AF.request(Endpoint.purchase.url, method: .post, parameters: parameters, headers: self.getHeader()).responseJSON { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.purchase(telNum: telNum, type: type, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard let token = json["token"].string else {
                        guard json["message"].string != nil else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            completion(false, nil)
                            return
                        }
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    completion(true, token)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.UnsuccessOperation.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
}
