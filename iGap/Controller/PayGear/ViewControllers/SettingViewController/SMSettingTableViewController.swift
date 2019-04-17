//
//  SMSettingTableViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import  SafariServices

/// The setting class
/// Handleing table view load only
@objc class SMSettingTableViewController: UITableViewController {

	var settingItems = [[]]
	
	required override init( style: UITableView.Style) {
		
		self.settingItems = [[]]
		super.init(style: style)

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
    /// Settup table view and load from storyboard
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		UIApplication.shared.userInterfaceLayoutDirection = .leftToRight
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		tableView.register(UINib(nibName: "SMSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingItem")
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExitItem")
		

    }

	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingItems[section].count
    }

	/// Tow type cells are loading, one exit style button and other setting item
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let currentSectionArray = settingItems[indexPath.section]
		let item = currentSectionArray[indexPath.row]
		let currentItem = item as! Dictionary<String,Any>
		
		if self.isKind(of: SMSettingViewController.self), indexPath.section == settingItems.count - 1  {
			
			let cell  = tableView.dequeueReusableCell(withIdentifier: "ExitItem")
			cell?.textLabel?.font = SMFonts.IranYekanBold(14)
			cell?.textLabel?.textColor = UIColor(netHex: 0xf44336)
			cell?.textLabel?.text = String(describing: currentItem["title"]!).localized
			cell?.textLabel?.textAlignment = .center
			
			return cell!
		}
	
 			let cell   = tableView.dequeueReusableCell(withIdentifier: "SettingItem") as! SMSettingTableViewCell
			cell.semanticContentAttribute = .forceLeftToRight
			cell.titleLbl.text = String(describing:currentItem["title"]!).localized
		if let imageName = currentItem["icon"] {
			cell.titleIcon.image = UIImage(named: String(describing:imageName))
		}
		if  (currentItem["title"]! as! String) == "appVersion", SMUserManager.isUpdateAvailable  {
			cell.titleLbl.textColor = UIColor(netHex: 0xff6d00)
			cell.titleLbl.text = "\(String(describing:currentItem["title"]!).localized) (\("appUpdate".localized))"
			cell.titleIcon.image = UIImage(named: String(describing:"update"))
		}
	
			return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	///Setting item has three type of actions
	/// - Actions:
	/// 	- 1: exit action which shows confirm exit button
	///		- 2: open url which opens a defined url on SafariWebView
	///     - 3: open page which open a view controller to do or show some other action
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		//select cell
		let currentSectionArray = settingItems[indexPath.section]
		let item = currentSectionArray[indexPath.row]
		let currentItem = item as! Dictionary<String,Any>
		
		let actionSource = String(describing: currentItem["target"]!)
		
		if String(describing: currentItem["action"]!) == "openURL"  {
			
			guard let url = URL(string: actionSource) else {
				return //be safe
			}
			let svc = SFSafariViewController(url: url)
			self.present(svc, animated: true, completion: nil)
		}
		else if String(describing: currentItem["action"]!) == "openPage" {
			
			if actionSource == "SMLanguageViewController" {
				
				let vc = SMMainTabBarController.packetTabNavigationController.findViewController(page: .ChooseLanguage) as! SMLanguageViewController
				SMMainTabBarController.packetTabNavigationController.pushViewController(vc, animated: true)
				
			}
			else {
				let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
				let aClass = NSClassFromString("\(appName).\(actionSource)") as! SMSettingTableViewController.Type
				let viewController = aClass.init(style: .grouped)
				
				viewController.settingItems[0] = currentItem["subItems"]! as! Array<Any>
				SMMainTabBarController.packetTabNavigationController.pushViewController(viewController, animated: true)
			}
			
		}
		else if String(describing: currentItem["action"]!) == "doAction" {
			
            if actionSource == "logout" {
                //logout app
                
                SMLoading.shared.showNormalDialog(viewController: self, height: 180, isleftButtonEnabled: true, title: "logout.title".localized, message: "logout.message".localized, leftButtonTitle: "logout.cancel.btn".localized, rightButtonTitle:"logout.confirm.btn".localized , yesPressed: {obj in
               
                SMUserManager.logout()
//              show signup page
                let navigation = SMNavigationController.shared
                navigation.navigationBar.isHidden = false
                navigation.style = .SMSignupStyle
                navigation.setRootViewController(page: .SignupPhonePage)
                })
            }
		}
		
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 10.000
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 10.000
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
