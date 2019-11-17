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
            return IGStringsManager.Charge.rawValue.localized
        case 1:
            return IGStringsManager.Prepaid.rawValue.localized
        case 2:
            return IGStringsManager.InCash.rawValue.localized
        case 3:
            return IGStringsManager.PayGateway.rawValue.localized
            
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
