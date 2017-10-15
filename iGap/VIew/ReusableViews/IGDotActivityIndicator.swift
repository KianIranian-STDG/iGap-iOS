/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit

@IBDesignable
class IGDotActivityIndicator : UIView {
    private var dotLayers = [CAShapeLayer]()
    private var dotsScale = 1.4
    
    let fillColor = UIColor.white

    @IBInspectable var dotsCount :Int = 3 {
        didSet {
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.dotLayers.removeAll()
            self.setupLayers()
        }
    }
    
    @IBInspectable var dotsRadius: CGFloat = 3 {
        didSet {
            for layer in dotLayers {
                layer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: dotsRadius*2.0, height: dotsRadius*2.0))
                layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: dotsRadius).cgPath
            }
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var dotsSpacing :CGFloat = 4 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            for layer in dotLayers {
                layer.fillColor = fillColor.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        let even = (dotsCount % 2 == 0)
        let middle :Int = dotsCount/2
        for (index, layer) in dotLayers.enumerated() {
            let x = center.x+CGFloat(index-middle)*((dotsRadius*2)+dotsSpacing)+(even ? (dotsRadius+(dotsSpacing/2)) : 0)
            layer.position = CGPoint(x: x, y: center.y)
        }
        startAnimating()
    }
    
    func startAnimating() {
        var offset :TimeInterval = 0.0
        dotLayers.forEach {
            $0.removeAllAnimations()
            $0.add(scaleAnimation(offset), forKey: "scaleAnim")
            offset = offset+0.20
        }
    }
    
    func stopAnimating() {
        dotLayers.forEach { $0.removeAllAnimations() }
    }
    
    private func dotLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: dotsRadius*2.0, height: dotsRadius*2.0))
        layer.path = UIBezierPath(roundedRect: layer.bounds, cornerRadius: dotsRadius).cgPath
        layer.fillColor = fillColor.cgColor
        return layer
    }
    
    private func setupLayers() {
        for _ in 0..<dotsCount {
            let layer = dotLayer()
            self.dotLayers.append(layer)
            self.layer.addSublayer(layer)
        }
    }
    
    private func scaleAnimation(_ after: TimeInterval = 0) -> CAAnimationGroup {
        let scaleUp = CABasicAnimation(keyPath: "transform.scale")
        scaleUp.beginTime = after
        scaleUp.fromValue = 1
        scaleUp.toValue = dotsScale
        scaleUp.duration = 0.3
        scaleUp.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.beginTime = after+scaleUp.duration
        scaleDown.fromValue = dotsScale
        scaleDown.toValue = 1.0
        scaleDown.duration = 0.2
        scaleDown.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let group = CAAnimationGroup()
        group.animations = [scaleUp, scaleDown]
        group.repeatCount = Float.infinity
        
        let sum = CGFloat(dotsCount)*0.3+CGFloat(0.4)
        group.duration = CFTimeInterval(sum)
        
        return group
    }
}
