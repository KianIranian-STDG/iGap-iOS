//
//  IGSearchTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 10/5/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import IGProtoBuff
import SwiftProtobuf
import RealmSwift

class IGSearchTableViewController: BaseTableViewController {
    static var enableForward = false //open forward page or main tab due to the this value
    var findResult: [IGLookAndFindStruct] = []
    var searching = false // use this param for avoid from duplicate search
    var latestSearchText = ""
    lazy var searchController : UISearchController = {
            
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = ""
            searchController.searchBar.setValue("CANCEL_BTN".localizedNew, forKey: "cancelButtonText")
            
            let gradient = CAGradientLayer()
            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

            gradient.frame = defaultNavigationBarFrame
            gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
            gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
    //        gradient.locations = orangeGradientLocation as [NSNumber]

            
        if #available(iOS 13.0, *) {
            searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))

        } else {
            searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))

        }
        searchController.searchBar.backgroundImage = UIImage()
            return searchController

        }()
    
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            
            if #available(iOS 13.0, *) {
                if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                    // appearance has changed
                    // Update your user interface based on the appearance
                    self.setSearchBarGradient()
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
        private func setSearchBarGradient() {
            let gradient = CAGradientLayer()
            let defaultNavigationBarFrame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width), height: 64)

            gradient.frame = defaultNavigationBarFrame
            gradient.colors = [UIColor(named: themeColor.navigationFirstColor.rawValue)!.cgColor, UIColor(named: themeColor.navigationSecondColor.rawValue)!.cgColor]
            gradient.startPoint = CGPoint(x: 0.0,y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0,y: 0.5)
    //        gradient.locations = orangeGradientLocation as [NSNumber]
            
            searchController.searchBar.barTintColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            searchController.searchBar.backgroundColor = UIColor(patternImage: IGGlobal.image(fromLayer: gradient))
            
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.scrollsToTop = false
        self.tableView.bounces = false
        self.tableView.contentOffset = CGPoint(x: 0, y: 0)

        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil,title: "SEARCH_PLACEHOLDER".localizedNew, iGapFont: true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initialiseSearchBar()
        
    }
    
    private func initialiseSearchBar() {
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
            
            let imageV = textField.leftView as! UIImageView
            imageV.image = nil
            if let backgroundview = textField.subviews.first {
                backgroundview.backgroundColor = UIColor(named: themeColor.searchBarBackGroundColor.rawValue)
                for view in backgroundview.subviews {
                    if view is UIView {
                        view.backgroundColor = .clear
                    }
                }
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
                
            }
            
            if let searchBarCancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
                searchBarCancelButton.setTitle("CANCEL_BTN".localizedNew, for: .normal)
                searchBarCancelButton.titleLabel!.font = UIFont.igFont(ofSize: 14,weight: .bold)
                searchBarCancelButton.tintColor = UIColor.white
            }
            
            if let placeHolderInsideSearchField = textField.value(forKey: "placeholderLabel") as? UILabel {
                placeHolderInsideSearchField.textColor = UIColor.white
                placeHolderInsideSearchField.textAlignment = .center
                placeHolderInsideSearchField.text = "SEARCH_PLACEHOLDER".localizedNew
                if let backgroundview = textField.subviews.first {
                    placeHolderInsideSearchField.center = backgroundview.center
                }
                placeHolderInsideSearchField.font = UIFont.igFont(ofSize: 15,weight: .bold)
                
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.tableHeaderView = searchController.searchBar


        // navigationItem.setChatListsNavigationItems()
//        let navigationItem = self.navigationItem as! IGNavigationItem
//        navigationItem.addNavigationViewItems(rightItemText: nil,title: "SEARCH_PLACEHOLDER".localizedNew, iGapFont: true)
//        navigationItem.navigationController = self.navigationController as? IGNavigationController
//        self.initNavigationBar {
//            
//        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        IGGlobal.shouldMultiSelect = false

    }
    // MARK: - Table view data source
    
    //****************** tableView ******************
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return findResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = self.findResult[indexPath.row]
        
        if result.isHeader {
            let cell: IGLookAndFindCell = self.tableView.dequeueReusableCell(withIdentifier: "HeaderSearch", for: indexPath) as! IGLookAndFindCell
            cell.setHeader(type: result.type)
            return cell
        }
        
        let cell: IGLookAndFindCell = self.tableView.dequeueReusableCell(withIdentifier: "LookUpSearch", for: indexPath) as! IGLookAndFindCell
        cell.setSearchResult(result: result)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 74.0, bottom: 0, right: 0)
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // IGRegistredUserInfoTableViewController
        
        self.navigationController?.hero.isEnabled = true
        self.navigationController?.hero.navigationAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .slide(direction: .right))
        
        let searchResult = self.findResult[indexPath.row]
        
        var room = searchResult.room
        var type = IGPClientSearchUsernameResponse.IGPResult.IGPType.room.rawValue
        
        if searchResult.type == .message || searchResult.type == .hashtag {
            room = IGRoom.getRoomInfo(roomId: searchResult.message.roomId)
        } else if searchResult.type == .user {
            type = IGPClientSearchUsernameResponse.IGPResult.IGPType.user.rawValue
        }
        
        if IGGlobal.isForwardEnable() {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                IGRecentsTableViewController.forwardStartObserver.onForwardStart(user: searchResult.user, room: room, type: IGPClientSearchUsernameResponse.IGPResult.IGPType(rawValue: type)!)
            }
            
            dismiss(animated: true, completion: nil)
            dismiss(animated: true, completion: nil)
            
        } else {
            var tmpType : String = "CHAT"
            if searchResult.type == .bot || searchResult.type == .message {
                tmpType = "CHAT"
            } else if searchResult.type == .channel {
                tmpType = "CHANNEL"
            } else if  searchResult.type == .group {
                tmpType = "GROUP"
                
            } else {
                tmpType = "CHAT"
                
            }
            IGHelperChatOpener.manageOpenChatOrProfile(viewController: self, usernameType: IGPClientSearchUsernameResponse.IGPResult.IGPType(rawValue: type)!, user: searchResult.user, room: room,roomType: tmpType)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.findResult[indexPath.row].isHeader {
            return 30.0
        }
        return 70.0
    }
    
}



