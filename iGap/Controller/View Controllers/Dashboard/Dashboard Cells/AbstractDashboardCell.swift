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
import IGProtoBuff

class AbstractDashboardCell: UICollectionViewCell {

    var dashboardAbs: [IGPDiscoveryField]!
    var mainViewAbs:  UIView?
    var img1Abs: UIImageView?
    var img2Abs: UIImageView?
    var img3Abs: UIImageView?
    var view1Abs: UIView?
    var view2Abs: UIView?
    var view3Abs: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func initView(dashboard: [IGPDiscoveryField]){
        self.dashboardAbs = dashboard
        if img1Abs != nil {
            customizeImage(img: img1Abs!, view: view1Abs)
            if dashboard.count > 0, let url = URL(string: dashboard[0].igpImageurl) {
                img1Abs?.sd_setImage(with: url, completed: nil)
            }
        }
        
        if img2Abs != nil {
            customizeImage(img: img2Abs!, view: view2Abs)
            if dashboard.count > 1, let url = URL(string: dashboard[1].igpImageurl) {
                img2Abs?.sd_setImage(with: url, completed: nil)
            }
        }
        
        if img3Abs != nil {
            customizeImage(img: img3Abs!, view: view3Abs)
            if dashboard.count > 2, let url = URL(string: dashboard[2].igpImageurl) {
                img3Abs?.sd_setImage(with: url, completed: nil)
            }
        }
        
        manageGesture()
    }
    
    private func customizeImage(img: UIImageView, view: UIView?){
        view?.layer.masksToBounds = false
        view?.layer.cornerRadius = IGDashboardViewController.itemCorner
        view?.layer.shadowOffset = CGSize(width: 2, height: 2)
        view?.layer.shadowRadius = 3
        view?.layer.shadowColor = UIColor.gray.cgColor
        view?.layer.shadowOpacity = 1
        
        img.layer.cornerRadius = IGDashboardViewController.itemCorner
        img.layer.masksToBounds = true
    }
    
    /**********************************************************************/
    /************************* Gesture Recognizer *************************/
    
    private func manageGesture(){
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapImage1(_:)))
        img1Abs?.addGestureRecognizer(tap1)
        img1Abs?.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTapImage2(_:)))
        img2Abs?.addGestureRecognizer(tap2)
        img2Abs?.isUserInteractionEnabled = true
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(didTapImage3(_:)))
        img3Abs?.addGestureRecognizer(tap3)
        img3Abs?.isUserInteractionEnabled = true
    }
    
    @objc func didTapImage1(_ gestureRecognizer: UITapGestureRecognizer){
        if self.dashboardAbs.count > 0 {
            actionManager(discoveryInfo: self.dashboardAbs[0])
        }
    }
    
    @objc func didTapImage2(_ gestureRecognizer: UITapGestureRecognizer){
        if self.dashboardAbs.count > 1 {
            actionManager(discoveryInfo: self.dashboardAbs[1])
        }
    }
    
    @objc func didTapImage3(_ gestureRecognizer: UITapGestureRecognizer){
        if self.dashboardAbs.count > 2 {
            actionManager(discoveryInfo: self.dashboardAbs[2])
        }
    }
    
    
    /**********************************************************************/
    /*************************** Action Manager ***************************/
    
    private func actionManager(discoveryInfo: IGPDiscoveryField){
        
        IGClientSetDiscoveryItemClickRequest.sendRequest(itemId: discoveryInfo.igpID)
        
        let actionType = discoveryInfo.igpActiontype
        
        switch actionType {
        case .none:
            return
            
        case .joinLink:
            IGHelperJoin.getInstance(viewController: UIApplication.topViewController()!).requestToCheckInvitedLink(invitedLink: discoveryInfo.igpValue)
            return
            
        case .usernameLink:
            IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: UIApplication.topViewController()!, username: discoveryInfo.igpValue, joinToRoom: false)
            return
            
        case .webLink:
            IGHelperOpenLink.openLink(urlString: discoveryInfo.igpValue, navigationController: UIApplication.topViewController()!.navigationController!, forceOpenInApp: true)
            return
            
        case .webViewLink:
            let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
            iGapBrowser.url = discoveryInfo.igpValue
            UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
            return
            
        case .showAlert:
            let alert = UIAlertController(title: nil, message: discoveryInfo.igpValue, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in })
            alert.addAction(okAction)
            UIApplication.topViewController()!.present(alert, animated: true, completion: nil)
            return
            
        case .page:
            let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            dashboard.pageId = Int32(discoveryInfo.igpValue)!
            UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
            return
            
        case .financialMenu:
            IGHelperFinancial.getInstance(viewController: UIApplication.topViewController()!).manageFinancialServiceChoose()
            return
            
        case .topupMenu:
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceCharge") as! IGFinancialServiceCharge
            UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
            return
            
        case .billMenu:
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = false
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
            return
            
        case .trafficBillMenu:
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = true
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
            return
            
        case .mobileBillMenu:
            IGFinancialServiceBillingInquiry.isMobile = true
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
            UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
            return
            
        case .phoneBillMenu:
            IGFinancialServiceBillingInquiry.isMobile = false
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
            UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
            return
            
        case .nearbyMenu:
            IGDashboardViewController.discoveryObserver?.onNearbyClick()
            return
            
        case .call:
            if let url = NSURL(string: "tel://\(discoveryInfo.igpValue)"), UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.openURL(url as URL)
            }
            return
            
        case .stickerShop:
            if #available(iOS 10.0, *) {
                let stickerShop = IGStickerViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                stickerShop.stickerPageType = StickerPageType.ADD_REMOVE
                UIApplication.topViewController()?.navigationController!.pushViewController(stickerShop, animated: true)
            }
            return
            
        default:
            return
        }
    }
}
