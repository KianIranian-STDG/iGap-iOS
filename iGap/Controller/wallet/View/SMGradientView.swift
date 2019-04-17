//
//  SMGradientView.swift
//  PayGear
//
//  Created by a on 4/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

//@IBDesignable
class SMGradientView: UIView {
    
    private let gradientLayer = SMSimpleLinearGradientLayer()
    
    
    var colors:[UIColor] = [UIColor.white,UIColor.white]{
        didSet{
            gradientLayer.colors = self.colors
        }
    }
    
    
    
    
    @IBInspectable
    var fromColor: UIColor = UIColor.white {
        didSet {
            self.colors = [fromColor, toColor]
        }
    }
    
    
    @IBInspectable
    var toColor: UIColor = UIColor.white {
        didSet {
            self.colors = [fromColor, toColor]
        }
    }
    
   
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
        
    }
    
    
}


class SMSimpleLinearGradientLayer: CALayer {
    var colors: [UIColor] = [UIColor.white,UIColor.white]{
        didSet {
            setNeedsDisplay()
        }
    }
    
    var cgColors: [CGColor] {
        return colors.map({ (color) -> CGColor in
            return color.cgColor
        })
    }
    
  
    
    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
       
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override func draw(in ctx: CGContext) {
        
        ctx.saveGState()
        
        let opt = CGGradientDrawingOptions(rawValue: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations: [CGFloat] = [0.0, 1.0]
        
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations)!
        
        ctx.drawLinearGradient(gradient, start:  CGPoint.init(x: 0.0, y: 0.0), end:  CGPoint.init(x: 0.0, y: bounds.height), options: opt)
        
    }
    
}
