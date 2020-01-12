//
//  Test.swift
//  iGap
//
//  Created by ahmad mohammadi on 1/11/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit


class ActiveLabelJsonify {
  
    static func toJson(_ text: String) -> Data? {
        
        let lbl = ActiveLabel(frame: .zero)
        lbl.text = text
        var itemHolder = ItemsHolder(items: [Item]())
        for (key, value) in lbl.activeElements {
            if (value.count != 0){
                for val in value {
                    let item = Item(type: typeToString(type: key), offset: val.range.location, limit: val.range.length)
                    itemHolder.items.append(item)
                }
            }
        }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(itemHolder)
            return data
        } catch {
            return nil
        }
        
    }
    
    private static func typeToString(type: ActiveType) -> String {
        switch type {
        case .email:
            return "email"
        case .mention:
            return "mention"
        case .hashtag:
            return "hashtag"
        case .url:
            return "url"
        case .deepLink:
            return "deepLink"
        case .bot:
            return "bot"
        case .bold:
            return "bold"
        case .custom:
            return ""
        }
    }
    
}

fileprivate struct ItemsHolder: Codable {
    
    var items : [Item]
    
}

fileprivate struct Item: Codable {
    var type: String
    var offset: Int
    var limit: Int
}
