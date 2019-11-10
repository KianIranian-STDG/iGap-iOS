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

class IGApiBase {
    
    static let sharedApiBase = IGApiBase()
    
    static var httpHeaders: HTTPHeaders!
    
    struct FailableDecodable<Base : Decodable> : Decodable {
        
        let base: Base?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.base = try? container.decode(Base.self)
        }
    }
    
    public func needToRetryRequest(statusCode: Int?, completion: @escaping (() -> Void)) -> Bool {
        if statusCode == nil {
            return false
        }
        
        let refreshToken = statusCode == 401
        
        if refreshToken {
            IGUserRefreshTokenRequest.sendRequest {
                completion()
            }
        }
        
        return refreshToken
    }
    
    public func getHeader() -> HTTPHeaders {
        if IGApiBase.httpHeaders == nil {
            guard let token = IGAppManager.sharedManager.getAccessToken() else { return ["Authorization": ""] }
            let authorization = "Bearer " + token
            IGApiBase.httpHeaders = ["Authorization": authorization]
            print("TTT || *** FETCH Header ***")
        } else {
            print("TTT || *** JUST RETURN OLD Header ***")
        }
        print("TTT || ************************************************************")
        print("TTT || FETCH HEADER : \(IGApiBase.httpHeaders)")
        print("TTT || ************************************************************")
        return IGApiBase.httpHeaders
    }
    
    public func refreshHeader(){
        IGApiBase.httpHeaders = ["Authorization": "Bearer " + IGAppManager.sharedManager.getAccessToken()!]
        print("WWW || ************************************************************")
        print("WWW || UPDATE HEADER : \(IGApiBase.httpHeaders)")
        print("WWW || ************************************************************")
        
        print("TTT || ************************************************************")
        print("TTT || UPDATE HEADER : \(IGApiBase.httpHeaders)")
        print("TTT || ************************************************************")
    }
}

extension DataRequest {
//    func decodableResponseSerializer<T: responseDecodable>() -> Alamofire.ResponseSerializer {
//        return DataResponseSerializer { _, response, data, error in
//            guard error == nil else { return .failure(error!) }
//
//            guard let data = data else {
//                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
//            }
//
//            return Result { try JSONDecoder().decode(T.self, from: data) }
//        }
//    }
    
//    @discardableResult
//    func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<T>) -> Void) -> Self {
//        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
//    }
}
