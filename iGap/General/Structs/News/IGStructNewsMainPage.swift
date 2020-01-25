/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation

struct IGStructNewsMainPage: Decodable {
    var type: Type
    var news: [news]?
    var buttons: [buttons]?
}
enum `Type`: String, Decodable {
    case slider = "5"
    case doubleButton = "4"
    case singleButton = "3"
    case newsTriple = "2"
    case newsDouble = "1"
    case newsSingle = "0"
}
struct news: Decodable {
    
    var category: String?
    var categoryId: QuantumValue?
    var news : [newsInner]?
    
    
}
enum QuantumValue: Decodable {

    case int(Int), string(String)

    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        throw QuantumError.missingValue
    }

    enum QuantumError:Error {
        case missingValue
    }
}
extension QuantumValue {

    var stringValue: String? {
        switch self {
        case .int(let value): return String(value)
        case .string(let value): return (value)
        }
    }
}
struct buttons: Decodable {
    
    var id: String?
    var title: String?
    var link: String?
    var color: String?
    var colorRooTitr: String?
    var colorTitr: String?

}
struct newsInner: Decodable {
    
    var source: String?
    var contents: contents?
    var color: String?
    var colorRooTitr: String?
    var colorTitr: String?

}
struct contents: Decodable {
    
    var id: String?
    var rootitr: String?
    var rootitr2: String?
    var titr: String?
    var titr2: String?
    var alias: String?
    var lead: String?
    var lead2: String?
    var introtext: String?
    var fulltext: String?
    var originalDate: String?
    var publishedDate: String?
    var image: [newsImages]?
    var internalLink: String?
    var externalLink: String?

}
struct newsImages : Decodable {
    
    var Original: String?
    var thumb128: String?
    var thumb256: String?
    var thumb512: String?

}





