//
//  SMWithDrawTabStripController.swift
//  PayGear
//
//  Created by amir soltani on 4/29/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import Foundation
import XLPagerTabStrip


class SMWithDrawTabStripController: ButtonBarPagerTabStripViewController {
	
	var merchant : SMMerchant!
	var sourceCard: SMCard!
    @IBOutlet weak var backBarView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var balance = "0".inLocalizedLanguage()
    var finishDelegate : HandleDefaultCard?
    open override func viewDidLoad() {
		
		self.SMTitle = "paygear.withdraw".localized

		if merchant != nil {
			self.SMTitle = "\("paygear.withdraw".localized) \(String(describing: merchant.name!))"
		}
        let gradient = CAGradientLayer(frame: backBarView.bounds, colors: [UIColor(netHex: 0x2196f3), UIColor(netHex: 0x0d47a1)])
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        backBarView.layer.insertSublayer(gradient, at: 0)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.white
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemFont = SMFonts.IranYekanBold(12)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarItemLeftRightMargin = 0
        
        self.view.layoutMargins = .zero
		
       
        containerView.isScrollEnabled = true
        moveToViewController(at: 0)
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
       
		if #available(iOS 11.0, *) {
			// nothing to do.
		} else {
			automaticallyAdjustsScrollViewInsets = false
		}
        super.viewDidLoad()
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.white.withAlphaComponent(0.3)
            newCell?.label.textColor = .white
           
        }
        
    }
    
   
    
    override func viewDidLayoutSubviews() {
       // super.viewDidLayoutSubviews()
        if topConstraint.constant == 44 {
        topConstraint.constant = 44 + UIApplication.shared.statusBarFrame.height
            buttonBarView.selectedBar.frame.size.width = (buttonBarView.cellForItem(at: IndexPath.init(row: 0, section: 0))?.frame.width)!
            buttonBarView.selectedBar.frame.origin.x = (buttonBarView.cellForItem(at: IndexPath.init(row: 0, section: 0))?.frame.origin.x)!
        }

    }
    
    
   
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = SMFastWithDrawViewController(itemInfo: IndicatorInfo(title: "fast".localized,balance: self.balance))
        child_1.finishDelegate = finishDelegate
        child_1.merchant = merchant
        child_1.sourceCard = sourceCard
        let child_2 = SMNormalWithDrawViewController(itemInfo: IndicatorInfo(title: "normal".localized,balance: self.balance))
        child_2.finishDelegate = finishDelegate
        child_2.merchant = merchant
        child_2.sourceCard = sourceCard
        let child_3 = SMMerchantWithDrawViewController(itemInfo: IndicatorInfo(title: "adminCashOut".localized,balance: self.balance))
        child_3.finishDelegate = finishDelegate
        child_3.merchant = merchant
        child_3.sourceCard = sourceCard
        
        
        if merchant != nil {
            return [child_1, child_2,child_3]
        }
        else{
            return [child_1, child_2]
        }
        
    }
}

    
    
    

