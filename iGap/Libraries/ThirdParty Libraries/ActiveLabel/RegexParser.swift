//
//  RegexParser.swift
//  ActiveLabel
//
//  Created by Pol Quintana on 06/01/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

struct RegexParser {

    static let hashtagPattern = "\\B(\\#[a-zA-Z0-9]+\\b)(?!;)"
    static let mentionPattern = "(?:^|\\s|$|[.])@[\\p{L}0-9_]*"
    //static let botPattern = "\\B(\\/[a-zA-Z0-9]+\\b)(?!;)"
    static let botPattern = "(?:^|\\s|$|[.])/[\\p{L}0-9_]*"
    /*static let urlPattern = "(http:\\/\\/www\\.|https:\\/\\/www\\.|http:\\/\\/|https:\\/\\/)?[a-zA-Z0-9]+([\\-\\.]{1}[a-zA-Z0-9]+)*\\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\\/.*)?|((http:\\/\\/www\\.|https:\\/\\/www\\.|http:\\/\\/|https:\\/\\/)?([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"*/
    
    static let alphaCharsRegExp = "a-z" +
        "\\u00c0-\\u00d6\\u00d8-\\u00f6\\u00f8-\\u00ff" + // Latin-1
        "\\u0100-\\u024f" + // Latin Extended A and B
        "\\u0253\\u0254\\u0256\\u0257\\u0259\\u025b\\u0263\\u0268\\u026f\\u0272\\u0289\\u028b" + // IPA Extensions
        "\\u02bb" + // Hawaiian
        "\\u0300-\\u036f" + // Combining diacritics
        "\\u1e00-\\u1eff" + // Latin Extended Additional (mostly for Vietnamese)
        "\\u0400-\\u04ff\\u0500-\\u0527" + // Cyrillic
        "\\u2de0-\\u2dff\\ua640-\\ua69f" + // Cyrillic Extended A/B
        "\\u0591-\\u05bf\\u05c1-\\u05c2\\u05c4-\\u05c5\\u05c7" +
        "\\u05d0-\\u05ea\\u05f0-\\u05f4" + // Hebrew
        "\\ufb1d-\\ufb28\\ufb2a-\\ufb36\\ufb38-\\ufb3c\\ufb3e\\ufb40-\\ufb41" +
        "\\ufb43-\\ufb44\\ufb46-\\ufb4f" + // Hebrew Pres. Forms
        "\\u0610-\\u061a\\u0620-\\u065f\\u066e-\\u06d3\\u06d5-\\u06dc" +
        "\\u06de-\\u06e8\\u06ea-\\u06ef\\u06fa-\\u06fc\\u06ff" + // Arabic
        "\\u0750-\\u077f\\u08a0\\u08a2-\\u08ac\\u08e4-\\u08fe" + // Arabic Supplement and Extended A
        "\\ufb50-\\ufbb1\\ufbd3-\\ufd3d\\ufd50-\\ufd8f\\ufd92-\\ufdc7\\ufdf0-\\ufdfb" + // Pres. Forms A
        "\\ufe70-\\ufe74\\ufe76-\\ufefc" + // Pres. Forms B
        "\\u200c" + // Zero-Width Non-Joiner
        "\\u0e01-\\u0e3a\\u0e40-\\u0e4e" + // Thai
        "\\u1100-\\u11ff\\u3130-\\u3185\\uA960-\\uA97F\\uAC00-\\uD7AF\\uD7B0-\\uD7FF" + // Hangul (Korean)
        "\\u3003\\u3005\\u303b" + // Kanji/Han iteration marks
        "\\uff21-\\uff3a\\uff41-\\uff5a" + // full width Alphabet
        "\\uff66-\\uff9f" + // half width Katakana
    "\\uffa1-\\uffdc" // half width Hangul (Korean)
    
    static let domainAddChars = "\\u00b7"
    static let urlPattern = "((?:https?|ftp)://|mailto:)?" +
        // user:pass authentication
        "(?:\\S{1,64}(?::\\S{0,64})?@)?" +
        "(?:" +
        // sindresorhus/ip-regexp
        "(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])(?:\\.(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])){3}" +
        "|" +
        // host name
        "[" + alphaCharsRegExp + "0-9][" + alphaCharsRegExp + domainAddChars + "0-9\\-]{0,64}" +
        // domain name
        "(?:\\.[" + alphaCharsRegExp + "0-9][" + alphaCharsRegExp + domainAddChars + "0-9\\-]{0,64}){0,10}" +
        
        // TLD identifier
        "(?:\\.(xn--[0-9a-z]{2,16}|[" + alphaCharsRegExp + "]{2,24}))" +
        ")" +
        // port number
        "(?::\\d{2,5})?" +
        // resource path
    "(?:/(?:\\S{0,255}[^\\s.;,(\\[\\]{}<>\"\'])?)?"
    
    static let deepLinkPattern = "(igap?://)([^:^/]*)(:\\d*)?(.*)?"
    
    static let emailPattern = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
    
    //static let boldPattern = "[*][*][\\w\\W]*[*][*]"
    //static let boldPattern = "[⁣⁣⁣⁣][\\w\\W]*[⁣⁣⁣]" // regex that check word between invisible character
    //static let boldPattern = "\\*\\*(\\S(.*?\\S)?)\\*\\*" // regex that check word between invisible character
    static let boldPattern = "[⁣](\\S(.*?\\S)?)[⁣]" // regex that check word between invisible character
    
    /*static let emailPattern = "^((([a-z]|\\d|[!#\\$%&'\\*\\+\\-\\/=\\?\\^_`{\\|}~]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])+(\\.([a-z]|\\d|[!#\\$%&'\\*\\+\\-\\/=\\?\\^_`{\\|}~]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])+)*)|((\\x22)((((\\x20|\\x09)*(\\x0d\\x0a))?(\\x20|\\x09)+)?(([\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x7f]|\\x21|[\\x23-\\x5b]|[\\x5d-\\x7e]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])|(\\\\([\\x01-\\x09\\x0b\\x0c\\x0d-\\x7f]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF]))))*(((\\x20|\\x09)*(\\x0d\\x0a))?(\\x20|\\x09)+)?(\\x22)))@((([a-z]|\\d|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])|(([a-z]|\\d|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])([a-z]|\\d|-||_|~|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])*([a-z]|\\d|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])))\\.)+(([a-z]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])+|(([a-z]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])+([a-z]+|\\d|-|\\.{0,1}|_|~|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])?([a-z]|[\\u00A0-\\uD7FF\\uF900-\\uFDCF\\uFDF0-\\uFFEF])))$"*/
    /*static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
     "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
     "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"*/

    private static var cachedRegularExpressions: [String : NSRegularExpression] = [:]

    static func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]{
        guard let elementRegex = regularExpression(for: pattern) else { return [] }
        return elementRegex.matches(in: text, options: [], range: range)
    }

    private static func regularExpression(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegularExpressions[pattern] {
            return regex
        } else if let createdRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
            cachedRegularExpressions[pattern] = createdRegex
            return createdRegex
        } else {
            return nil
        }
    }
}
