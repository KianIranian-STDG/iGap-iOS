//
//  SMExtensions.swift
//  PayGear
//
//  Created by a on 4/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
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
	
	var SMSignupTitle:String?{
		set{
			let titleLabel = UILabel()
			titleLabel.text = (newValue ?? "").truncateWord(30)
			titleLabel.font = SMFonts.IranYekanBold(18)
			titleLabel.textColor = SMColor.SignupTitleTextColor
			titleLabel.sizeToFit()
			
			self.navigationItem.titleView = titleLabel
		}
		get{
			return (self.navigationItem.titleView as? UILabel)?.text
		}
	}
	
    var SMTitle:String?{
        set{
            let titleLabel = UILabel()
            titleLabel.text = (newValue ?? "").truncateWord(30)
            titleLabel.font = SMFonts.IranYekanBold(18)
            titleLabel.textColor = SMColor.TitleTextColor
            titleLabel.sizeToFit()
            
            self.navigationItem.titleView = titleLabel
        }
        get{
            return (self.navigationItem.titleView as? UILabel)?.text
        }
    }
    
    
    var SMIcon:UIImage?{
        set{
            let profileImage = UIBarButtonItem()
            profileImage.image = newValue
            self.navigationItem.leftBarButtonItem? = profileImage
        }
        get{
            return self.navigationItem.leftBarButtonItem?.image
        }
    }
	
}



extension UIButton {
    
}


extension Date {
	
	func localizedDateTime() -> String {
		var convertedDate = ""
		if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
			convertedDate =  SMDateUtil.toGregorian(self).inLocalizedLanguage()
		}
		else {
			convertedDate =  SMDateUtil.toPersian(self).inLocalizedLanguage()
		}
		return convertedDate
	}
	
	func localizedDate() -> String {
		var convertedDate = ""
		if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
			convertedDate =  SMDateUtil.toGregorianOnlyDate(self).inLocalizedLanguage()
		}
		else {
			convertedDate =  SMDateUtil.toPersianOnlyDate(self).inLocalizedLanguage()
		}
		return convertedDate
	}
	
	func localizedDateByComponent() -> ((Int?, Int?, Int?)) {
		
		if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
			return  SMDateUtil.toGregorianYearMonthDay(self)
		}
			return  SMDateUtil.toPersianYearMonthDay(self)
	}
	
	static func toDate(_ year: Int, month: Int, day: Int, hour: Int? = nil, minute: Int? = nil) -> Date? {

		if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
			return SMDateUtil.gregorianToDate(year, month: month, day: day, hour: hour, minute: minute)

		}
		else {
			return SMDateUtil.persianToDate(year, month: month, day: day, hour: hour, minute: minute)
		}
	}
}


extension Data {
    func hex(separator:String = "") -> String {
        return (self.map { String(format: "%02X", $0) }).joined(separator: separator)
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
    
    subscript (i: Int) -> Character {
        get {
            let index = self.index(startIndex, offsetBy: i)
            return self[index]
        }
    }
    
    var localized: String {
        let bundle = Bundle(path: Bundle.main.path(forResource: SMLangUtil.lang, ofType: "lproj")!)!
        return NSLocalizedString(self, tableName: "Localization", bundle: bundle, value: "", comment: "")
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
    
   
    func inLocalizedLanguage()->String{
        if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
            return self.inEnglishNumbers()
        }
        else{
            return self.inPersianNumbers()
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
//		outStr = outStr.replacingOccurrences(of: "*", with: "•")
        
        
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
    
    
    func inRialFormat()->String{
        
        let nf = NumberFormatter()
        
        nf.locale = Locale(identifier: "fa")
        nf.numberStyle = .decimal
        nf.allowsFloats = false
        nf.maximumFractionDigits = 0
        nf.groupingSeparator = ","
        
        
        let str = nf.string(from: NSNumber(value: Double(self) ?? 0)) ?? "0"
        
        return "\(str)"
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
    
}


extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
    
    func createGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UIView {
    
    static func reuseIdentifier() -> String {
        return NSStringFromClass(classForCoder()).components(separatedBy: ".").last!
    }
    
    static func UINibForClass(_ bundle: Bundle? = nil) -> UINib {
        return UINib(nibName: reuseIdentifier(), bundle: bundle)
    }
    
    
    
    
func addTransitionFade(_ duration: TimeInterval = 0.5) {
    let animation = CATransition()
    
    animation.type = CATransitionType.fade
    animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
    animation.fillMode = CAMediaTimingFillMode.forwards
    animation.duration = duration
    
    layer.add(animation, forKey: "kCATransitionFade")
    
}
}

extension UIImageView {
	
	static let imageCache = NSCache<NSString, UIImage>()
	
	static func downloadImage(url: URL, cacehable: Bool, completion: @escaping (_ image: UIImage?, _ error: Error? ) -> Void) {
		if cacehable, let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
			SMLog.SMPrint("request from cache ----> \(url)")
			completion(cachedImage, nil)
		} else {
			SMLog.SMPrint("request to dl ----> \(url)")
			URLSession.shared.dataTask(with: url) { data, response, error in
				guard
					let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
					let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
					let data = data, error == nil,
					let image = UIImage(data: data)
					else {
						completion(nil, error)
						return
				}
				if cacehable {
					imageCache.setObject(image, forKey: url.absoluteString as NSString)
				}
				completion(image, nil)
				
				}.resume()
			
		}
	}
	
	func downloadedFrom(url: URL, cashable: Bool = false, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: @escaping (_ completed: Bool) -> () ) {
        contentMode = mode
		
		UIImageView.downloadImage(url: url, cacehable: cashable) { (image, error) in
			if (image != nil){
				DispatchQueue.main.async() {
					self.image = image
					completion(true)
				}
				return
			}
			else {
				completion(false)
				return
			}
		}
		
    }
    
	func downloadedFrom(link: String, cashable: Bool = false, contentMode mode: UIView.ContentMode = .scaleAspectFit, completion: @escaping (_ completed: Bool) -> () = {_ in ()}) {
        guard let url = URL(string: link) else { return }
		downloadedFrom(url: url, cashable: cashable, contentMode: mode, completion: completion)
    }
}

extension NSObject {
	
	static func downloadImageFrom(url: URL, closure: @escaping (_ image: UIImage?) -> ()) {
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard
				let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data)
			else {return}
			closure(image)
			}.resume()
		
	}
}

extension CAShapeLayer {
	internal func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
		fillColor = filled ? color.cgColor : UIColor.white.cgColor
		strokeColor = color.cgColor
		let origin = CGPoint(x: location.x - radius, y: location.y - radius)
		path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
	}
}

extension UIBarButtonItem {
	func addBadge(string: String, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
		guard let view = self.value(forKey: "view") as? UIView else { return }
		
		// Initialize Badge
		let badge = CAShapeLayer()
		let radius = CGFloat(7)
		let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
		badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
		
		view.layer.addSublayer(badge)
		
		// Initialiaze Badge's label
		let label = CATextLayer()
		label.string = string
		label.alignmentMode = CATextLayerAlignmentMode.center
		label.fontSize = 11
		label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
		label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
		label.backgroundColor = UIColor.clear.cgColor
		label.contentsScale = UIScreen.main.scale
		badge.addSublayer(label)
	}
}
