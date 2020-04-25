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
        case MCIcategories
        case MCIpackages
        case MCIpurchase

        case MTNcategories
        case MTNpackages
        case MTNpurchase

        case RIGHTELcategories
        case RIGHTELpackages
        case RIGHTELpurchase

        var url: String {
            var urlString = IGApiInternetPackage.internetPackageBaseUrl
            
            switch self {
            case .MCIcategories:
                urlString += "/mci/internet-package/categories"
            case .MCIpackages:
                urlString += "/mci/internet-package/packages/categorized"
            case .MCIpurchase:
                urlString += "/mci/internet-package/purchase"
            case .MTNcategories:
                urlString += "/mtn/internet-package/categories"
            case .MTNpackages:
                urlString += "/mtn/internet-package/packages/categorized"
            case .MTNpurchase:
                urlString += "/mtn/internet-package/purchase"
            case .RIGHTELcategories:
                urlString += "/rightel/internet-package/categories"
            case .RIGHTELpackages:
                urlString += "/rightel/internet-package/packages/categorized"
            case .RIGHTELpurchase:
                urlString += "/rightel/internet-package/purchase"
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiInternetPackage()
    private static let internetPackageBaseUrl = "https://api.igap.net/services/v1.0"
    
    func getCategories(opType: IGOperator = .mci,completion: @escaping ((_ success: Bool, _ token: [IGStructInternetCategory]?) -> Void) ) {
        var urlinner = Endpoint.MCIcategories.url
        switch opType {
        case .mci : urlinner = Endpoint.MCIcategories.url
        case .irancell : urlinner = Endpoint.MTNcategories.url
        case .rightel : urlinner = Endpoint.RIGHTELcategories.url
        default:
            urlinner = Endpoint.MCIcategories.url
        }
        AF.request(urlinner, method: .get, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getCategories(opType: opType,completion: completion)
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
    
    func getPackages(opType: IGOperator, completion: @escaping ((_ success: Bool, _ token: IGStructInternetPackageCategorized?) -> Void) ) {
        var urlinner = Endpoint.MCIcategories.url
        switch opType {
        case .mci : urlinner = Endpoint.MCIpackages.url
        case .irancell : urlinner = Endpoint.MTNpackages.url
        case .rightel : urlinner = Endpoint.RIGHTELpackages.url
        default:
            urlinner = Endpoint.MCIcategories.url
        }

        AF.request(urlinner, method: .get, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getPackages(opType: opType, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    
                    do {
                        let classData = try JSONDecoder().decode(IGStructInternetPackageCategorized.self, from: value)
                        completion(true, classData)
                    } catch {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                    }
                    
                case .failure(_):
                    guard let data = response.data else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    let json = try? JSON(data: data)
                    guard let message = json?["message"].string else {
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
    
    func purchase(opType: IGOperator,telNum: String, type: String, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "type" : type]
       var urlinner = Endpoint.MCIcategories.url
       switch opType {
       case .mci : urlinner = Endpoint.MCIpurchase.url
       case .irancell : urlinner = Endpoint.MTNpurchase.url
       case .rightel : urlinner = Endpoint.RIGHTELpurchase.url
       default:
           urlinner = Endpoint.MCIcategories.url
       }

        AF.request(urlinner, method: .post, parameters: parameters, headers: self.getHeader()).responseJSON { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.purchase(opType: opType, telNum: telNum, type: type, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard let token = json["token"].string else {
                        guard json["message"].string != nil else {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            completion(false, nil)
                            return
                        }
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil)
                        return
                    }
                    completion(true, token)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil)
                }
            }
        }
    }
    
}
