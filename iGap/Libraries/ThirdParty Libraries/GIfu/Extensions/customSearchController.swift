/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

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
