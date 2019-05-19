/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation
import UIKit

/// RadioButtonControllerDelegate. Delegate optionally implements didSelectButton that receives selected button.
@objc protocol SSRadioButtonControllerDelegate {
    /**
     This function is called when a button is selected. If 'shouldLetDeSelect' is true, and a button is deselected, this function
     is called with a nil.
     
     */
    @objc optional func didSelectButton(_ aButton: UIButton?)
}

class SSRadioButtonsController : NSObject
{
    fileprivate var buttonsArray = [UIButton]()
    fileprivate weak var currentSelectedButton:UIButton? = nil
    weak var delegate : SSRadioButtonControllerDelegate? = nil
    /**
     Set whether a selected radio button can be deselected or not. Default value is false.
     */
    var shouldLetDeSelect = false
    /**
     Variadic parameter init that accepts UIButtons.
     - parameter buttons: Buttons that should behave as Radio Buttons
     */
    init(buttons: UIButton...) {
        super.init()
        for aButton in buttons {
            aButton.addTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
        }
        self.buttonsArray = buttons
    }
    /**
     Add a UIButton to Controller
     - parameter button: Add the button to controller.
     */
    func addButton(_ aButton: UIButton) {
        buttonsArray.append(aButton)
        aButton.addTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
    }
    /**
     Remove a UIButton from controller.
     - parameter button: Button to be removed from controller.
     */
    func removeButton(_ aButton: UIButton) {
        var iteratingButton: UIButton? = nil
        if(buttonsArray.contains(aButton))
        {
            iteratingButton = aButton
        }
        if(iteratingButton != nil) {
            buttonsArray.remove(at: buttonsArray.firstIndex(of: iteratingButton!)!)
            iteratingButton!.removeTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
            iteratingButton!.isSelected = false
            if currentSelectedButton == iteratingButton {
                currentSelectedButton = nil
            }
        }
    }
    /**
     Set an array of UIButons to behave as controller.
     
     - parameter buttonArray: Array of buttons
     */
    func setButtonsArray(_ aButtonsArray: [UIButton]) {
        for aButton in aButtonsArray {
            aButton.addTarget(self, action: #selector(SSRadioButtonsController.pressed(_:)), for: UIControl.Event.touchUpInside)
        }
        buttonsArray = aButtonsArray
    }
    
    @objc func pressed(_ sender: UIButton) {
        if(sender.isSelected) {
            if shouldLetDeSelect {
                sender.isSelected = false
                currentSelectedButton = nil
            }
        } else {
            for aButton in buttonsArray {
                aButton.isSelected = false
            }
            sender.isSelected = true
            currentSelectedButton = sender
        }
        delegate?.didSelectButton?(currentSelectedButton)
    }
    /**
     Get the currently selected button.
     
     - returns: Currenlty selected button.
     */
    func selectedButton() -> UIButton? {
        return currentSelectedButton
    }
}
