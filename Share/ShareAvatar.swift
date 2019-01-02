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

class ShareAvatar: UIView {
    
    private var initialLettersView: UIView?
    private var initialLettersLabel: UILabel?
    var avatarImageView: UIImageView?
    private var gradient: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    
    private func configure() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.masksToBounds = true
        
        let subViewsFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.initialLettersView = UIView(frame: subViewsFrame)
        self.avatarImageView = UIImageView(frame: subViewsFrame)
        self.initialLettersLabel = UILabel(frame: subViewsFrame)
        
        self.avatarImageView?.contentMode = .scaleAspectFill
        
        self.addSubview(self.initialLettersView!)
        self.addSubview(self.initialLettersLabel!)
        self.addSubview(self.avatarImageView!)
        
        self.initialLettersLabel!.textColor = UIColor.white
        self.initialLettersLabel!.textAlignment = .center
    }
    
    func clean() {
        self.avatarImageView!.image = nil
        self.initialLettersLabel!.text = ""
    }
    
    func setAvatar(imageData: Data?, initilas: String, initilasColor: String) {
        if imageData != nil {
            self.avatarImageView!.image = UIImage(data: imageData!)
        } else {
            self.avatarImageView?.image = nil
            self.initialLettersLabel!.text = initilas
            self.initialLettersView!.backgroundColor = UIColor(hexString: initilasColor)
            
            if self.frame.size.width < 40 {
                self.initialLettersLabel!.font = UIFont.boldSystemFont(ofSize: 10.0)
            } else if self.frame.size.width < 60 {
                self.initialLettersLabel!.font = UIFont.boldSystemFont(ofSize: 14.0)
            } else {
                self.initialLettersLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
            }
        }
    }
    
    func setImage(_ image: UIImage) {
        self.avatarImageView!.image = image
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
