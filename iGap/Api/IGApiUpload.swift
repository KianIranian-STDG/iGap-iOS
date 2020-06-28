//
//  IGApiUpload.swift
//  iGap
//
//  Created by ahmad mohammadi on 6/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias UploadInitResponse = (_ result: InitUpload?, _ error: String?) -> Void


fileprivate let UploadBaseUrl = "http://192.168.8.15:4001/v1.0"
private enum UploadURL {
    case initUpload
    
    var url: String {
        switch self {
        case .initUpload:
            return (UploadBaseUrl + "/init")
        }
    }
}

class IGApiUpload: IGApiBase {
    
    private override init() {
        super.init()
    }
    
    static let shared = IGApiUpload()
    
    
    func initUpload(name: String, size: Int64, fileExtension: String, roomId: String, completion: @escaping UploadInitResponse) {
        
        let params: Parameters = [
            "name" : name,
            "size":  size,
            "extension": fileExtension,
            "room_id": roomId
        ]
        
        AF.request(UploadURL.initUpload.url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).responseUploadInit {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.initUpload(name: name, size: size, fileExtension: fileExtension, roomId: roomId, completion: completion)
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
    
}


extension DataRequest {

    @discardableResult
    func responseUploadInit(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<InitUpload>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }

}
