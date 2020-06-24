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
typealias PSQueryMBillResponse = (_ response: IGPSMobileBillQuery?, _ error: String?) -> Void
typealias PSGetAllBillsResponse = (_ response: [parentBillModel]?, _ error: String?) -> Void
typealias PSDeleteBillResponse = (_ response: IGKBaseResponseModelNormal?, _ error: String?) -> Void
typealias PSElecBillBranchInfo = (_ response: ElecBillBranchInfoModel?, _ error: String?) -> Void
typealias PSGasBillBranchInfo = (_ response: GasBillBranchInfoModel?, _ error: String?) -> Void

class IGApiBills: IGApiBase {
    
    enum Endpoint {
        case getInquery
        case getAllBills
        case deleteBill
        case editBill
        case addBill
        case branchInfo
        case getImageOfBill

        var url: String {
            var urlString = IGApiBills.billBaseUrl
            
            switch self {
            case .getInquery:
                urlString += "/get-inquiry"
                
            case .getAllBills:
                urlString += "/get-bills?skip=0&limit=100000"
                
            case .deleteBill:
                urlString += "/delete-bill/"
                
            case .editBill:
                urlString += "/edit-bill/"
                
            case .addBill:
                urlString += "/add-bill"
            case .branchInfo:
                urlString += "/get-details"
                case .getImageOfBill:
                    urlString += "/get-last-bill-image"

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
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseQueryElecBills {[weak self] (response) in
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
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseQueryGasBills {[weak self] (response) in
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
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseQueryPhoneBills {[weak self] (response) in
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
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseQueryMobileBills {[weak self] (response) in
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
    
    
    
    func deleteBill(billType : String, billID: String, completion: @escaping PSDeleteBillResponse) {
        let url = Endpoint.deleteBill.url + billID
        var parameters: Parameters!
        switch billType {
            
        default :
            parameters = ["bill_type" : billType]
            
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseDeleteBill {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.deleteBill(billType : billType, billID: billID, completion: completion)
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
    
    func editBill(billType : String,ID: String, billIdentifier: String? = nil ,billTitle: String ,subCode : String? = nil, telNum : String? = nil, completion: @escaping PSDeleteBillResponse) {
        let url = Endpoint.editBill.url + ID
        var parameters: Parameters!
        
        switch billType {
            
        case "ELECTRICITY" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "bill_identifier" : billIdentifier!]

        case "GAS" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "subscription_code" : subCode!]

        case "MOBILE_MCI" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "phone_number" : telNum!]
        case "PHONE" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "phone_number" : String((telNum?.dropFirst(3))!), "area_code" : String((telNum?.prefix(3))!)]

        default : break
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseDeleteBill {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.editBill(billType : billType, ID: ID, billIdentifier: billIdentifier ,billTitle: billTitle ,subCode : subCode, telNum : telNum, completion: completion)
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

    
    ////////////////////////////GET IMAGE OF BILL////////////////////////////////
    func getImageOfBill(billNumber: String,phoneNumber: String, completion: @escaping ((_ success: Bool, _ response: IGStructBillImage?, _ errorMessage: String?) -> Void) ) {
        let parameters: Parameters = ["bill_identifier" : billNumber, "mobile_number" : phoneNumber]
        AF.request(Endpoint.getImageOfBill.url, method: .post,parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseData { (response) in
            
            if self.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                self.getImageOfBill(billNumber: billNumber, phoneNumber: phoneNumber, completion: completion)
            }) {
            } else {
                
                let json = try? JSON(data: response.data ?? Data())
                switch response.response?.statusCode {
                case 200:
                    
                    switch response.result {
                    case .success(let value):
                        do {
                            let classData = try JSONDecoder().decode(IGStructBillImage.self, from: value)
                            completion(true, classData, nil)
                        } catch _ {
                            guard json != nil, let message = json!["message"].string else {
                                completion(false, nil, IGStringsManager.GlobalTryAgain.rawValue.localized)
                                return
                            }
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                            completion(false, nil, message)
                        }
                        
                    case .failure(_):
                        guard json != nil, let message = json!["message"].string else {
                            completion(false, nil, IGStringsManager.GlobalTryAgain.rawValue.localized)
                            return
                        }
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        completion(false, nil, message)
                    }
                    
                    break
                    
                default :
                    guard json != nil, let message = json!["message"].string else {
                        completion(false, nil, IGStringsManager.GlobalTryAgain.rawValue.localized)
                        return
                    }
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: message, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    completion(false, nil, message)
                }
            }
        }
    }
    func addBill(billType : String, billIdentifier: String? = nil ,billTitle: String ,subCode : String? = nil, telNum : String? = nil,userPhoneNumber: String, completion: @escaping PSDeleteBillResponse) {
        let url = Endpoint.addBill.url
        var parameters: Parameters!

        
        switch billType {
            
        case "ELECTRICITY" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle,"mobile_number" :  userPhoneNumber.inEnglishNumbersNew(), "bill_identifier" : billIdentifier!.inEnglishNumbersNew()]

        case "GAS" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "subscription_code" : subCode!.inEnglishNumbersNew(),"mobile_number" :  userPhoneNumber.inEnglishNumbersNew()]

        case "MOBILE_MCI" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "phone_number" : telNum!.inEnglishNumbersNew(),"mobile_number" :  userPhoneNumber.inEnglishNumbersNew()]
        case "PHONE" :
            parameters = ["bill_type" : billType,"bill_title" : billTitle, "phone_number" : String((telNum?.dropFirst(3))!).inEnglishNumbersNew(), "area_code" : String((telNum?.prefix(3))!).inEnglishNumbersNew(),"mobile_number" :  userPhoneNumber.inEnglishNumbersNew()]

        default : break
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseDeleteBill {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.addBill(billType : billType, billIdentifier: billIdentifier ,billTitle: billTitle ,subCode : subCode, telNum : telNum, userPhoneNumber: userPhoneNumber, completion: completion)
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
    
    func getAllBills(completion: @escaping PSGetAllBillsResponse){
        let url = Endpoint.getAllBills.url
        AF.request(url,  method: .get, headers: self.getHeader()).responseGetAllBills {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.getAllBills(completion: completion)
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
                
                let apistruct = data.docs
                
                var arr = [parentBillModel]()
                for st in apistruct! {
                    
                    var bill = parentBillModel()
                    bill.billAreaCode = st.billAreaCode
                    bill.billIdentifier = st.billID
                    bill.billPhone = st.billPhone
                    bill.billTitle = st.billTitle
                    bill.billType = st.billType
                    bill.id = st.id
                    bill.mobileNumber = st.mobileNumber
                    bill.subsCriptionCode = st.subsCriptionCode
                    arr.append(bill)
                }
                
                
                completion(arr, nil)
                return

            }
        }
        
    }
    
    func getGasBillBranchInfo(billType : String, subscriptionCode: String, completion: @escaping PSGasBillBranchInfo) {
        var url = Endpoint.branchInfo.url
        var parameters: Parameters!
        switch billType {
            
        case "GAS" :
            parameters = ["bill_type" : billType, "subscription_code" : subscriptionCode]
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.getHeader()).responseGasBranchInfo {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.getGasBillBranchInfo(billType : billType, subscriptionCode: subscriptionCode, completion: completion)
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
    func getElecBillBranchInfo(billType : String, billIdentifier: String, completion: @escaping PSElecBillBranchInfo) {
        var url = Endpoint.branchInfo.url
        var parameters: Parameters!
        switch billType {
            
        case "ELECTRICITY" :
            parameters = ["bill_type" : billType, "bill_identifier" : billIdentifier]
        default : break
            
        }
        
        AF.request(url, method: .post, parameters: parameters, headers: self.getHeader()).responseElecBranchInfo {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.getElecBillBranchInfo(billType : billType, billIdentifier: billIdentifier, completion: completion)
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
    @discardableResult
    func responseQueryElecBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSElecBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }

    @discardableResult
    func responseQueryGasBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSGasBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseQueryPhoneBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSPhoneBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseQueryMobileBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModel<IGPSMobileBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseGetAllBills(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseBillResponseArrayModel<IGPSAllBillsBillQuery>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseDeleteBill(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGKBaseResponseModelNormal>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    @discardableResult
    func responseElecBranchInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseResponseModel<ElecBillBranchInfoModel>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }

    @discardableResult
    func responseGasBranchInfo(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<IGPSBaseResponseModel<GasBillBranchInfoModel>>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }


}
