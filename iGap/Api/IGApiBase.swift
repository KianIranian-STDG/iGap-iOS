//
//  IGApiBase.swift
//  iGap
//
//  Created by MacBook Pro on 6/21/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire

class IGApiBase {
    lazy var getHeaders: HTTPHeaders = {
        guard let token = IGAppManager.sharedManager.getAccessToken() else { return ["Authorization": ""] }
        let authorization = "Bearer " + token
        let headers: HTTPHeaders = ["Authorization": authorization]
        return headers
    }()
    
    struct FailableDecodable<Base : Decodable> : Decodable {
        
        let base: Base?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.base = try? container.decode(Base.self)
        }
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
