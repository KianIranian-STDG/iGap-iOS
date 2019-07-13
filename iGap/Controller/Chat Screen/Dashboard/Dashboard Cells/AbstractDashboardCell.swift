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
import MBProgressHUD


class AbstractDashboardCell: UICollectionViewCell {
    
    var btnCheckMark: UIButton!
    var item : Int = 0
    
    var dashboardAbs: [IGPDiscoveryField]!
    var dashboardAbsPoll: [IGPPollField]!
    var dashboardIGPPoll: [IGPPoll]!
    var mainViewAbs:  UIView?
    var img1Abs: IGImageView?
    var img2Abs: IGImageView?
    var img3Abs: IGImageView?
    var view1Abs: UIView?
    var view2Abs: UIView?
    var view3Abs: UIView?
    var numberOfChecked : Int = 0
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
    
    public func initViewPoll(dashboard: [IGPPollField]){
        self.dashboardAbsPoll = dashboard
        if img1Abs != nil {
            customizeImage(img: img1Abs!, view: view1Abs)
            if dashboard.count > 0, let url = URL(string: dashboard[0].igpImageurl) {
                img1Abs?.sd_setImage(with: url, completed: nil)
                if dashboardAbsPoll[0].igpClicked {
                    self.numberOfChecked += 1
                    self.showCheckMark(imageView: self.img1Abs)
                }
            }
            //            if dashboard.count > 0,  (dashboard[0].igpClicked) {
            //                showCheckMark()
            //            }
            
            
            
        }
        
        if img2Abs != nil {
            customizeImage(img: img2Abs!, view: view2Abs)
            if dashboard.count > 1, let url = URL(string: dashboard[1].igpImageurl) {
                img2Abs?.sd_setImage(with: url, completed: nil)
                if dashboardAbsPoll[1].igpClicked {
                    self.numberOfChecked += 1
                    self.showCheckMark(imageView: self.img2Abs)
                }
            }
            //            if dashboard.count > 1,  (dashboard[1].igpClicked) {
            //                showCheckMark()
            //            }
        }
        
        if img3Abs != nil {
            customizeImage(img: img3Abs!, view: view3Abs)
            if dashboard.count > 2, let url = URL(string: dashboard[2].igpImageurl) {
                img3Abs?.sd_setImage(with: url, completed: nil)
                if dashboardAbsPoll[2].igpClicked {
                    self.numberOfChecked += 1
                    self.showCheckMark(imageView: self.img3Abs)
                }
            }
            //            if dashboard.count > 2,  (dashboard[2].igpClicked) {
            //                showCheckMark()
            //            }
        }
        
        
        manageGesture()
    }
    
    private func customizeImage(img: UIImageView, view: UIView?){
        view?.layer.masksToBounds = false
        view?.layer.cornerRadius = IGDashboardViewController.itemCorner
        view?.layer.shadowOffset = CGSize(width: 1, height: 1)
        view?.layer.shadowRadius = 1
        view?.layer.shadowColor = UIColor.gray.cgColor
        view?.layer.shadowOpacity = 0.4
        
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
    //Tap on First - second and third cell
    @objc func didTapImage1(_ gestureRecognizer: UITapGestureRecognizer){
        
        if IGGlobal.shouldShowChart {
            if self.dashboardAbsPoll.count > 0 {
                actionManagerPoll(pollInfo: self.dashboardAbsPoll![0],item : 0)
            }
            
        }
        else {
            if self.dashboardAbs.count > 0 {
                actionManager(discoveryInfo: self.dashboardAbs[0])
            }
            
        }
    }
    
    @objc func didTapImage2(_ gestureRecognizer: UITapGestureRecognizer){
        if IGGlobal.shouldShowChart {
            if self.dashboardAbsPoll.count > 1 {
                actionManagerPoll(pollInfo: self.dashboardAbsPoll![1],item : 1)
            }
            
        }
        else {
            if self.dashboardAbs.count > 1 {
                actionManager(discoveryInfo: self.dashboardAbs[1])
            }
            
        }
    }
    
    @objc func didTapImage3(_ gestureRecognizer: UITapGestureRecognizer){
        if IGGlobal.shouldShowChart {
            if self.dashboardAbsPoll.count > 2 {
                actionManagerPoll(pollInfo: self.dashboardAbsPoll![2],item : 2)
            }
            
        }
        else {
            if self.dashboardAbs.count > 2 {
                actionManager(discoveryInfo: self.dashboardAbs[2])
            }
            
        }
    }
    
    //Carpino Agrement
    func carpinoAggrement(agrementSlug: String!,itemID: Int32!,url : String!) {
        IGInfoPageRequest.Generator.generate(pageID: agrementSlug).success { (responseProto) in
            DispatchQueue.main.async {
                switch responseProto {
                case let pageInfoResponse as IGPInfoPageResponse:
                    let body = IGInfoPageRequest.Handler.interpret(response: pageInfoResponse)
                    let htmlString = "<font face='IRANSans' size='3'>" + "<p style='text-align:center'>" + body + "</p>"
                    let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
                    iGapBrowser.itemID = itemID
                    iGapBrowser.url = url
                    iGapBrowser.htmlString = htmlString
                    UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                    return
                    
                default:
                    break
                }
            }
            }.error { (errorCode, waitTime) in
            }.send()
    }
    //
    func showCheckMark(imageView: IGImageView?) {
        btnCheckMark = UIButton()
        btnCheckMark.setTitle("", for: .normal)
        btnCheckMark.titleLabel?.font = UIFont.iGapFonticoNew(ofSize: 25)
        btnCheckMark.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        btnCheckMark.layer.cornerRadius = IGDashboardViewController.itemCorner
        
        imageView!.addSubview(btnCheckMark)
        btnCheckMark?.snp.makeConstraints { (make) in
            make.width.equalTo((imageView?.frame.width)!)
            make.height.equalTo((imageView?.frame.height)!)
            make.centerX.equalTo(imageView!.snp.centerX)
            make.centerY.equalTo(imageView!.snp.centerY)
        }
    }
    /**********************************************************************/
    /*************************** Action Manager ***************************/
    private func actionManagerPoll(pollInfo: IGPPollField,item : Int!){
        
        IGGlobal.shouldShowChart = true
        
        print(dashboardIGPPoll)
        
        if pollInfo.igpClicked {
            IGHelperAlert.shared.showAlert(message: "MSG_U_HAVE_ALREADY_VOTED".localizedNew)
        }
        else {
            if pollInfo.igpClickable {
//                IGPClientSetPollItemClickRequest.sendRequest(itemId: pollInfo.igpID)
                self.isUserInteractionEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isUserInteractionEnabled = true
                }
                switch item {
                case 0 :
                    showCheckMark(imageView: self.img1Abs)
                    self.numberOfChecked += 1
                    
                    break
                case 1:
                    showCheckMark(imageView: self.img2Abs)
                    self.numberOfChecked += 1
                    
                    
                    break
                case 2 :
                    showCheckMark(imageView: self.img3Abs)
                    self.numberOfChecked += 1
                    
                    break
                default :
                    break
                }
            }
        }
        
        
    }
    
    private func actionManager(discoveryInfo: IGPDiscoveryField){
        IGGlobal.shouldShowChart = false
        IGClientSetDiscoveryItemClickRequest.sendRequest(itemId: discoveryInfo.igpID)
        
        let actionType = discoveryInfo.igpActiontype
        let valueType = String(discoveryInfo.igpValue)
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isUserInteractionEnabled = true
            
        }
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
            
            //            showCheckMark()
            
            IGHelperOpenLink.openLink(urlString: discoveryInfo.igpValue, navigationController: UIApplication.topViewController()!.navigationController!, forceOpenInApp: true)
            return
            
        case .webViewLink:
            let t = discoveryInfo.igpAgreementSlug
            let b = discoveryInfo.igpAgreement
            if !(t == "") {
                if (b == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
                    iGapBrowser.url = discoveryInfo.igpValue
                    iGapBrowser.htmlString = nil
                    UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                    return
                    
                }
            } else {
                return
            }
        case .showAlert:
            IGHelperAlert.shared.showAlert(message: discoveryInfo.igpValue)
            return
            
        case .page:
            let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            dashboard.pageId = Int32(discoveryInfo.igpValue)!
            UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
            return
        //Pull actions
        case .poll:
            let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            dashboard.pageId = Int32(discoveryInfo.igpValue)!
            IGGlobal.shouldShowChart = true
            UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
            return
        // End
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
            messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: discoveryInfo.igpValue)
            UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
            return
            
        case .trafficBillMenu:
            IGFinancialServiceBill.BillInfo = nil
            IGFinancialServiceBill.isTrafficOffenses = true
            let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
            let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
            messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: discoveryInfo.igpValue)
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
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
            return
            
        case .stickerShop:
            if #available(iOS 10.0, *) {
                IGTabBarStickerController.openStickerCategories()
            }
            return
            
        case .ivand:
            let scanner = IGScoreViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            UIApplication.topViewController()!.navigationController!.pushViewController(scanner, animated:true)
            return
            
        case .ivandqr:
            let scanner = IGSettingQrScannerViewController.instantiateFromAppStroryboard(appStoryboard: .Setting)
            scanner.scannerPageType = .IVandScore
            UIApplication.topViewController()!.navigationController!.pushViewController(scanner, animated:true)
            return
            
        case .ivandlist:
            let scoreHistory = IGScoreHistoryViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            UIApplication.topViewController()!.navigationController!.pushViewController(scoreHistory, animated:true)
            return
            
        case .ivandscore:
            IGUserIVandSetActivityRequest.sendRequest(plancode: discoveryInfo.igpValue)
            return
            
        case .cardToCard:
            IGHelperFinancial.shared.sendCardToCardRequest()
            return
            
            
        case .payDirect:
            IGHelperAlert.shared.showAlert(data: discoveryInfo.igpValue)
        case .walletMenu:
            switch valueType {
            case "QR_USER_WALLET" :
                let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)
                let qrVC: QRMainTabbarController? = (storyboard.instantiateViewController(withIdentifier: "qrMainTabbar") as! QRMainTabbarController)
                UIApplication.topViewController()!.navigationController!.pushViewController(qrVC!, animated: true)
                
                break
                
            case "QR_MERCHANT_WALLET" :
                break
            default :
                let vc = UIStoryboard.init(name: "wallet", bundle: Bundle.main).instantiateViewController(withIdentifier: "packetTableViewController") as? packetTableViewController
                UIApplication.topViewController()!.navigationController!.pushViewController(vc!, animated: true)
                
                break
            }
        default:
            return
        }
    }
}
