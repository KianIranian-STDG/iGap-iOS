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
        
        var url: String {
            var urlString = IGApiInternetPackage.internetPackageBaseUrl
            
            switch self {
            case .categories:
                urlString += "/categories"
                
            case .packages:
                urlString += "/packages/categorized"
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
            debugPrint(response.data ?? "NO RESPONSE BODY")
            
            switch response.result {
                
            case .success(let value):
                
                do {
                    let classData = try JSONDecoder().decode([IGStructInternetCategory].self, from: value)
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
    
    func getPackages(completion: @escaping ((_ success: Bool, _ token: IGStructInternetPackage?) -> Void) ) {
        
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
                    let classData = try JSONDecoder().decode(IGStructInternetPackage.self, from: value)
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
    
}
