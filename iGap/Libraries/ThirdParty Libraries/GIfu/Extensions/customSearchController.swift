//
//  customSearchController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

 class customSearchController: UISearchController {
    
    private var cSearchBar = customSearchBar()
    override public var searchBar: UISearchBar {
        get {
            return cSearchBar
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public init(searchResultsController: UIViewController? = nil,
                searchResultsUpdater: UISearchResultsUpdating? = nil,
                delegate: UISearchControllerDelegate? = nil,
                dimsBackgroundDuringPresentation: Bool,
                hidesNavigationBarDuringPresentation: Bool,
                searchBarDelegate: UISearchBarDelegate?,
                searchBarFrame: CGRect?,
                searchBarStyle: UISearchBar.Style,
                searchBarPlaceHolder: String,
                searchBarFont: UIFont?,
                searchBarTextColor: UIColor?,
                searchBarBarTintColor: UIColor?, // Bar background
        searchBarTintColor: UIColor) { // Cursor and bottom line
        
        super.init(searchResultsController: searchResultsController)
        
        self.searchResultsUpdater = searchResultsUpdater
        self.delegate = delegate
        self.dimsBackgroundDuringPresentation = dimsBackgroundDuringPresentation
        self.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation
        
        cSearchBar.setUp(delegate: searchBarDelegate,
                              frame: searchBarFrame,
                              barStyle: searchBarStyle,
                              placeholder: searchBarPlaceHolder,
                              font: searchBarFont,
                              textColor: searchBarTextColor,
                              barTintColor: searchBarBarTintColor,
                              tintColor: searchBarTintColor)
        
    }
}
