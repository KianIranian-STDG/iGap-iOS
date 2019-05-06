//
//  BaseCollectionViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/24/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class BaseCollectionViewController: UICollectionViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideKeyboardWhenTappedAround()
        let current : String = SMLangUtil.loadLanguage()
        switch current {
        case "fa" :
            UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
            
        case "en" :
            UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
            
        case "ar" :
            UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
            
        default :
            break
        }
    }
    
    public func setDirectionManually(direction: UISemanticContentAttribute)  {
        UIView.appearance().semanticContentAttribute = direction
    }
    
}
