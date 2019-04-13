/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import IGProtoBuff
import RealmSwift

class IGHelperNearby {
    
    static let shared = IGHelperNearby()
    
    func openMap(){
        if IGAppManager.sharedManager.mapEnable() {
            let createGroup = IGMap.instantiateFromAppStroryboard(appStoryboard: .Main)
            UIApplication.topViewController()?.navigationController!.pushViewController(createGroup, animated: true)
        } else {
            
            let option = UIAlertController(title: "Notice! Activating Map Status", message: "Will result in making your location visible to others. Please be sure about it before turning on.", preferredStyle: IGGlobal.detectAlertStyle())
            
            let enable = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                IGGeoRegister.Generator.generate(enable: true).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        if let registerResponse = protoResponse as? IGPGeoRegisterResponse {
                            IGGeoRegister.Handler.interpret(response: registerResponse)
                            IGAppManager.sharedManager.setMapEnable(enable: registerResponse.igpEnable)
                            self.openMapAlert()
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    switch errorCode {
                    case .timeout:
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okAction)
                            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                        }
                    default:
                        break
                    }
                    
                }).send()
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            option.addAction(enable)
            option.addAction(cancel)
            
            UIApplication.topViewController()?.present(option, animated: true, completion: {})
        }
    }
    
    func openMapAlert(){
        let option = UIAlertController(title: "Attention", message: "Note: People on the map will be displayed with a 500-meter error. So no worries!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let createGroup = IGMap.instantiateFromAppStroryboard(appStoryboard: .Main)
            UIApplication.topViewController()?.navigationController!.pushViewController(createGroup, animated: true)
        })
        option.addAction(ok)
        UIApplication.topViewController()?.present(option, animated: true, completion: {})
    }
    
}
