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
            let mapVC = IGMap.instantiateFromAppStroryboard(appStoryboard: .Main)
            mapVC.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()?.navigationController!.pushViewController(mapVC, animated: true)
        } else {
            
            let option = UIAlertController(title: IGStringsManager.EnableNearby.rawValue.localized, message: IGStringsManager.NearByMessage.rawValue.localized, preferredStyle: IGGlobal.detectAlertStyle())
            
            let enable = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { (action) in
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
                        break
                    default:
                        break
                    }
                    
                }).send()
            })
            
            let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
            
            option.addAction(enable)
            option.addAction(cancel)
            
            UIApplication.topViewController()?.present(option, animated: true, completion: {})
        }
    }
    
    func openMapAlert() {
        let option = UIAlertController(title: IGStringsManager.GlobalAttention.rawValue.localized, message: IGStringsManager.MapDistanceMSG.rawValue.localized, preferredStyle: .alert)
        let ok = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: { (action) in
            let mapVC = IGMap.instantiateFromAppStroryboard(appStoryboard: .Main)
            mapVC.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()?.navigationController?.pushViewController(mapVC, animated: true)
        })
        option.addAction(ok)
        UIApplication.topViewController()?.present(option, animated: true, completion: {})
    }
    
}
