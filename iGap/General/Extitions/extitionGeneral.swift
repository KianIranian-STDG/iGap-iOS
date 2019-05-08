//
//  extitionGeneral.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit

typealias CallBack = (Any?) -> ()
typealias SimpleCallBack = () -> ()
typealias FailedCallBack = (Any) -> ()
typealias MoreActionCallBack = (Any?, Bool? ) -> ()



extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:UInt) {
        let red = (netHex >> 16) & 0xff
        let green = (netHex >> 8) & 0xff
        let blue = netHex & 0xff
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHexWithAlpha netHex:Int) {
        let alpha = (netHex >> 24) & 0xff
        let red = (netHex >> 16) & 0xff
        let green = (netHex >> 8) & 0xff
        let blue = netHex & 0xff
        
        assert(alpha >= 0 && alpha <= 255, "Invalid alpha component")
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    convenience init(netHexString:String) {
        
        var hex = netHexString.replace("#", withString: "")
        
        if hex.length == 6 {
            self.init(netHex: UInt(hex, radix: 16)!)
        } else if hex.length == 3{
            let a = String(hex[0])
            let b = String(hex[1])
            let c = String(hex[2])
            
            hex = a + a + b + b + c + c
            self.init(netHex: UInt(hex, radix: 16)!)
        } else {
            self.init(netHex: UInt("F7B731", radix: 16)!)
        }
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UITableViewController {
    func hideKeyboardWhenTappedAroundTableVIew() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UITableViewController.dismissKeyboardTableVIew))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)

        
    }
    
    @objc func dismissKeyboardTableVIew() {
        tableView.endEditing(true)
    }
}
extension String {
    
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    static var RightToLeftMark:String{
        return "\u{200F}"
    }
    static var LeftToRightMark:String{
        return "\u{200E}"
    }
    
    func replace(_ target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    var length: Int {
        get {
            return self.count
        }
    }

    func localizedWithArgs(_ args: [CVarArg]) -> String {
        return String(format: self.localized, arguments: args)
    }
    
    func truncateWord(_ maxLimit:Int) -> String{
        if self.length < maxLimit{
            return self
        }else{
            //            let indx = self.index(self.startIndex, offsetBy: maxLimit)
            //            var newText = String(self[...indx])
            var newText = self.substring(self.startIndex.encodedOffset, maxLimit)
            let lastSpaceIndex = newText.range(of: " ", options: String.CompareOptions.backwards)?.lowerBound ?? self.endIndex
            newText = String(self[...lastSpaceIndex])
            return newText + " ..."
        }
    }
    
   
    
    
    func inPersianNumbers()->String{
        
        var outStr = self
        
        //convert English numbers to Persian
        outStr = outStr.replacingOccurrences(of: "0", with: "۰")
        outStr = outStr.replacingOccurrences(of: "1", with: "۱")
        outStr = outStr.replacingOccurrences(of: "2", with: "۲")
        outStr = outStr.replacingOccurrences(of: "3", with: "۳")
        outStr = outStr.replacingOccurrences(of: "4", with: "۴")
        outStr = outStr.replacingOccurrences(of: "5", with: "۵")
        outStr = outStr.replacingOccurrences(of: "6", with: "۶")
        outStr = outStr.replacingOccurrences(of: "7", with: "۷")
        outStr = outStr.replacingOccurrences(of: "8", with: "۸")
        outStr = outStr.replacingOccurrences(of: "9", with: "۹")
        //        outStr = outStr.replacingOccurrences(of: "*", with: "•")
        
        
        //convert Arabic numbers to Persian
        outStr = outStr.replacingOccurrences(of: "٠", with: "۰")
        outStr = outStr.replacingOccurrences(of: "١", with: "۱")
        outStr = outStr.replacingOccurrences(of: "٢", with: "۲")
        outStr = outStr.replacingOccurrences(of: "٣", with: "۳")
        outStr = outStr.replacingOccurrences(of: "٤", with: "۴")
        outStr = outStr.replacingOccurrences(of: "٥", with: "۵")
        outStr = outStr.replacingOccurrences(of: "٦", with: "۶")
        outStr = outStr.replacingOccurrences(of: "٧", with: "۷")
        outStr = outStr.replacingOccurrences(of: "٨", with: "۸")
        outStr = outStr.replacingOccurrences(of: "٩", with: "۹")
        
        return outStr
    }
    
    
    func inEnglishNumbers()->String{
        
        var outStr = self
        
        //convert English numbers to Persian
        outStr = outStr.replacingOccurrences(of: "۰", with: "0")
        outStr = outStr.replacingOccurrences(of: "۱", with: "1")
        outStr = outStr.replacingOccurrences(of: "۲", with: "2")
        outStr = outStr.replacingOccurrences(of: "۳", with: "3")
        outStr = outStr.replacingOccurrences(of: "۴", with: "4")
        outStr = outStr.replacingOccurrences(of: "۵", with: "5")
        outStr = outStr.replacingOccurrences(of: "۶", with: "6")
        outStr = outStr.replacingOccurrences(of: "۷", with: "7")
        outStr = outStr.replacingOccurrences(of: "۸", with: "8")
        outStr = outStr.replacingOccurrences(of: "۹", with: "9")
        
        
        //convert Arabic numbers to Persian
        outStr = outStr.replacingOccurrences(of: "٠", with: "0")
        outStr = outStr.replacingOccurrences(of: "١", with: "1")
        outStr = outStr.replacingOccurrences(of: "٢", with: "2")
        outStr = outStr.replacingOccurrences(of: "٣", with: "3")
        outStr = outStr.replacingOccurrences(of: "٤", with: "4")
        outStr = outStr.replacingOccurrences(of: "٥", with: "5")
        outStr = outStr.replacingOccurrences(of: "٦", with: "6")
        outStr = outStr.replacingOccurrences(of: "٧", with: "7")
        outStr = outStr.replacingOccurrences(of: "٨", with: "8")
        outStr = outStr.replacingOccurrences(of: "٩", with: "9")
        
        return outStr
    }
    
    

    
    func onlyDigitChars() -> String{
        
        //remove all chars except numbers
        return self.inEnglishNumbers().components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    func printMaskedPanNumber()->String
    {
        var chars = ["_","_","_","_","_","_","_","_","_","_","_","_","_","_","_","_"]
        let str = self
        chars[0] = String(str[0])
        chars[1] = String(str[1])
        chars[2] = String(str[2])
        chars[3] = String(str[3])
        chars[4] = String(str[4])
        chars[5] = String(str[5])
        chars[6] = "*"
        chars[7] = "*"
        chars[8] = "*"
        chars[9] = "*"
        chars[10] = "*"
        chars[11] = "*"
        chars[12] = String(str[12])
        chars[13] = String(str[13])
        chars[14] = String(str[14])
        chars[15] = String(str[15])
        
        
        return chars.joined()
    }
    
    
    func formatPanStringWith(char: String) -> String {
        
        var newStr = self
        
        newStr.insert(contentsOf: char, at: newStr.index(newStr.startIndex, offsetBy: 12))
        newStr.insert(contentsOf: char, at: newStr.index(newStr.startIndex, offsetBy: 8))
        newStr.insert(contentsOf: char, at: newStr.index(newStr.startIndex, offsetBy: 4))
        
        newStr = String.LeftToRightMark + newStr
        
        return newStr
    }
    
    func substring(_ startIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        return self.substring(from: start)
    }
    
    func substring(_ startIndex: Int, _ endIndex: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex)
        if endIndex >= self.count {
            return self.substring(with: start..<self.endIndex)
        }
        let end = self.index(self.startIndex, offsetBy: endIndex)
        return self.substring(with: start..<end)
    }
    
    
    func checkCardNumberIsValid() -> Bool {
        
        let cardNo = self.onlyDigitChars()
        
        guard cardNo.length == 16 else {
            return false
        }
        
        guard !cardNo.hasPrefix("627353") else{     // Tejarat numbers may be invalid. no need to verify.
            return true
        }
        guard !cardNo.hasPrefix("505801") else{     // Kowsar numbers may be invalid. no need to verify.
            return true
        }
        
        var sum = 0
        for i in 0..<cardNo.length {
            let c = Int(String(cardNo[i]))!
            let factor: Int
            if (i + 1) % 2 == 0 {
                factor = 1
            } else {
                factor = 2
            }
            var cf = factor * c
            if cf > 9 {
                cf -= 9
            }
            sum += cf
            
        }
        return sum % 10 == 0
        
    }
    
    func currencyFormat() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value:double)
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        return formatter.string(from: number)!
    }
    // formatting text for currency textField
    func RemoveCurrencyFormat() -> String {
        var string:String!
        var newString:String!
        if string != "" {
            if string.count > 3 {
                if (string?.contains("."))! {
                    newString = (string.components(separatedBy: [".", " "]).joined().replacingOccurrences(of: " ", with: ""))
                    
                }
                else if (string?.contains(","))! {
                    newString = (string.components(separatedBy: [",", " "]).joined().replacingOccurrences(of: " ", with: ""))
                    
                }
                else {
                    newString = string
                    
                }
            }
        }
        else {
            
        }
        return newString
        
    }
    
    func RemoveingCurrencyFormat() -> String {
        var result: String = ""
        
        if (self.contains(".")) {
            result = (self.components(separatedBy: [".", " "]).joined().replacingOccurrences(of: " ", with: "")).trimmingCharacters(in: .whitespaces)
            
        }
        else if (self.contains(",")) {
            result = (self.components(separatedBy: [",", " "]).joined().replacingOccurrences(of: " ", with: "")).trimmingCharacters(in: .whitespaces)
            
        }
        else {
            result = self
            
        }
        return result
    }
    func inserting(separator: String, every n: Int) -> String {
        var result: String = ""
        let characters = Array(self.characters)
        stride(from: 0, to: characters.count, by: n).forEach {
            result += String(characters[$0..<min($0+n, characters.count)])
            if $0+n < characters.count {
                result += separator
            }
        }
        return result
    }

    func addSepratorCardNum() -> String {
        var _:String!
        var newString:String!
        
        newString = self.inserting(separator: "-", every: 4)
        return newString
        
    }
    func addSepratorforCardNum() -> String {
        var _:String!
        var newString:String!
        
        newString = self.inserting(separator: "  ", every: 4)
        return newString
        
    }
    func removeSepratorCardNum() -> String {
        var _:String!
        var newString:String!
        
        newString = self.replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespaces)
        return newString
        
    }
}
