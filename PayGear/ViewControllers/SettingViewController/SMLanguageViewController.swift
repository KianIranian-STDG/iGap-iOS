//
//  SMLanguageViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 5/29/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

/// This class changes the language of application, currently English and Persian is supported
class SMLanguageViewController: UIViewController {

	@IBOutlet var infoLbl: UILabel!
	
	/// Initial view
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let gradientColors : [UIColor] = [UIColor(netHex: 0x2196f3), UIColor(netHex: 0x0d47a1)]
		let gradient = CAGradientLayer(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
			,colors : gradientColors)
		gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
		self.view.layer.insertSublayer(gradient, below: nil)
		
		infoLbl!.text = "choose.language".localized
		
		/*
		SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue ?
		SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Base.rawValue) :
		SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.English.rawValue)
		*/
    }

	/// Persian language is selected
	/// call change language parameter
	///
	/// - Parameter sender: Selected button
	@IBAction func persianLanguageDidSelect(_ sender: Any) {
		
		//show popup to confirm changing language
		SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Base.rawValue)
		nextActions()
	}
	
	/// English language is selected
	/// call change language parameter
	///
	/// - Parameter sender: Selected button
	@IBAction func englishLanguageDidSelect(_ sender: Any) {
		
		//show popup to confirm changing language
		SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.English.rawValue)
		nextActions()
	}
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	/// After changing language, app is restarted to load all base views by new langauge
	/// This page is called from settignand start up page;
	/// next action is handleing from which page is choosed language
	func nextActions() {
		
		if SMUserManager.profileLevelsCompleted == SMUserManager.CurrentStep.Main.rawValue{
			// Reload app and start from wallet view
			let navigation = SMNavigationController.shared
			navigation.navigationBar.isHidden = false
			navigation.style = .SMMainPageStyle
			navigation.setRootViewController(page: .Main)
			

			SMUserManager.saveDataToKeyChain()
			SMInitialInfos.updateBaseInfoFromServer()
           
		}
		else {
			//show Intro pages
			SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Intro.rawValue
			SMUserManager.saveDataToKeyChain()
			let navigation = SMNavigationController.shared
			navigation.style = .SMSignupStyle
			navigation.setRootViewController(page: .IntroPage)
			
		}
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
