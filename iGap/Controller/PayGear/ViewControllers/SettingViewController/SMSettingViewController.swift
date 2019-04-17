//
//  SMSettingViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/8/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Subclass of Setting table view controller, setups navigation and setting items
class SMSettingViewController: SMSettingTableViewController {
	
	
	
//	@IBOutlet var tableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		readSettingPlist()
		self.SMTitle = "setting.main.title".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	
	// MARK: - Read Setting
	
	/// The setting items are loading from Setting.stringsdict file
	/// The structure of this file is an array contains items object
	/// Items object is a two dimensional array
	/// Sub Items are a dictionary by this key value:
	/// - title (String), target(String), action(string), target(String), icon(string), subItems(array of sub Item)
	/// 	- title: language key of title
	/// 	- action: define what type of action this item does, openURL, openPage or doAction(exit item)
	/// 	- target: viewController or url or do defined action (according action key)
	/// 	- icon: name of item icon
	/// 	- subItems: an array of items if row must show some other items on sub view controller
	func readSettingPlist() {
		
		var settingDic: NSDictionary?
		if let path = Bundle.main.path(forResource: "Setting", ofType: "stringsdict") {
			settingDic = NSDictionary(contentsOfFile: path)
		}
		if let dict = settingDic {
			// Use your dict here
			if let array = dict["Setting"] {
				self.settingItems = array as! Array<Array>
			}
		}
	}
}
