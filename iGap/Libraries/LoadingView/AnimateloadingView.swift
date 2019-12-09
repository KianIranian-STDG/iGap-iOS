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


class AnimateloadingView : UIView {
    
    public var isAnimating : Bool = false
    /**
     Start animating.
     */
    public final func startAnimating() {
        isHidden = false
        layer.speed = 1
        setUpAnimation(in: layer, size: self.frame.size)
    }
    /**
     Stop animating.
     */
    public final func stopAnimating() {
        if isAnimating == false {return}
        isHidden = true
        layer.sublayers?.removeAll()
        isAnimating = false
    }
    func setUpAnimation(in layer: CALayer, size: CGSize) {
        let color = ThemeManager.currentTheme.ProgressColor
        let beginTime: Double = 0.5
        let strokeStartDuration: Double = 1.5
        let strokeEndDuration: Double = 1.1
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.byValue = Float.pi * 2
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.duration = strokeEndDuration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.duration = strokeStartDuration
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        
        strokeStartAnimation.fromValue = 0
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.beginTime = beginTime
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rotationAnimation, strokeEndAnimation, strokeStartAnimation]
        groupAnimation.duration = strokeStartDuration + beginTime
        groupAnimation.repeatCount = .infinity
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        let circle = circleLayer(size: size, color: color)
        let frame = CGRect(
            x: (layer.bounds.width - size.width) / 2,
            y: (layer.bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        
        let backgroundFrame = CGRect(
            x: (layer.bounds.width - (size.width + 10)) / 2,
            y: (layer.bounds.height - (size.height + 10)) / 2,
            width: size.width + 10,
            height: size.height + 10
        )

        let backgroundView: UIView = UIView(frame: backgroundFrame)
        backgroundView.backgroundColor = ThemeManager.currentTheme.ProgressBackgroundColor
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        backgroundView.layer.shadowRadius = 5
        backgroundView.layer.shadowOpacity = 0.3
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.cornerRadius = (size.width + 10) / 2
        
        circle.frame = frame
        circle.add(groupAnimation, forKey: "animation")
        self.addSubview(backgroundView)
        layer.addSublayer(circle)
        isAnimating = true
    }
    func circleLayer(size: CGSize, color: UIColor) -> CALayer{
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    radius: size.width / 2,
                    startAngle: -(.pi / 2),
                    endAngle: .pi + .pi / 2,
                    clockwise: true)
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = 2

        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
    }
}

