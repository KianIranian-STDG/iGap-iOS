/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */


/* Programatically Custom View */

class IGHelperView {
    
    internal static func makeSearchView(searchBar: UISearchBar, centerPlaceholder: Bool = false){
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.removeUnderline()
        }
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.darkGray
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.font = UIFont.igFont(ofSize: 14)
        searchBar.frame = CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 44)
        
        if centerPlaceholder {
            let placeholderText : String! = textFieldInsideSearchBarLabel?.text
            let placeholderWidth = placeholderText.width(withConstrainedHeight: 44, font: UIFont.igFont(ofSize: 14)) + 35
            let offset = UIOffset(horizontal: (searchBar.frame.width - (placeholderWidth)) / 2, vertical: 0)
            searchBar.setPositionAdjustment(offset, for: .search)
        }
    }

}
