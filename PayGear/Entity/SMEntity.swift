//
//  SMEntity.swift
//  PayGear
//
//  Created by a on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import CoreData

class SMEntity: NSObject {
    
    static var context:NSManagedObjectContext{
        get{
            return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        }
    }
    
    
    static func commit(){
        do{
            try SMEntity.context.save()
        }catch{
            SMLog.SMPrint(error)
        }
    }
    
    
    override var description: String{
        get{
            var desc = super.description
            
            for ch in Mirror(reflecting: self).children{
                desc = desc + "\n\t\(ch.label ?? "noLabel") => \(ch.value)"
            }
            
            return desc
        }
    }
    
}
