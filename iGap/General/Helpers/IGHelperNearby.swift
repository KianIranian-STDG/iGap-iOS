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
            
            let option = UIAlertController(title: "TTL_MAP_STATUS".localizedNew, message: "SETTING_NEARBY_MAP_STATUS".localizedNew, preferredStyle: IGGlobal.detectAlertStyle())
            
            let enable = UIAlertAction(title: "OK".localizedNew, style: .default, handler: { (action) in
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
                            let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "MSG_PLEASE_TRY_AGAIN".localizedNew, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                            alert.addAction(okAction)
                            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                        }
                    default:
                        break
                    }
                    
                }).send()
            })
            
            let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
            
            option.addAction(enable)
            option.addAction(cancel)
            
            UIApplication.topViewController()?.present(option, animated: true, completion: {})
        }
    }
    
    func openMapAlert(){
        let option = UIAlertController(title: "TTL_ATTENTION".localizedNew, message: "MSG_MAP_DISTANCE".localizedNew, preferredStyle: .alert)
        let ok = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: { (action) in
            let createGroup = IGMap.instantiateFromAppStroryboard(appStoryboard: .Main)
            UIApplication.topViewController()?.navigationController!.pushViewController(createGroup, animated: true)
        })
        option.addAction(ok)
        UIApplication.topViewController()?.present(option, animated: true, completion: {})
    }
    
}
