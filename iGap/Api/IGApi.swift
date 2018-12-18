/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import Foundation
import SwiftyRSA

public class IGApi {
    
    static var apiBotProtocol: IGApiProtocol?
    
    public static func encryption(text : String) -> String {
        
        var encryptedMsg : String = ""
        let dataKey = Data(text.utf8)
        // ---------------------------------- Encryption Method --------------------------------------//
        let myPem = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCipYWzizhe+3fBBhPl/gzgmgSC\nNcAuMeMASomBRgWQXvU0jQMplIAXxmnxh3PQcWxCqqcJ/noYv2cB9m4PEX3EOy14\nfEaaQMsxufKaEmZcFJzQGVGBsu1ZxftzkCWvIrfm2PW6t4CKxtFgJzvtsGwOgZNb\ny9JD6KXURAy1QHGsUwIDAQAB\n-----END PUBLIC KEY-----"
        do {
            let publicKey = try PublicKey(pemEncoded: myPem)
            let clear = ClearMessage(data: dataKey)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            encryptedMsg = encrypted.base64String
        } catch  {
            print(error)
        }
        
        // -------------------------------- End Encryption Method ------------------------------------//
        
        return encryptedMsg
    }
    
    // Call WebService
    public static func callWebService() {
       
        let path = Bundle.main.path(forResource: "webServiceKey", ofType: "txt")
        let signkey : String = try! NSString(contentsOfFile: path!, encoding: String.Encoding.utf8.rawValue) as String
        
        let encMsg = encryption(text: signkey)
        
        var request = URLRequest(url: URL(string: "http://botapi.igap.net:8080/rest/igap/getData")!)
        
        let params = ["key": encMsg]
        request.setURLEncodedFormData(parameters: params)
        
        request.httpMethod = "POST"
        request.timeoutInterval = 10000
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if response != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, AnyObject>
                    if let jsonData = json["favorite"] {
                        jsonParse(jsonResponse: jsonData)
                    }
                } catch {
                    print("error")
                }
            }
        })
        
        task.resume()
    }
    
    private static func jsonParse(jsonResponse : Any){
        guard let jsonArray = jsonResponse as? [[String: AnyObject]] else {
            return
        }
        
        var apiResults : [IGApiStruct] = []
        for json in jsonArray {
            apiResults.append(IGApiStruct(json))
        }
        
        if apiBotProtocol != nil {
            apiBotProtocol?.onBotDataRecieve(results: apiResults)
        }
    }
}
