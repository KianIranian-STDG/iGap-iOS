//
//  DynamicTextLayer.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/11/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//
import UIKit
import Foundation


extension String {
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}

class DynamicTextLayer : CATextLayer {
    var adjustsFontSizeToFitWidth = false
    
    override func layoutSublayers() {
        super.layoutSublayers()
        if adjustsFontSizeToFitWidth {
            fitToFrame()
        }
    }
    
    func fitToFrame(){
        // Calculates the string size.
        var stringSize: CGSize  {
            get { return (string as? String)!.size(OfFont: UIFont(name: (font as! UIFont).fontName, size: fontSize)!) }
        }
        // Adds inset from the borders. Optional
        let inset: CGFloat = 2
        // Decreases the font size until criteria met
        while frame.width < stringSize.width + inset {
            fontSize -= 1
        }
    }
}
