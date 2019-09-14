//
//  customSearchBar.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class customSearchBar: UISearchBar {
    
    var preferredFont: UIFont?
    var preferredTextColor: UIColor?
    
    init(){
        super.init(frame: CGRect.zero)
    }
    
    func setUp(delegate: UISearchBarDelegate?,
               frame: CGRect?,
               barStyle: UISearchBar.Style,
               placeholder: String,
               font: UIFont?,
               textColor: UIColor?,
               barTintColor: UIColor?,
               tintColor: UIColor?) {
        
        self.delegate = delegate
        self.frame = frame ?? self.frame
        self.searchBarStyle = searchBarStyle
        self.placeholder = placeholder
        self.preferredFont = font
        self.preferredTextColor = textColor
        self.barTintColor = barTintColor ?? self.barTintColor
        self.tintColor = tintColor ?? self.tintColor
        self.bottomLineColor = tintColor ?? UIColor.clear
        
        sizeToFit()
        
        //        translucent = false
        //        showsBookmarkButton = false
        //        showsCancelButton = true
        //        setShowsCancelButton(false, animated: false)
        //        customSearchBar.backgroundImage = UIImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    let bottomLine = CAShapeLayer()
    var bottomLineColor = UIColor.clear
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        for view in subviews {
            if let searchField = view as? UITextField { setSearchFieldAppearance(searchField: searchField); break }
            else {
                for sView in view.subviews {
                    if let searchField = sView as? UITextField { setSearchFieldAppearance(searchField: searchField); break }
                }
            }
        }
        
        bottomLine.path = UIBezierPath(rect: CGRect(x: 0.0, y: frame.size.height - 1, width: frame.size.width, height: 1.0)).cgPath
        bottomLine.fillColor = UIColor.clear.cgColor
        layer.addSublayer(bottomLine)
    }
    
    func setSearchFieldAppearance(searchField: UITextField) {
        searchField.frame = CGRect(x: 5.0, y: 5.0, width: frame.size.width - 10.0, height: frame.size.height - 10.0)
        searchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
        searchField.textColor = UIColor.white
        searchField.textAlignment = .center
        let imageV = searchField.leftView as! UIImageView
        imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        imageV.tintColor = UIColor.white
        
        if let backgroundview = searchField.subviews.first {
            backgroundview.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            backgroundview.layer.cornerRadius = 10;
            backgroundview.clipsToBounds = true;
            
        }

        if let placeHolderInsideSearchField = searchField.value(forKey: "placeholderLabel") as? UILabel {
            placeHolderInsideSearchField.textColor = UIColor.white
            placeHolderInsideSearchField.textAlignment = .center
            placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
            placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
            
                placeHolderInsideSearchField.frame = CGRect(x: 100.0, y: 5.0, width: 300.0, height: frame.size.height - 10.0)
        }


        //searchField.backgroundColor = UIColor.clearColor()
        //backgroundImage = UIImage()
    }
    
}

