//
//  mainRequest.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/8/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import Foundation

import Alamofire
import Gloss

class Request {
    
    class func postData<T:Glossy>(_ urlString: String,vc: UIViewController ,body: [String : AnyObject] ,method: HTTPMethod? = HTTPMethod.post, completion: @escaping(T? ,AFError?) -> Void) {
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method?.rawValue
        
        let data = (try! body.convertToJson().data(using: .utf8))! as Data
        //        let data = body.convertToJson().data(using: .utf8)!
        request.httpBody = data
        
        print("////////////////////////////////")
        print("URL: \(urlString)\n")
        print("BODY: \(body.convertToJson())\n")
        print("BODY_PLAIN: \((try! body.convertToJson().data(using: .utf8))!)\n")
        print("////////////////////////////////")
        request.timeoutInterval = TimeInterval(60)
        
        request.setValue(Utils.getAccessToken(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
       
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            
                Alamofire.request(request).responseJSON { response in
                    if response.result.isFailure {
                        
                        if let error = response.result.error as? URLError{
                            
                            switch error.errorCode {
                            case -1009:
                                return
                            case -1001:
                                return
                                
                            case -1004:
                                return
                            case -1200:
                                return
                            case -1005:
                                return
                            default:
                                print(error.errorCode)
                                return
                            }
                        }
                    }
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        let encryptedResponse = try! utf8Text
                        print("Json Response:\n\(encryptedResponse)")
                        let jsonData = encryptedResponse.convertToDictionary()
                        //                  let jsonData = utf8Text.convertToDictionary()
                        if jsonData != nil {
                            
                        }
                    }
                    
                    
                }
//            })
        }
    }
    
}
extension Dictionary {
    
    func convertToJson() -> String{
        
        var Json : String!
        let dictionary = self
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: []) {
            let theJSONText = String(data: theJSONData,encoding: .utf8)
            Json = theJSONText
        }
        return Json
        
    }
    
}
