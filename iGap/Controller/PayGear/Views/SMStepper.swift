//
//  SMStepper.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/23/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit


/// Protocol to observe changes on value of
/// Two actions call this method, increase and decrease value.
 protocol SMStepperDelegate {
    func stepperValueDidChanged()
}

// MARK: - extention to implement protocol method
/// avoid crash when owner class is not implemented protocol method
extension SMStepperDelegate {
    func stepperValueDidChanged(){
        // leaving this empty
    }
}
@IBDesignable
/// Custom stepper as defined by design; this stepper is custom only on view style
/// and support all actions of a normal Stepper object
/// The buttons style of this object is customable out of this class
public class SMStepper: UIView {

    
    let leftButton = SMBottomButton()
    let rightButton = SMBottomButton()
    let label = UILabel()
    var delegate: SMStepperDelegate!
    
    /// Stepper value
    @IBInspectable public var value = 1 {
        didSet {
            label.text = "  \(String(describing: value))  \("PersonUnit".localized)  ".inLocalizedLanguage()
            if delegate != nil {
                delegate.stepperValueDidChanged()
            }
        }
    }
    
    @IBInspectable public var leftButtonText: String = "-" {
        didSet {
            leftButton.setTitle(leftButtonText, for: .normal)
        }
    }
    
    /// Text on the right button. Be sure that it fits in the button. Defaults to "+".
    @IBInspectable public var rightButtonText: String = "+" {
        didSet {
            
            rightButton.setTitle(rightButtonText, for: .normal)
        }
    }
    
    /// Text color of the buttons. Defaults to white.
    @IBInspectable public var buttonsTextColor: UIColor = .white {
        didSet {
            for button in [leftButton, rightButton] {
                button.setTitleColor(buttonsTextColor, for: .normal)
            }
        }
    }

    @IBInspectable public var buttonsTextFont: UIFont = SMFonts.IranYekanLight(35) {
        didSet {
            for button in [leftButton, rightButton] {
                button.titleLabel?.font = buttonsTextFont
            }
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
	
	
    /// Load view, add actions and style to objects
    func setup() {
        
        leftButton.setTitle("-", for: .normal)
        leftButton.colors = [UIColor(netHex: 0xffbe00), UIColor(netHex: 0xff7600)]
        leftButton.titleLabel?.font = buttonsTextFont
        leftButton.titleLabel?.textAlignment = .right
        leftButton.contentHorizontalAlignment = .center
        leftButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 22)
        leftButton.enable()
        leftButton.addTarget(self, action: #selector(leftButtonTouchDown(_:)), for: .touchDown)
        addSubview(leftButton)
		
        rightButton.setTitle("+", for: .normal)
        rightButton.colors = [UIColor(netHex: 0xffbe00), UIColor(netHex: 0xff7600)]
        rightButton.titleLabel?.font = buttonsTextFont
        rightButton.titleLabel?.textAlignment = .left
        rightButton.contentHorizontalAlignment = .center
        rightButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0)
        rightButton.enable()
        rightButton.addTarget(self, action: #selector(rightButtonTouchDown(_:)), for: .touchDown)

        self.addSubview(rightButton)
        
        value = 1
		
        label.text = "  \(String(describing: value)) \("PersonUnit".localized)  ".inLocalizedLanguage()
        label.textAlignment = .center
        label.backgroundColor = .white
        label.clipsToBounds = true;
        label.font = SMFonts.IranYekanBold(18)
		label.minimumScaleFactor = 0.5;
		label.adjustsFontSizeToFitWidth = true;
        label.textColor = UIColor(netHex: 0x416480)
        label.layer.borderWidth = 1
        label.frame = frame.insetBy(dx: -25, dy: -25)
        label.layer.borderColor = UIColor(netHex: 0x2196f3).cgColor
        addSubview(label)
        
        self.isUserInteractionEnabled = true
        
    }
    
    
    
    /// Reload layout after loading view
    override public func layoutSubviews() {
        
        let overlapSize: CGFloat = 25
        let labelWidthWeight: CGFloat = 0.35
        let buttonYMargin: CGFloat = 5

        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * (labelWidthWeight)

        leftButton.frame = CGRect(x: 0, y: buttonYMargin, width: buttonWidth, height: bounds.size.height - (buttonYMargin * 2))

        label.frame = CGRect(x:(buttonWidth - overlapSize), y: 0, width: (labelWidth + 2 * overlapSize), height: bounds.size.height)

        rightButton.frame = CGRect(x: (buttonWidth + labelWidth), y: buttonYMargin, width: buttonWidth, height: bounds.size.height - (buttonYMargin * 2))
        
        leftButton.layer.cornerRadius = leftButton.frame.size.height / 2
        rightButton.layer.cornerRadius = rightButton.frame.size.height / 2
        label.layer.cornerRadius = label.frame.size.height / 2
        
    }

    /// Decrease value
    ///
    /// - Parameter button: left button object
    @objc func leftButtonTouchDown(_ button: UIButton) {
        if value > 0 {
            value -= 1
        }
    }
    
    /// Increase value
    ///
    /// - Parameter button: right button object
    @objc func rightButtonTouchDown(_ button: UIButton) {
        value += 1
    }
    

}
