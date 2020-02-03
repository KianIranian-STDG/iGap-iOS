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
        var itemHolder = ActiveItemsHolder(items: [ActiveLabelItem]())
        if lbl.activeElements.count == 0 {
            return nil
        }
        
        for (keyy, value) in lbl.activeElements {
            var key = keyy
            if (value.count != 0){
                for val in value {
                    
                    if key == .url {
                        
                        let str = getStringAtRange(string: text, range: NSRange(location: val.range.location, length: val.range.length))
                        
                        if isEmail(candidate: str) {
                            
                            key = .email
                            
                        } else if URL(string: str) == nil{
                            
                            continue
                            
                        }
                        
                        
                    }
                    
                    let item = ActiveLabelItem(type: typeToString(type: key), offset: val.range.location, limit: val.range.length)
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
    
    static func toObejct(_ json: Data) -> [ActiveLabelItem]?{
        do {
            let fff = try JSONDecoder().decode(ActiveItemsHolder.self, from: json)
            return fff.items
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

fileprivate struct ActiveItemsHolder: Codable {
    
    var items : [ActiveLabelItem]
    
}

struct ActiveLabelItem: Codable {
    var type: String
    var offset: Int
    var limit: Int
}


fileprivate func isEmail(candidate: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
}

private func getStringAtRange(string: String, range: NSRange) -> String {
    return (string as NSString).substring(with: range)
}
