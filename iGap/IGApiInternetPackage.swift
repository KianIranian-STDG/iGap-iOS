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
typealias PSInternetPackagesResponse = (_ list: [IGPSInternetPackages]?, _ error: String?) -> Void
typealias PSInternetCategoriesResponse = (_ list: [IGPSInternetCategory]?, _ error: String?) -> Void
typealias PSLastPackagesResponse = (_ list: [IGPSLastInternetPackagesPurchases]?, _ error: String?) -> Void

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
        
        case LastPackages

        case MTNSetFavourites
        case MCISetFavourites
        case rightelSetFavourites

        var url: String {
            var urlString = IGApiInternetPackage.internetPackageBaseUrl
            
            switch self {
            case .LastPackages :
                urlString += "/internet-package/get-favorite"
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
                case .MTNSetFavourites:
                    urlString += "/mtn/internet-package/set-favorite"
                case .MCISetFavourites:
                    urlString += "/mci/internet-package/set-favorite"
                case .rightelSetFavourites:
                    urlString += "/rightel/internet-package/set-favorite"
                }

            return urlString
        }
    }
    
    static let shared = IGApiInternetPackage()
    private static let internetPackageBaseUrl = "https://api.igap.net/operator-services/v1.0"
    
    
    func getCategories(opType: selectedOperator = .MCI,completion: @escaping PSInternetCategoriesResponse ) {
        
        var urlinner = Endpoint.MCIcategories.url
        switch opType {
        case .MCI : urlinner = Endpoint.MCIcategories.url
        case .MTN : urlinner = Endpoint.MTNcategories.url
        case .Rightel : urlinner = Endpoint.RIGHTELcategories.url
        default:
            urlinner = Endpoint.MCIcategories.url
        }

        AF.request(urlinner, method: .get, headers: self.getHeader()).responseGetCategories {[weak self] (response) in
                  guard let sSelf = self else {
                      return
                  }
                  
                  if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                    sSelf.getCategories(opType: opType ,completion: completion)
                  }) {
                      
                  } else {
                      
                      guard let statusCode = response.response?.statusCode else {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }

                      if statusCode != 200 {
                          do {
                              let json = try JSON(data: response.data!)
                              guard let msg = json["message"].string else {
                                  completion(nil, IGStringsManager.ServerError.rawValue.localized)
                                  return
                              }
                              completion(nil, msg)
                              return

                          }catch {
                              completion(nil, IGStringsManager.ServerError.rawValue.localized)
                              return
                          }
                      }


                    guard let data = response.value else {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }
                      
        
                      
                      completion(data, nil)
                      return

                  }
              }
        
    }
    
    func getPackages(opType: selectedOperator = .MCI,type: String = "CREDIT" ,completion: @escaping PSInternetPackagesResponse ) {
        var urlinner = Endpoint.MCIcategories.url
        switch opType {
        case .MCI : urlinner = Endpoint.MCIpackages.url
        case .MTN : urlinner = Endpoint.MTNpackages.url
        case .Rightel : urlinner = Endpoint.RIGHTELpackages.url
        default:
            urlinner = Endpoint.MCIcategories.url
        }
        urlinner += "?type=\(type)"

        AF.request(urlinner, method: .get, headers: self.getHeader()).responseGetInternetPackages {[weak self] (response) in
                  guard let sSelf = self else {
                      return
                  }
                  
                  if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                    sSelf.getPackages(opType: opType, type : type ,completion: completion)
                  }) {
                      
                  } else {
                      
                      guard let statusCode = response.response?.statusCode else {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }

                      if statusCode != 200 {
                          do {
                              let json = try JSON(data: response.data!)
                              guard let msg = json["message"].string else {
                                  completion(nil, IGStringsManager.ServerError.rawValue.localized)
                                  return
                              }
                              completion(nil, msg)
                              return

                          }catch {
                              completion(nil, IGStringsManager.ServerError.rawValue.localized)
                              return
                          }
                      }


                    guard let data = response.value else {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }
                      
        
                      
                      completion(data.data, nil)
                      return

                  }
              }
        
    }
    
    
    func getVolumes(opType: selectedOperator = .MCI ,completion: @escaping PSInternetPackagesResponse ) {
        var urlinner = Endpoint.MCIcategories.url
        switch opType {
        case .MCI : urlinner = Endpoint.MCIpackages.url
        case .MTN : urlinner = Endpoint.MTNpackages.url
        case .Rightel : urlinner = Endpoint.RIGHTELpackages.url
        default:
            urlinner = Endpoint.MCIcategories.url
        }
        AF.request(urlinner, method: .get, headers: self.getHeader()).responseGetInternetPackages {[weak self] (response) in
                  guard let sSelf = self else {
                      return
                  }
                  
                  if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                    sSelf.getPackages(opType: opType ,completion: completion)
                  }) {
                      
                  } else {
                      
                      guard let statusCode = response.response?.statusCode else {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }

                      if statusCode != 200 {
                          do {
                              let json = try JSON(data: response.data!)
                              guard let msg = json["message"].string else {
                                  completion(nil, IGStringsManager.ServerError.rawValue.localized)
                                  return
                              }
                              completion(nil, msg)
                              return

                          }catch {
                              completion(nil, IGStringsManager.ServerError.rawValue.localized)
                              return
                          }
                      }


                    guard let data = response.value else {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }
                      
        
                      
                      completion(data.data, nil)
                      return

                  }
              }
        
    }

      func getLastPurchases(completion: @escaping PSLastPackagesResponse){
          let url = Endpoint.LastPackages.url
          AF.request(url,  method: .get, headers: self.getHeader()).responseLastPurchase {[weak self] (response) in
              guard let sSelf = self else {
                  return
              }
              
              if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                  sSelf.getLastPurchases(completion: completion)
              }) {
                  
              } else {
                  guard let statusCode = response.response?.statusCode else {
                      completion(nil, IGStringsManager.ServerError.rawValue.localized)
                      return
                  }

                  if statusCode != 200 {
                      do {
                          let json = try JSON(data: response.data!)
                          guard let msg = json["message"].string else {
                              completion(nil, IGStringsManager.ServerError.rawValue.localized)
                              return
                          }
                          completion(nil, msg)
                          return

                      }catch {
                          completion(nil, IGStringsManager.ServerError.rawValue.localized)
                          return
                      }
                  }


                  guard let data = response.value else {
                      completion(nil, IGStringsManager.ServerError.rawValue.localized)
                      return
                  }
                  
    
                  
                  completion(data.data, nil)
                  return

              }
          }
          
      }
    
    func saveToHistory(opType : String, telNum: String, chargeType: String,packageType: String, completion: @escaping ((_ success: Bool) -> Void)) {
        let parameters: Parameters = ["phone_number" : telNum.dropFirst(), "charge_type" : chargeType, "package_type" : packageType]
        var url = Endpoint.MCISetFavourites.url
        switch opType {
        case "MCI" : url = Endpoint.MCISetFavourites.url
        case "MTN" : url = Endpoint.MTNSetFavourites.url
        case "RIGHTEL" : url = Endpoint.rightelSetFavourites.url
        default : url = Endpoint.MCISetFavourites.url
        }
        
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseJSON { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.saveToHistory(opType: opType, telNum: telNum, chargeType: chargeType, packageType: packageType, completion: completion)
            }) {
            } else {
                switch response.result {
                case .success(_):

                    completion(true)

                case .failure(_):
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false)
                }
            }
        }

    }
    func purchase(opType: selectedOperator,telNum: String, type: String, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "type" : type]
       var urlinner = Endpoint.MCIpurchase.url
       switch opType {
       case .MCI : urlinner = Endpoint.MCIpurchase.url
       case .MTN : urlinner = Endpoint.MTNpurchase.url
       case .Rightel : urlinner = Endpoint.RIGHTELpurchase.url
       default:
           urlinner = Endpoint.MCIpurchase.url
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
extension DataRequest {
    
    @discardableResult
    func responseGetInternetPackages(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseResponseArrayModel<IGPSInternetPackages>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseGetCategories(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<[IGPSInternetCategory]>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseLastPurchase(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseResponseArrayModel<IGPSLastInternetPackagesPurchases>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
}
