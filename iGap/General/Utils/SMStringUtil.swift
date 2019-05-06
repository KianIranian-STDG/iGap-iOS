//
//  SMStringUtil.swift
//  PayGear
//
//  Created by amir soltani on 4/21/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation


class SMStringUtil {
    
    static func getTransType(type : Int)->String{
        
        switch type {
        case 0:
            return "TTL_CHARGE".localizedNew
        case 1:
            return "TTL_PREPAID".localizedNew
        case 2:
            return "TTL_INCASH".localizedNew
        case 3:
            return "TTL_PAYMENT_GATEWAY".localizedNew
            
        default:
            return ""
        }
    }
    
    static func separateFormat(_ plain: String, separators: [Int], delimiter: String) -> String {
        var strings = Array<String?>(repeating: nil, count: separators.count)
        for i in 0..<separators.count {
            var prev = 0;
            for j in 0..<i {
                prev += separators[j];
            }
            let end = separators[i] + prev;
            if (plain.length >= end) {
                strings[i] = plain.substring(prev, end);
            } else if (plain.length >= prev) {
                strings[i] = plain.substring(prev);
            }
        }
        var sb = ""
        for i in 0..<separators.count {
            if (strings[i] != nil) {
                if (!strings[i]!.isEmpty) {
                    sb.append(strings[i]!);
                }
                if (strings[i]!.length == separators[i] && i < separators.count - 1) {
                    sb.append(delimiter);
                }
            }
        }
        if sb.length > 0 && sb.substring(sb.length - 1) == delimiter {
            sb = sb.substring(0, sb.length - 1)
        }
        
        return sb
    }
    
    
    
    
    
}
