//
//  SMPrivacyViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// Subclass of SMSettingTableViewController, superclass handle show and action
class SMPrivacyViewController: SMSettingTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.SMTitle = "setting.privacy.title".localized
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
	
	
	
	
}
