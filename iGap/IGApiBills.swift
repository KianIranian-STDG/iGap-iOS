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

//typealias PSBaseResponse = (_ message: String?, _ error: String?) -> Void
typealias PSQueryEBillResponse = (_ response: IGPSElecBillQuery?, _ error: String?) -> Void
typealias PSQueryGBillResponse = (_ response: IGPSGasBillQuery?, _ error: String?) -> Void
typealias PSQueryPBillResponse = (_ response: IGPSPhoneBillQuery?, _ error: String?) -> Void
typealias PSQueryMBillResponse = (_ response: IGPSPhoneBillQuery?, _ error: String?) -> Void

class IGApiBills: IGApiBase {
    
    enum Endpoint {
        case getInquery
        
        var url: String {
            var urlString = IGApiBills.billBaseUrl
            
            switch self {
            case .getInquery:
                urlString += "/get-inquiry"
            }
            
            return urlString
        }
    }
    
    
    
    
    
    

    
    
    
    
    static let shared = IGApiBills()
//    private static let topupBaseUrl = "https://api.igap.net/services/v1.0"
    private static let billBaseUrl = "https://api.igap.net/bill-manager/v1.0"

    func queryElecBill(billType : String, telNum: String? = nil, billID: String? = nil, completion: @escaping PSQueryEBillResponse) {
        var url = Endpoint.getInquery.url
        var parameters: Parameters!
        switch billType {
            
        case "ELECTRICITY" :
            parameters = ["bill_type" : billType, "bill_identifier" : billID!, "mobile_number" : telNum!]
        case "GAS" :
            parameters = ["bill_type" : billType, "subscription_code" : billID!]
        case "PHONE" :
            parameters = ["bill_type" : billType, "phone_number" : String((telNum?.dropFirst(3))!), "area_code" : String((telNum?.prefix(3))!)]
        case "MOBILE_MCI" :
            parameters = ["bill_type" : billType, "phone_number" : telNum!]
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseQueryElecBills {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.queryElecBill(billType : billType, telNum: telNum, billID: billID, completion: completion)
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
    
    
    func queryGasBill(billType : String, billID: String? = nil, completion: @escaping PSQueryGBillResponse) {
        var url = Endpoint.getInquery.url
        var parameters: Parameters!
        switch billType {
        case "GAS" :
            parameters = ["bill_type" : billType, "subscription_code" : billID!]
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseQueryGasBills {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.queryGasBill(billType : billType, billID: billID, completion: completion)
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
    
    

    func queryPhoneBill(billType : String, telNum: String? = nil, completion: @escaping PSQueryPBillResponse) {
        var url = Endpoint.getInquery.url
        var parameters: Parameters!
        switch billType {
            
        case "PHONE" :
            parameters = ["bill_type" : billType, "phone_number" : String((telNum?.dropFirst(3))!), "area_code" : String((telNum?.prefix(3))!)]
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseQueryPhoneBills {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.queryPhoneBill(billType : billType, telNum: telNum, completion: completion)
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
    
    func queryMobileBill(billType : String, telNum: String, completion: @escaping PSQueryMBillResponse) {
        var url = Endpoint.getInquery.url
        var parameters: Parameters!
        switch billType {
            
        case "MOBILE_MCI" :
            parameters = ["bill_type" : billType, "phone_number" : telNum]
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseQueryMobileBills {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.queryMobileBill(billType : billType, telNum: telNum, completion: completion)
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
}



extension DataRequest {
    
//    @discardableResult
//    func responseGetLastTopUps(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseResponseArrayModel<IGPSLastTopUpPurchases>>) -> Void) -> Self {
//        return responseDecodable(completionHandler: completionHandler)
//    }
    
    func responseQueryElecBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSElecBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }


    func responseQueryGasBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSGasBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }

    func responseQueryPhoneBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSPhoneBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    func responseQueryMobileBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSPhoneBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }

}
