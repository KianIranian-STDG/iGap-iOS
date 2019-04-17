//
//  SMError.swift
//  PayGear
//
//  Created by amir soltani on 4/15/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

struct SMError: Error {
    
    var code: Int
    var customError: String
    
    init(code: Int) {
        self.code = code
        customError = ""
    }
    
    init(code: Int, customError: String) {
        self.code = code
        self.customError = customError
    }
    
    func getInfo() -> String{
        
        if customError.length > 0 {
            return customError.localized
        } else if self.code == -1 {
            return "error.network".localized
        } else if self.code == -2 {
            return "error.network".localized
        } else if self.code == -3 {
            return "error.upload.network".localized
        } else {
            return "error.network".localized
        }
        
    }
    
}

