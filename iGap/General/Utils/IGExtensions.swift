/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import SDWebImage
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
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
    
    func localizedDate(showHour: Bool = false) -> String {
        var convertedDate = ""
        if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
            convertedDate =  SMDateUtil.toGregorianOnlyDate(self, showHour: showHour).inLocalizedLanguage()
        } else {
            convertedDate =  SMDateUtil.toPersianOnlyDate(self, showHour: showHour).inLocalizedLanguage()
        }
        return convertedDate
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
            return self.inEnglishNumbersNew()
        } else {
            return self.inPersianNumbersNew()
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

extension Thread {
    
    var threadName: String {
        if let currentOperationQueue = OperationQueue.current?.name {
            return "OperationQueue: \(currentOperationQueue)"
        } else if let underlyingDispatchQueue = OperationQueue.current?.underlyingQueue?.label {
            return "DispatchQueue: \(underlyingDispatchQueue)"
        } else {
            let name = __dispatch_queue_get_label(nil)
            return String(cString: name, encoding: .utf8) ?? Thread.current.description
        }
    }
}

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> ()) {
        
        pushViewController(viewController, animated: animated)
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popViewController(viewController: UIViewController? = nil, animated: Bool, completion: @escaping () -> ()) {
        if let viewController = viewController {
            popToViewController(viewController, animated: animated)
        } else {
            popViewController(animated: animated)
        }
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popToRootViewController(animated: Bool, completion: @escaping () -> ()) {
        popToRootViewController(animated: animated)
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}

// MARK: - CAGradientLayer extensions
extension CAGradientLayer {

    enum Point {
        case topRight, topLeft
        case bottomRight, bottomLeft
        case centerRight, centerLeft
        case custion(point: CGPoint)

        var point: CGPoint {
            switch self {
                case .topRight: return CGPoint(x: 1, y: 0)
                case .topLeft: return CGPoint(x: 0, y: 0)
                case .bottomRight: return CGPoint(x: 1, y: 1)
                case .bottomLeft: return CGPoint(x: 0, y: 1)
                case .centerRight: return CGPoint(x: 1, y: 0.5)
                case .centerLeft: return CGPoint(x: 0, y: 0.5)
                case .custion(let point): return point
            }
        }
    }

    convenience init(frame: CGRect, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        self.init()
        self.frame = frame
        self.colors = colors.map { $0.cgColor }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    convenience init(frame: CGRect, colors: [UIColor], startPoint: Point, endPoint: Point) {
        self.init(frame: frame, colors: colors, startPoint: startPoint.point, endPoint: endPoint.point)
    }

    func createGradientImage() -> UIImage? {
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

