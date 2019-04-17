//
//  SMLoading.swift
//  PayGear
//
//  Created by amir soltani on 4/17/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import Presentr

class SMLoading {
    
    public static var shared:SMLoading = SMLoading()
    
    var presenter: Presentr?
    
    static var loadingViewPage: UIView?
    static var fullPageLoading : UIView?
//	static var toastView : UIView?
	
    static func showFullPageLoading(viewcontroller: UIViewController,text: String? = nil) {
		
        fullPageLoading = UIView(frame: viewcontroller.view.bounds)
//        fullPageLoading!.backgroundColor = SMColor.PrimaryColor.withAlphaComponent(0.9)
        
        let loading = UIActivityIndicatorView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.style = .whiteLarge
        loading.startAnimating()
        fullPageLoading!.addSubview(loading)
        
        loading.centerXAnchor.constraint(equalTo: fullPageLoading!.centerXAnchor).isActive = true
        loading.centerYAnchor.constraint(equalTo: fullPageLoading!.centerYAnchor).isActive = true
        
        if text != nil {
            let label = UILabel()
            label.textColor = UIColor.white
//            label.font = SMFonts.IranYekanBold(13)
            label.text = text
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            fullPageLoading!.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: loading.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: loading.bottomAnchor, constant: 20).isActive = true
            label.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        }
        
        
        DispatchQueue.main.async {
			if !(fullPageLoading?.isDescendant(of: viewcontroller.view))! {
				viewcontroller.view.addSubview(fullPageLoading!)
			}
		}
    }
    
	static func hideFullPageLoading(completion: SimpleCallBack? = nil) {
		DispatchQueue.main.async {
			if let loadingView =  self.fullPageLoading {
				loadingView.removeFromSuperview()
			}
		}
	}
    
	
	static func showToast(viewcontroller: UIViewController,text: String? = "") {

		var topPadding: CGFloat = 0.0
		if #available(iOS 11.0, *) {
			let window = UIApplication.shared.keyWindow
			topPadding = /*(window?.safeAreaInsets.top)! +*/ viewcontroller.view.safeAreaLayoutGuide.layoutFrame.origin.y
//			let bottomPadding = window?.safeAreaInsets.bottom
		}
		else {
			topPadding = 64
			
		}

		let toastView = UIView(frame: CGRect(x: 0, y: topPadding, width: UIScreen.main.bounds.width, height: 0))
		toastView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
		toastView.autoresizesSubviews = true
		
		let toastLbl = UILabel(frame: CGRect(x: 10, y: 1, width: UIScreen.main.bounds.width - 20, height: 21))
//        toastLbl.font = SMFonts.IranYekanRegular(13)
//        toastLbl.textAlignment = SMDirection.TextAlignment()
		toastLbl.textColor = .white
		toastLbl.text = text?.localized
		
		toastView.addSubview(toastLbl)
		if #available(iOS 11.0, *) {
			viewcontroller.view.addSubview(toastView)
		}
		else {
			UIApplication.shared.keyWindow?.addSubview(toastView)
		}

//		UIApplication.shared.keyWindow?.insertSubview(toastView, aboveSubview: (UIApplication.shared.keyWindow?.subviews.last)!)//(toastView)
		DispatchQueue.main.async {

				UIView.animate(withDuration: 0.5, animations: {
					toastView.frame.size.height = 23

				}, completion: { (true) in
					UIView.animate(withDuration: 0.5, delay: 2.0, options: .transitionFlipFromBottom, animations: {
						toastView.frame.size.height = 0
						toastLbl.frame.size.height = 0
						
					}, completion: { (true) in
						toastView.removeFromSuperview()
					})
				})
		}
	}
	
    static func showLoadingPage(viewcontroller: UIViewController,text: String? = "loading.text".localized) {
		
		self.hideLoadingPage {
			loadingViewPage = UIView(frame : UIScreen.main.bounds)
			loadingViewPage!.backgroundColor = UIColor.clear
			
//			let loadingView = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2 - 60, y: UIScreen.main.bounds.height/2 - 60, width: 120, height: 120))
			let loadingView = UIView(frame: CGRect(x: viewcontroller.view.bounds.width/2 - 60, y: viewcontroller.view.bounds.height/2 - 60, width: 120, height: 120))

			loadingView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
			loadingView.layer.cornerRadius = 6.0
			//loadingView.clipsToBounds = true
			loadingViewPage!.addSubview(loadingView)
			
			let loadingActivity = UIActivityIndicatorView()
			loadingActivity.frame.origin = CGPoint(x: loadingView.frame.width/2 - loadingActivity.frame.width/2, y: loadingView.frame.height/2 - loadingActivity.frame.height/2)
			loadingActivity.style = .whiteLarge
			loadingActivity.startAnimating()
			
			loadingView.addSubview(loadingActivity)
			
			if text != nil {
				let label = UILabel()
				label.textColor = UIColor.white
//                label.font = SMFonts.IranYekanBold(13.3)
				label.text = text
				label.textAlignment = .center
				label.translatesAutoresizingMaskIntoConstraints = false
				loadingView.addSubview(label)
				
				label.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
				label.topAnchor.constraint(equalTo: loadingActivity.bottomAnchor, constant: 30).isActive = true
				label.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
			}
			
			DispatchQueue.main.async {
				if !(loadingViewPage?.isDescendant(of: viewcontroller.view))! {
					viewcontroller.view.addSubview(loadingViewPage!)
				}
			}
			
		}
    }
    
    static func hideLoadingPage(completion: SimpleCallBack? = nil) {
		DispatchQueue.main.async {
			if let loadingView =  self.loadingViewPage {
				loadingView.removeFromSuperview()
				if let com = completion {
					com()
				}
			}
			else {
				if let com = completion {
					com()
				}
			}
		}
    }
    
    
    func presenter(width: Float = 285, height: Float = 292) -> Presentr {
        let width = ModalSize.custom(size: width)
        let height = ModalSize.custom(size: height)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .crossDissolve
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        customPresenter.backgroundColor = UIColor(netHex: 0x1D5CEB)
        customPresenter.backgroundOpacity = 0.2
        self.presenter = customPresenter
        return customPresenter
}
  
    
    
    func showNormalDialog(viewController:UIViewController, height: Float ,isleftButtonEnabled : Bool? = true ,title:String? ,message:String? ,leftButtonTitle : String? = "no".localized ,rightButtonTitle :String? = "yes".localized , yesPressed: CallBack? = nil, noPressed: SimpleCallBack? = nil){
        
        let alertView = self.findViewController(page: .NormalAlert) as! SMNormalAlertViewController
        alertView.dialogT = title
        alertView.leftButtonEnable = isleftButtonEnabled
        
        alertView.message = message
        
        alertView.leftButtonTitle = leftButtonTitle
        alertView.leftButtonAction = noPressed
        
        alertView.rightButtonTitle = rightButtonTitle
        alertView.rightButtonAction = yesPressed
		

		let customType = PresentationType.custom(width: ModalSize.custom(size: 285), height: ModalSize.custom(size: height), center: ModalCenterPosition.center)
		self.presenter = Presentr(presentationType: customType)
		self.presenter?.dismissOnTap = false
        viewController.customPresentViewController(self.presenter!, viewController: alertView, animated: true, completion: nil)
		
    }
    
    func findViewController(page:SMPages) -> UIViewController {
        let identifier = page.rawValue.components(separatedBy: "@")[0]
        let nibName = page.rawValue.components(separatedBy: "@")[1]
        
        let story = UIStoryboard(name: nibName, bundle: self.nibBundle)
        
        return story.instantiateViewController(withIdentifier: identifier)
    }
    
}



