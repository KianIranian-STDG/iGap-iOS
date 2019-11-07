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
import Realm

class IGApiElectricityBill: IGApiBase {
    
    enum Endpoint {
        case addBill
        case getBills
        case queryBill
        case branchingInfo
        
        var url: String {
            var urlString = IGApiElectricityBill.electricityBillBaseUrl
            
            switch self {
            case .queryBill:
                urlString += "/api/get-branch-debit"
            case .addBill:
                break
            case .getBills:
                break
            case .branchingInfo:
                urlString += "/api/get-branch-info"
                
            }
            
            return urlString
        }
    }
    
    static let shared = IGApiElectricityBill()
    private static let electricityBillBaseUrl = "https://api.igap.net/bill/v1.0"
    
    
    func queryBill(billNumber: String,phoneNumber: String, completion: @escaping ((_ success: Bool, _ response: IGStructInqueryBill?, _ errorMessage: String?) -> Void) ) {
        let parameters: Parameters = ["bill_identifier" : billNumber, "mobile_number" : phoneNumber]
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.queryBill.url)
        debugPrint("=========Request Headers=========")
        debugPrint(self.getHeaders)
        
        AF.request(Endpoint.queryBill.url, method: .post,parameters: parameters,headers: self.getHeaders).responseData { (response) in
            
            let json = try? JSON(data: response.data ?? Data())
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(json ?? "NO RESPONSE BODY")
            
            switch response.result {
                
            case .success(let value):
                do {
                    let classData = try JSONDecoder().decode(IGStructInqueryBill.self, from: value)
                    completion(true, classData, nil)
                } catch let error {
                    print(error.localizedDescription)
                    guard json != nil, let message = json!["message"].string else {
                        //                        IGHelperAlert.shared.showErrorAlert()
                        completion(false, nil, "UNSSUCCESS_OTP".localizedNew)
                        return
                    }
                    //                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                    completion(false, nil, message)
                }
                
            case .failure(let error):
                print("error: ", error.localizedDescription)
                guard json != nil, let message = json!["message"].string else {
                    //                    IGHelperAlert.shared.showErrorAlert()
                    completion(false, nil, "UNSSUCCESS_OTP".localizedNew)
                    return
                }
                //                IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                completion(false, nil, message)
            }
            
        }
    }
    
    
    func branchingInfo(billNumber: String,phoneNumber: String, completion: @escaping ((_ success: Bool, _ response: IGStructBranchingInfo?, _ errorMessage: String?) -> Void) ) {
        let parameters: Parameters = ["bill_identifier" : billNumber, "mobile_number" : phoneNumber]
        
        debugPrint("=========Request Url=========")
        debugPrint(Endpoint.branchingInfo.url)
        debugPrint("=========Request Headers=========")
        debugPrint(self.getHeaders)
        
        AF.request(Endpoint.branchingInfo.url, method: .post,parameters: parameters,headers: self.getHeaders).responseData { (response) in
            
            let json = try? JSON(data: response.data ?? Data())
            
            debugPrint("=========Response Headers=========")
            debugPrint(response.response ?? "no headers")
            debugPrint("=========Response Body=========")
            debugPrint(json ?? "NO RESPONSE BODY")
            
            switch response.result {
                
            case .success(let value):
                do {
                    let classData = try JSONDecoder().decode(IGStructBranchingInfo.self, from: value)
                    completion(true, classData, nil)
                } catch let error {
                    print(error.localizedDescription)
                    guard json != nil, let message = json!["message"].string else {
                        //                        IGHelperAlert.shared.showErrorAlert()
                        completion(false, nil, "UNSSUCCESS_OTP".localizedNew)
                        return
                    }
                    //                    IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                    completion(false, nil, message)
                }
                
            case .failure(let error):
                print("error: ", error.localizedDescription)
                guard json != nil, let message = json!["message"].string else {
                    //                    IGHelperAlert.shared.showErrorAlert()
                    completion(false, nil, "UNSSUCCESS_OTP".localizedNew)
                    return
                }
                //                IGHelperAlert.shared.showAlert(title: "GLOBAL_WARNING".localizedNew, message: message)
                completion(false, nil, message)
            }
            
        }
    }
}
