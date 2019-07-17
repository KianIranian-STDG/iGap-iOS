//
//  IGExtensions.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/8/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import SDWebImage

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
    
    func localizedDate(showHour: Bool = false) -> String {
        var convertedDate = ""
        if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
            convertedDate =  SMDateUtil.toGregorianOnlyDate(self, showHour: showHour).inLocalizedLanguage()
        } else {
            convertedDate =  SMDateUtil.toPersianOnlyDate(self, showHour: showHour).inLocalizedLanguage()
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
extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.6, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
extension String {
    
    func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    func inLocalizedLanguage()->String{
        if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
            return self.inEnglishNumbers()
        } else {
            return self.inPersianNumbers()
        }
    }
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
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
