//
//  NumberpadButton.swift
//  HamrahCard
//
//  Created by Alireza Ghias on 6/28/1396 AP.
//  Copyright © 1396 Farazpardazan. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NumberpadButton: UIButton {
	
	@IBInspectable
	var highlightBackgroundColor: UIColor? = UIColor.lightGray
	@IBInspectable
	var defaultBackgroundColor: UIColor? = UIColor.white
	
	
    
    
    
	override open var isHighlighted: Bool {
		
		didSet {
			backgroundColor = isHighlighted ? highlightBackgroundColor : defaultBackgroundColor
           	}
	}
	
}
