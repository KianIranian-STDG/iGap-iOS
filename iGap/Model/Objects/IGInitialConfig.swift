//
//  IGInitialConfig.swift
//  iGap
//
//  Created by ahmad mohammadi on 7/21/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

fileprivate typealias InitialConfigResponse = (_ message: InitialConfig?) -> Void

class IGInitialConfig {
    
    public static let sharedConfig = IGInitialConfig()
    
    private init() {
    }
    
    func getInitialConfig(completion: @escaping (()->())) {
        
        ConfigApiHandler.getConfig { (config) in
            
            guard let conf = config else {
                completion()
                return
            }
            
            if let socketUrl = conf.webSocketUrl {
                if socketUrl != IGAppManager.sharedManager.webSocketUrl {
                    IGAppManager.sharedManager.webSocketUrl = socketUrl
                    IGWebSocketManager.sharedManager.forceConnect(forceReconnect: true)
                }else {
                    IGAppManager.sharedManager.webSocketUrl = socketUrl
                }
            }
            
            if let debugM = conf.debugMode {
                IGAppManager.sharedManager.debugMode = debugM
            }
            
            if let debugr = IGDebugger(rawValue: conf.debugger ?? "") {
                IGAppManager.sharedManager.debugger = debugr
            }
            
            if let timeO = conf.timeOut {
                IGAppManager.sharedManager.timeOut = timeO
            }
            
            if let mFileSize = conf.maxFileSize {
                IGAppManager.sharedManager.maxFileSize = mFileSize
            }
            
            if let cMaxLenght = conf.captionMaxLength {
                IGAppManager.sharedManager.captionMaxLength = cMaxLenght
            }
            
            if let mMaxLenght = conf.messageMaxLength {
                IGAppManager.sharedManager.messageMaxLength = mMaxLenght
            }
            
            if let gpLimit = conf.groupMemberLimit {
                IGAppManager.sharedManager.groupMemberLimit = gpLimit
            }
            
            if let chnlLimit = conf.channelMemberLimit {
                IGAppManager.sharedManager.channelMemberLimit = chnlLimit
            }
            
            if let upDlMethod = RequestMethod(rawValue: conf.microServices?.file ?? "") {
                IGAppManager.sharedManager.UploadDownloadMethod = upDlMethod
            }
            
            if let blkMode = RequestMethod(rawValue: conf.microServices?.file ?? "") {
                IGAppManager.sharedManager.blockMethod = blkMode
            }
            
            completion()
            
        }
        
    }
    
}

    // MARK:- Api Handler
class ConfigApiHandler {
    fileprivate static func getConfig(completion: @escaping InitialConfigResponse) {
        let configEndpoint = "https://api.igap.net/config/"
        AF.request(configEndpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseInitialConfig {(response) in
            guard let statusCode = response.response?.statusCode else {
                completion(nil)
                return
            }

            if statusCode != 200 {
                completion(nil)
            }

            guard let data = response.value else {
                completion(nil)
                return
            }

            completion(data)
            return
            
        }
    }
}



    // MARK:- Api OBJECT
fileprivate struct InitialConfig: Decodable {
    
    var webSocketUrl: String?
    var debugMode: Bool?
    var debugger: String?
    var timeOut: Int?
    var maxFileSize: Int64?
    var captionMaxLength: Int?
    var messageMaxLength: Int?
    var groupMemberLimit: Int?
    var channelMemberLimit: Int?
    var microServices: MicroService?
    
//    var IGDebugger
//    var UploadDownloadMethod: RequestMethod?
//    var blockMethod: RequestMethod?
    
    enum CodingKeys: String, CodingKey {
        case webSocketUrl = "websocket"
        case debugMode = "debug_mode"
        case debugger
        case timeOut = "default_timeout"
        case maxFileSize = "max_file_size"
        case captionMaxLength = "caption_length_max"
        case messageMaxLength = "message_length_max"
        case groupMemberLimit = "group_add_member_limit"
        case channelMemberLimit = "channel_add_member_limit"
        case microServices = "micro_services"
    }
    
    struct MicroService: Decodable {
        var file: String?
        var block: String?
        
        enum CodingKeys: String, CodingKey {
            case file, block
        }
    }
    
}

    //MARK:- Alamofire Extension
extension DataRequest {

    @discardableResult
    fileprivate func responseInitialConfig(queue: DispatchQueue? = nil, completionHandler: @escaping (Alamofire.AFDataResponse<InitialConfig>) -> Void) -> Self {
        return responseDecodable(completionHandler: completionHandler)
    }
    
}
