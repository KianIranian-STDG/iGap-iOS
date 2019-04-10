/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

class IGRealmDiscovery: Object {

    @objc dynamic var model: Int = 0
    @objc dynamic var scale: String?
    var discoveryFields: List<IGRealmDiscoveryField> = List<IGRealmDiscoveryField>()
    
    convenience init(discovery: IGPDiscovery) {
        self.init()
        
        self.model = discovery.igpModel.rawValue
        self.scale = discovery.igpScale
        for field in discovery.igpDiscoveryfields {
            self.discoveryFields.append(IGRealmDiscoveryField(discoveryField: field))
        }
    }
    
    internal static func getDiscoveryInfo() -> IGPClientGetDiscoveryResponse? {

        let discoveryList = try! Realm().objects(IGRealmDiscovery.self)
        if discoveryList.count == 0 {
            return nil
        }
        
        var clientGetDiscoveryResponse = IGPClientGetDiscoveryResponse()
        for discovery in discoveryList {
            var discoveries = IGPDiscovery()
            discoveries.igpModel = IGPDiscovery.IGPDiscoveryModel(rawValue: discovery.model)!
            discoveries.igpScale = discovery.scale!

            var discoveryFields: [IGPDiscoveryField] = []
            for field in discovery.discoveryFields {
                var discoveryField = IGPDiscoveryField()
                discoveryField.igpOrderid = field.orderId
                discoveryField.igpActiontype = IGPDiscoveryField.IGPButtonActionType(rawValue: field.actionType)!
                discoveryField.igpValue = field.value!
                discoveryField.igpImageurl = field.imageUrl!
                discoveryFields.append(discoveryField)
            }
            
            discoveries.igpDiscoveryfields = discoveryFields
            clientGetDiscoveryResponse.igpDiscoveries.append(discoveries)
        }
        
        return clientGetDiscoveryResponse
    }
}


class IGRealmDiscoveryField: Object {
    
    @objc dynamic var imageUrl: String?
    @objc dynamic var value: String?
    @objc dynamic var actionType: Int = 0
    @objc dynamic var orderId: Int32 = 0
    
    convenience init(discoveryField: IGPDiscoveryField) {
        self.init()
        
        self.imageUrl = discoveryField.igpImageurl
        self.value = discoveryField.igpValue
        self.actionType = discoveryField.igpActiontype.rawValue
        self.orderId = discoveryField.igpOrderid
    }
}

