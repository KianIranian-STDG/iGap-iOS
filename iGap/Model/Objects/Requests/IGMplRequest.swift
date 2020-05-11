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
import UIKit
import IGProtoBuff
import SwiftProtobuf
import RealmSwift
import WebRTC

class IGMplGetBillToken : IGRequest {    
    class Generator : IGRequest.Generator{
        class func generate(billId: Int64, payId: Int64) -> IGRequestWrapper {
            var mplGetBillToken = IGPMplGetBillToken()
            mplGetBillToken.igpBillID = billId
            mplGetBillToken.igpPayID = payId
            return IGRequestWrapper(message: mplGetBillToken, actionID: 9100)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetBillTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplGetTopupToken : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(number: Int64, amount: Int64, type: IGPMplGetTopupToken.IGPType) -> IGRequestWrapper {
            var mplGetTopupToken = IGPMplGetTopupToken()
            mplGetTopupToken.igpChargeMobileNumber = number
            mplGetTopupToken.igpAmount = amount
            mplGetTopupToken.igpType = type
            return IGRequestWrapper(message: mplGetTopupToken, actionID: 9101)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetTopupTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplGetSalesToken : IGRequest {
    
    
    
    
    class Generator : IGRequest.Generator{
        class func generate(inquery: Bool, amount: Int64 , toUserId: Int64 , invoiceNUmber: Int64 , description: String ) -> IGRequestWrapper {
            var mplGetSales = IGPMplGetSalesToken()
            mplGetSales.igpAmount = amount
            mplGetSales.igpInquiry = inquery
            mplGetSales.igpToUserID = toUserId
            mplGetSales.igpDescription = description
            mplGetSales.igpInvoiceNumber = invoiceNUmber
            return IGRequestWrapper(message: mplGetSales, actionID: 9102)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetTopupTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplSetSalesResult : IGRequest {
    
    class func sendRequest(data : String){
        IGMplSetSalesResult.Generator.generate(data : data).success({ (protoResponse) in
            if let response = protoResponse as? IGPMplSetSalesResultResponse {
                print("RESPONSE SALES SET :",response)
            }
        }).error ({ (errorCode, waitTime) in
            print(errorCode)
            switch errorCode {
            case .timeout:
                sendRequest(data : data)
                
            default:
                break
            }
        }).send()
    }
    class Generator : IGRequest.Generator{
        class func generate(data : String) -> IGRequestWrapper {
            var mplSetSalesResult = IGPMplSetSalesResult()
            mplSetSalesResult.igpData = data
            print(data)
            print(mplSetSalesResult.igpData)
            return IGRequestWrapper(message: mplSetSalesResult, actionID: 9103)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplSetSalesResultResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}
class IGMplSetCardToCardResult : IGRequest {
    
    class func sendRequest(data : String, toUserId: Int64? = nil){
        IGMplSetCardToCardResult.Generator.generate(data : data, toUserId: toUserId).success({ (protoResponse) in
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                sendRequest(data : data)
            default:
                break
            }
        }).send()
    }
    
    class Generator : IGRequest.Generator{
        class func generate(data : String, toUserId: Int64? = nil) -> IGRequestWrapper {
            var mplSetCardToCardResult = IGPMplSetCardToCardResult()
            mplSetCardToCardResult.igpData = data
            if toUserId != nil {
                mplSetCardToCardResult.igpToUserID = toUserId!
            }
            return IGRequestWrapper(message: mplSetCardToCardResult, actionID: 9108)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplSetCardToCardResultResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

/* Hint: not need "toUserId" for following request, but after do this action for send "IGMplSetCardToCardResult" request, "toUserId" is needed. */
class IGMplGetCardToCardToken : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(toUserId: Int64 = 0) -> IGRequestWrapper {
            var requestObject =  IGPMplGetCardToCardToken()
            requestObject.igpToUserID = toUserId
            return IGRequestWrapper(message: requestObject, actionID: 9106, identity: "\(toUserId)")
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetCardToCardTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplTransactionList: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(type: IGPMplTransaction.IGPType, offset: Int32, limit: Int32, requestIdentity: String) -> IGRequestWrapper {
            var transactionListRequestMessage = IGPMplTransactionList()
            
            transactionListRequestMessage.igpType = type
            
            // pagination
            var pagination = IGPPagination()
            pagination.igpLimit = limit
            pagination.igpOffset = offset
            
            transactionListRequestMessage.igpPagination = pagination
            return IGRequestWrapper(message: transactionListRequestMessage, actionID: 9109, identity: requestIdentity)
        }
    }
    
    class Handler: IGRequest.Handler {
        class func interpret(response reponseProtoMessage: IGPMplTransactionListResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplTransactionInfo: IGRequest {
    class Generator : IGRequest.Generator {
        class func generate(transactionToken: String) -> IGRequestWrapper {
            var transactionInfoRequestMessage = IGPMplTransactionInfo()
            
            transactionInfoRequestMessage.igpToken = transactionToken
            
            return IGRequestWrapper(message: transactionInfoRequestMessage, actionID: 9110)
        }
    }
    
    class Handler: IGRequest.Handler {
        class func interpret(response reponseProtoMessage: IGPMplTransactionInfoResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGMplGetCardToCardTokenWithAmount : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(toUserId: Int64 = 0,amount:Int?,destinationCard: String?) -> IGRequestWrapper {
            var requestObject =  IGPMplGetCardToCardToken()
            requestObject.igpToUserID = toUserId

            return IGRequestWrapper(message: requestObject, actionID: 9106, identity: "\(toUserId)")
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPMplGetCardToCardTokenResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGBillInquiryMci : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(mobileNumber: Int64) -> IGRequestWrapper {
            var billInquiryMci = IGPBillInquiryMci()
            billInquiryMci.igpMobileNumber = mobileNumber
            return IGRequestWrapper(message: billInquiryMci, actionID: 9200)
        }
    }
    
    class Handler : IGRequest.Handler {
        class func interpret(response reponseProtoMessage:IGPBillInquiryMciResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}

class IGBillInquiryTelecom : IGRequest {
    class Generator : IGRequest.Generator{
        class func generate(provinceCode: Int32, telephoneNumber: Int64) -> IGRequestWrapper {
            var billInquiryTelecom = IGPBillInquiryTelecom()
            billInquiryTelecom.igpProvinceCode = provinceCode
            billInquiryTelecom.igpTelephoneNumber = telephoneNumber
            return IGRequestWrapper(message: billInquiryTelecom, actionID: 9201)
        }
    }
    
    class Handler : IGRequest.Handler{
        class func interpret(response reponseProtoMessage:IGPBillInquiryMciResponse) {}
        override class func handlePush(responseProtoMessage: Message) {}
    }
}



