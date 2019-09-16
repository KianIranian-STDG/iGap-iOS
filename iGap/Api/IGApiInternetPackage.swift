//
//  IGApiInternetPackage.swift
//  iGap
//
//  Created by MacBook Pro on 6/21/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

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
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.categories.url)
        debugPrint("=========Request Headers=========")
        debugPrint(self.getHeaders)
        
        Alamofire.request(Endpoint.categories.url, method: .get, headers: self.getHeaders).responseData { (response) in
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response?.allHeaderFields ?? "no headers")
            debugPrint("=========Response Body=========")
            let dataString = String(data: response.data ?? Data(), encoding: String.Encoding.utf8) ?? "Data could not be printed"
            debugPrint(dataString)
            
            switch response.result {
                
            case .success(let value):
                
                do {
                    let dataString = String(data: value, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    print(dataString)
                    let classData = try JSONDecoder().decode([FailableDecodable<IGStructInternetCategory>].self, from: value).compactMap { $0.base }
                    completion(true, classData)
                } catch let error {
                    print(error.localizedDescription)
                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: "unable to decode data")
                    completion(false, nil)
                }
                
            case .failure(let error):
                guard let data = response.data else {
                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: "unable to get data")
                    completion(false, nil)
                    return
                }
                let json = try? JSON(data: data)
                guard let message = json?["message"].string else {
                    print(error.localizedDescription)
                    IGHelperAlert.shared.showErrorAlert()
                    completion(false, nil)
                    return
                }
                IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                completion(false, nil)
            }
        }
    }
    
    func getPackages(completion: @escaping ((_ success: Bool, _ token: IGStructInternetPackageCategorized?) -> Void) ) {
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.categories.url)
        debugPrint("=========Request Headers=========")
        debugPrint(self.getHeaders)
        
        Alamofire.request(Endpoint.packages.url, method: .get, headers: self.getHeaders).responseData { (response) in
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response?.allHeaderFields ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(response.data ?? "NO RESPONSE BODY")
            
            switch response.result {
                
            case .success(let value):
                
                do {
                    let classData = try JSONDecoder().decode(IGStructInternetPackageCategorized.self, from: value)
                    completion(true, classData)
                } catch {
                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: "unable to decode data")
                    completion(false, nil)
                }
                
            case .failure(let error):
                guard let data = response.data else {
                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: "unable to get data")
                    completion(false, nil)
                    return
                }
                let json = try? JSON(data: data)
                guard let message = json?["message"].string else {
                    print(error.localizedDescription)
                    IGHelperAlert.shared.showErrorAlert()
                    completion(false, nil)
                    return
                }
                IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                completion(false, nil)
            }
        }
    }
    
    func purchase(telNum: String, type: String, completion: @escaping ((_ success: Bool, _ token: String?) -> Void) ) {
        
        let parameters: Parameters = ["tel_num" : telNum, "type" : type]
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.purchase.url)
        debugPrint("=========Request Headers=========")
        debugPrint(getHeaders)
        debugPrint("=========Request Parameters=========")
        debugPrint(parameters)
        
        Alamofire.request(Endpoint.purchase.url, method: .post, parameters: parameters, headers: getHeaders).responseJSON { (response) in
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(response.result.value ?? "NO RESPONSE BODY")
            
            switch response.result {
                
            case .success(let value):
                let json = JSON(value)
                guard let token = json["token"].string else {
                    guard let message = json["message"].string else {
                        IGHelperAlert.shared.showErrorAlert()
                        completion(false, nil)
                        return
                    }
                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                    completion(false, nil)
                    return
                }
                completion(true, token)
                
            case .failure(let error):
                print(error.localizedDescription)
                IGHelperAlert.shared.showErrorAlert()
                completion(false, nil)
            }
        }
    }
    
}
