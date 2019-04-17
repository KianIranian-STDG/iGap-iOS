//
//  SMVersionViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/9/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import SafariServices

/// Subclass of SMSettingTableViewController
class SMVersionViewController: SMSettingTableViewController {

    /// Register exit type cell to load custom cell
	/// If new update is available one cell shows to update app
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExitItem")
//        tableView.allowsSelection = false
        tableView.delegate = self
		self.SMTitle = "setting.version.title".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if SMUserManager.isUpdateAvailable {
            return 2
		}
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell  = tableView.dequeueReusableCell(withIdentifier: "ExitItem")
        cell?.selectionStyle = .none
		// Show logo, version and build number of current app
		if indexPath.section == 0 {
            let logo = UIImageView(image: UIImage(named: "farsi_logo_without_box"))
            logo.frame = CGRect(x: 0, y: 20, width: tableView.bounds.width, height: 80)
            logo.contentMode = .scaleAspectFit
            cell?.addSubview(logo)

            let label = UILabel(frame: CGRect(x: 0, y: 110, width: tableView.bounds.width, height: 40))
            label.font = SMFonts.IranYekanBold(15)
            label.textAlignment = .center
            label.text = "\("V".localized): \(SMConstants.version.inLocalizedLanguage()) - \("B".localized): \(SMConstants.build.inLocalizedLanguage())"
            cell?.addSubview(label)
		}
		else if indexPath.section == 1 {
			// If new update is available this row shows to rout to update link
			let label = UILabel(frame: CGRect(x: 0, y: 10, width: tableView.bounds.width, height: 40))
			label.font = SMFonts.IranYekanBold(15)
			label.textAlignment = .center
			label.textColor = #colorLiteral(red: 1, green: 0.4274509804, blue: 0, alpha: 1)
			label.text = "appUpdate".localized
			cell?.addSubview(label)
		}

		return cell!
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return 160
		}
		return 50
	}
	
	/// Update action page
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			
			guard let url = URL(string: "https://paygear.ir/get") else {
				return //be safe
			}
//			let svc = SFSafariViewController(url: url)
//			self.present(svc, animated: true, completion: nil)
            UIApplication.shared.open(url)
		}
	}
	
}
