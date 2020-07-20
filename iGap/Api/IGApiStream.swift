//
//  IGApiStream.swift
//  iGap
//
//  Created by ahmad mohammadi on 7/15/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias UploadInitResponse = (_ initUpload: InitUploadStream?, _ error: String?) -> Void
typealias UploadResumeResponse = (_ byteReceived: UInt64?, _ fileNotFound: Bool, _ error: String?) -> Void


fileprivate let SBaseUrl = "https://api.igap.net/file-test/v1.0"

//fileprivate let SBaseUrl = "http://192.168.10.31:3007/v1.0/"


class IGApiStream: IGApiBase {
    
    private override init() {
        super.init()
    }
    static let shared = IGApiStream()
    
    private enum SURL {
        case initUpload
        
        var url: String {
            
            switch self {
            case .initUpload:
                return (SBaseUrl + "/init")
            }
            
        }
    }
    
    // MARK: - Check Username
    func initUpload(name: String, size: UInt64, completion: @escaping UploadInitResponse) {
        
        let params: Parameters = [
            "size": size,
            "name": name,
            "extension": "",
            "room_id": "-1"
        ]
        
        AF.request(SURL.initUpload.url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).responseInitUpload {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.initUpload(name: name, size: size, completion: completion)
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
    
    func uploadResume(token: String, completion: @escaping UploadResumeResponse) {
        
        AF.request(SURL.initUpload.url + "/\(token)", method: .get, headers: self.getHeader()).responseResumeUpload {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            if sSelf.needToRetryRequest(statusCode: response.response?.statusCode, completion: {
                sSelf.uploadResume(token: token, completion: completion)
            }) {
                
            } else {
                
                guard let statusCode = response.response?.statusCode else {
                    completion(nil, false, IGStringsManager.ServerError.rawValue.localized)
                    return
                }
                
                if statusCode == 404 {
                    completion(nil, true, nil)
                    return
                }

                if statusCode != 200 {
                    do {
                        let json = try JSON(data: response.data!)
                        guard let msg = json["message"].string else {
                            completion(nil, false, IGStringsManager.ServerError.rawValue.localized)
                            return
                        }
                        completion(nil, false, msg)
                        return

                    }catch {
                        completion(nil, false, IGStringsManager.ServerError.rawValue.localized)
                        return
                    }
                }


                guard let data = response.value else {
                    completion(nil, false, IGStringsManager.ServerError.rawValue.localized)
                    return
                }
                
                completion(data.uploadedSize!, false, nil)
                return

            }
        }
        
    }
    
}


extension DataRequest {

    @discardableResult
    func responseInitUpload(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<InitUploadStream>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseResumeUpload(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<ResumeUploadStream>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
}
