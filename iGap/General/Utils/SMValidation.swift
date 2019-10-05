//
//  SMValidation.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/11/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Class contains validation methods, the method of this class are class function
class SMValidation: NSObject {

    /// Class func to validate phone number
    ///
    /// - Parameter mobileString: String of mobile number
	/// - Returns: true: is format valid, false it is not valid
	///
	/// mobile number must be 12 characters and has country code as prefix
	
    class func mobileValidation (_ mobileString : String) -> Bool {
        
        //+989xxxxxxxxx
        let str = mobileString.inEnglishNumbersNew().components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return (str.length == 12 && str.hasPrefix("989"))
    }

    /// Class method to validate pin code messaged at login
    ///
    /// - Parameter pinCode: String of pin code
    /// - Returns: validation status
	///
	/// login pin is 4 character and it is only digit character
    class func pinCodeValidation (_ pinCode : String) -> Bool {
        var validation: Bool = false
        if pinCode.length == 4 {
            //althogh keyboard is numberpad in this case, past option is available in all fields, to prevent accepting input like "55aa" the check code for number is added
            if Int(pinCode) != nil {
                validation = true
            }
        }
        return validation
    }
	
	/// Class method to validate wallet passcode
	///
	/// - Parameter pinCode: String pin code
	/// - Returns: status of validation
	///
	/// wallet pin code id digit more than 3 characters
	class func walletPassCodeValidation (_ pinCode : String) -> Bool {
		var validation: Bool = false
		if pinCode.length > 3 {
			//althogh keyboard is numberpad in this case, past option is available in all fields, to prevent accepting input like "55aa" the check code for number is added
			if Int(pinCode) != nil {
				validation = true
			}
		}
		return validation
	}
    

	
	/// Class method to validate error on toast
	///
	/// - Parameter userInfo: A Dictionary
	/// - Returns: Status of validation
	
	/// If userinfo contains error which is offline or timeout or server error
	/// this method returns true
	class func showConnectionErrorToast(_ userInfo: Any) -> Bool {
		
		if type(of: userInfo) == (Swift.Dictionary<String, String>).self &&
			(userInfo as! Dictionary<String, String>)["server error"] != nil &&
			(userInfo as! Dictionary<String, String>)["server error"] == "Unreachable" {
			return true
		}
		guard let value = (userInfo as! Dictionary<String, AnyObject>)["NSUnderlyingError"] else {return false}
		let code = (value as! NSError).code
		if code == -1009 || code == -1001 {
			return true
		}
		
		
		return false
	}
}
