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

public protocol PinCodeTextFieldDelegate: class {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool // return false to disallow editing.
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) // became first responder
    
    func textFieldValueChanged(_ textField: PinCodeTextField) // text value changed
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool // return true to allow editing to stop and to resign first responder status at the last character entered event. NO to disallow the editing session to end
    
    func textFieldDidEndEditing(_ textField: PinCodeTextField) // called when pinCodeTextField did end editing
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool // called when 'return' key pressed. return false to ignore.
}

/// default
public extension PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
}
