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
import SwiftEventBus

class AbstractDashboardCell: UICollectionViewCell {

    var btnCheckMark: UIButton!
    var item : Int = 0
    var dashboardAbsPollMain: [IGPPollField]! = []
    var dashboardAbs: [IGPDiscoveryField]!
    var dashboardAbsPoll: [IGPPollField]!
    var dashboardIGPPoll: IGPClientGetPollResponse!
    var mainViewAbs:  UIView?
    var img1Abs: IGImageView?
    var img2Abs: IGImageView?
    var img3Abs: IGImageView?
    var view1Abs: UIView?
    var view2Abs: UIView?
    var view3Abs: UIView?
    var numberOfChecked : Int = 0
    
    private let lblStar: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.iGapFonticon(ofSize: 48)
        lbl.textColor = ThemeManager.currentTheme.iVandColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    private let lblYourScoreTitle: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.lightGray.withAlphaComponent(0.8)
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.YourScore.rawValue.localized
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    private let lblYourScore: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 15, weight: .bold)
        lbl.textColor = ThemeManager.currentTheme.iVandColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    private let viewSeparatorLine: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        vi.layer.cornerRadius = 10
        vi.clipsToBounds = true
        vi.translatesAutoresizingMaskIntoConstraints = false
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    private let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = IGStringsManager.IncreaseScore.rawValue.localized
        lbl.textColor = ThemeManager.currentTheme.iVandColor
        lbl.numberOfLines = 2
        lbl.font = UIFont.igFont(ofSize: 15, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CategoriesCounter = 0
    }
    
    public func initView(dashboard: [IGPDiscoveryField]){
        self.dashboardAbs = dashboard
        if img1Abs != nil {
            if dashboard[0].igpActiontype == IGPDiscoveryField.IGPButtonActionType.ivand {
                makeCreditCellView()
                img1Abs?.image = nil
                img1Abs = nil
                view1Abs?.backgroundColor = .clear

            } else {
                removeCreditCellView()
                customizeImage(img: img1Abs!, view: view1Abs)
                if dashboard.count > 0, let url = URL(string: dashboard[0].igpImageurl) {
                    img1Abs?.sd_setImage(with: url, completed: nil)
                }
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
                    IGGlobal.hideBarChart = false

                    self.showCheckMark(imageView: self.img1Abs)
                }
            }
        }
        
        if img2Abs != nil {
            customizeImage(img: img2Abs!, view: view2Abs)
            if dashboard.count > 1, let url = URL(string: dashboard[1].igpImageurl) {
                img2Abs?.sd_setImage(with: url, completed: nil)
                if dashboardAbsPoll[1].igpClicked {
                    self.numberOfChecked += 1
                    IGGlobal.hideBarChart = false

                    self.showCheckMark(imageView: self.img2Abs)
                }
            }
        }
        
        if img3Abs != nil {
            customizeImage(img: img3Abs!, view: view3Abs)
            if dashboard.count > 2, let url = URL(string: dashboard[2].igpImageurl) {
                img3Abs?.sd_setImage(with: url, completed: nil)
                if dashboardAbsPoll[2].igpClicked {
                    self.numberOfChecked += 1
                    IGGlobal.hideBarChart = false

                    self.showCheckMark(imageView: self.img3Abs)
                }
            }
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
        view?.backgroundColor = ThemeManager.currentTheme.DashboardCellBackgroundColor
        
        img.layer.cornerRadius = IGDashboardViewController.itemCorner
        img.layer.masksToBounds = true
        img.backgroundColor = UIColor.clear
    }
    
    /**********************************************************************/
    /************************* Gesture Recognizer *************************/
    
    private func manageGesture() {
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
    override func prepareForReuse() {
        super.prepareForReuse()
        img1Abs?.sd_cancelCurrentImageLoad()
        img1Abs = nil
        if self.btnCheckMark != nil {
            btnCheckMark.removeFromSuperview()
            self.btnCheckMark = nil
        }
    }
    //Carpino Agrement
    static func carpinoAggrement(agrementSlug: String!,itemID: Int32!,url : String!) {
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
                    iGapBrowser.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                    return
                    
                default:
                    break
                }
            }
            }.error { (errorCode, waitTime) in
            }.send()
    }
    
    func update(itemID: Int32) {
        let imageDataDict:[String: Int32] = ["id": itemID]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateChart"), object: nil, userInfo: imageDataDict)
    }
    
    func showCheckMark(imageView: IGImageView?) {
        if btnCheckMark == nil {
            btnCheckMark = UIButton()
            btnCheckMark.setTitle("", for: .normal)
            btnCheckMark.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
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
    }
    /**********************************************************************/
    /*************************** Action Manager ***************************/
    private func actionManagerPoll(pollInfo: IGPPollField, item : Int!) {
        
        IGGlobal.shouldShowChart = true
        
        if pollInfo.igpClicked {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AlreadyVoted.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
        } else {
            if pollInfo.igpClickable {
                IGPClientSetPollItemClickRequest.Generator.generate(itemId: pollInfo.igpID).success({ (protoResponse) in
                    DispatchQueue.main.async {
                        self.isUserInteractionEnabled = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isUserInteractionEnabled = true
                        }
                        switch item {
                        case 0 :
                            self.showCheckMark(imageView: self.img1Abs)
                            self.numberOfChecked += 1
                            self.update(itemID: IGGlobal.pageIDChartUpdate)
                            IGGlobal.hideBarChart = false
                            break
                            
                        case 1:
                            self.showCheckMark(imageView: self.img2Abs)
                            self.numberOfChecked += 1
                            IGGlobal.hideBarChart = false
                            self.update(itemID: IGGlobal.pageIDChartUpdate)
                            break
                            
                        case 2 :
                            self.showCheckMark(imageView: self.img3Abs)
                            self.numberOfChecked += 1
                            IGGlobal.hideBarChart = false
                            self.update(itemID: IGGlobal.pageIDChartUpdate)
                            break
                            
                        default :
                            break
                        }
                    }
                }).error ({ (errorCode, waitTime) in
                    print(errorCode)
                    
                    switch errorCode {
                    case .timeout:
                        IGPClientSetPollItemClickRequest.sendRequest(itemId: pollInfo.igpID)
                        break
                    case .selectIsBiggerThanMax:
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.MaximumPoll.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                        break
                    default:
                        break
                    }
                }).send()

            }
        }
        
    }
    
    private func actionManager(discoveryInfo: IGPDiscoveryField, deepLinkDiscoveryIds: [String] = []) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isUserInteractionEnabled = true
        }
        
        AbstractDashboardCell.dashboardCellActionManager(discoveryInfo: discoveryInfo, deepLinkDiscoveryIds: deepLinkDiscoveryIds)
    }
    
    static func dashboardCellActionManager(discoveryInfo: IGPDiscoveryField, deepLinkDiscoveryIds: [String] = []) {
        IGGlobal.shouldShowChart = false
        IGClientSetDiscoveryItemClickRequest.sendRequest(itemId: discoveryInfo.igpID)
        
        let actionType = discoveryInfo.igpActiontype
        let valueType = String(discoveryInfo.igpValue)
        let agreementSlug = discoveryInfo.igpAgreementSlug
        let agreementValue = discoveryInfo.igpAgreement
        let actionData = discoveryInfo.igpParam

        
        switch actionType {
        case .none:
            return
        case .inviteFriend :
        let vc = inviteFreindsVC.instantiateFromAppStroryboard(appStoryboard: .PhoneBook)
          vc.hidesBottomBarWhenPushed = true

            UIApplication.topViewController()?.navigationController!.pushViewController(vc, animated: true)
            

        case .joinLink:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGHelperJoin.getInstance().requestToCheckInvitedLink(invitedLink: discoveryInfo.igpValue)
                    return

                }
            } else {
                IGHelperJoin.getInstance().requestToCheckInvitedLink(invitedLink: discoveryInfo.igpValue)
                return

            }
            
        case .usernameLink:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGHelperChatOpener.checkUsernameAndOpenRoom(username: discoveryInfo.igpValue, joinToRoom: false)
                    return
                }
            } else {
                IGHelperChatOpener.checkUsernameAndOpenRoom(username: discoveryInfo.igpValue, joinToRoom: false)
                return
            }
            
        case .webLink:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGHelperOpenLink.openLink(urlString: discoveryInfo.igpValue, forceOpenInApp: true)
                    return
                }
            } else {
                IGHelperOpenLink.openLink(urlString: discoveryInfo.igpValue, forceOpenInApp: true)
                return
            }
            
        case .webViewLink:
            
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    if actionData == "" {
                        let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
                        iGapBrowser.url = discoveryInfo.igpValue
                        iGapBrowser.htmlString = nil
                        iGapBrowser.hidesBottomBarWhenPushed = true
                        UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                        return

                    } else {
                        
                        let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)

                        iGapBrowser.request = URLRequest(url: URL(string: discoveryInfo.igpValue)!)
                        iGapBrowser.htmlString = nil
                        iGapBrowser.isPost = true
                        iGapBrowser.param = actionData
                        iGapBrowser.hidesBottomBarWhenPushed = true
                        UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                        return

                        
                    }
                }
            } else {
                if actionData == "" {
                    let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
                    iGapBrowser.url = discoveryInfo.igpValue
                    iGapBrowser.htmlString = nil
                    iGapBrowser.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                    return
                    
                } else {
                    
                    let iGapBrowser = IGiGapBrowser.instantiateFromAppStroryboard(appStoryboard: .Main)
                    
                    iGapBrowser.request = URLRequest(url: URL(string: discoveryInfo.igpValue)!)
                    iGapBrowser.htmlString = nil
                    iGapBrowser.isPost = true
                    iGapBrowser.param = actionData
                    iGapBrowser.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(iGapBrowser, animated:true)
                    return
                }
                
            }
        case .showAlert:
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: nil, showIconView: false, showDoneButton: false, showCancelButton: true, message: discoveryInfo.igpValue, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            return
        //Hint :- favouriteChannels Handler
        case .favoriteChannel:
            
            if !(agreementSlug == "") && (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
            } else {
                if !discoveryInfo.igpValue.isEmpty {
                    let dashboard = IGFavouriteChannelsDashboardInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    dashboard.categoryId = discoveryInfo.igpValue
                    dashboard.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                } else {
                    let dashboard = IGFavouriteChannelsDashboardTableViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    dashboard.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated: true)
                }
            }
            return

        case .page:
            isDashboardInner = true

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)

                } else {
                    let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    dashboard.pageId = Int32(discoveryInfo.igpValue)!
                    if deepLinkDiscoveryIds.count > 0 {
                        dashboard.deepLinkDiscoveryIds = deepLinkDiscoveryIds
                    }
                    dashboard.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                    return
                }
            } else {
                
                // uncomment these
                let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                dashboard.pageId = Int32(discoveryInfo.igpValue)!
                if deepLinkDiscoveryIds.count > 0 {
                    dashboard.deepLinkDiscoveryIds = deepLinkDiscoveryIds
                }
                dashboard.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                return
            }
            
        //Pull actions
        case .poll:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    dashboard.pageId = Int32(discoveryInfo.igpValue)!
                    IGGlobal.shouldShowChart = true // value is false becoz the chart should not be shown in this page anymore instead it should be shown in pollResult page
                    dashboard.showChartOnly = false
                    dashboard.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                    return
                }
            } else {
                let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                dashboard.pageId = Int32(discoveryInfo.igpValue)!
                IGGlobal.shouldShowChart = true // value is false becoz the chart should not be shown in this page anymore instead it should be shown in pollResult page
                dashboard.showChartOnly = false

                dashboard.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                return
            }
        case .pollResult:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    dashboard.pageId = Int32(discoveryInfo.igpValue)!
                    IGGlobal.shouldShowChart = true
                    dashboard.showChartOnly = true

                    dashboard.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                    return
                }
            } else {
                let dashboard = IGDashboardViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                dashboard.pageId = Int32(discoveryInfo.igpValue)!
                IGGlobal.shouldShowChart = true
                dashboard.showChartOnly = true

                dashboard.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated:true)
                return
            }
        // End
            
        case .electricBillMenu:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)

                } else {
                    let vc = IGPSBillMainVC()
                    vc.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            } else {
                let vc = IGPSBillMainVC()
                vc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)

                return
            }
        case .financialMenu:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGHelperFinancial.getInstance(viewController: UIApplication.topViewController()!).manageFinancialServiceChoose()
                    return
                }
            } else {
                IGHelperFinancial.getInstance(viewController: UIApplication.topViewController()!).manageFinancialServiceChoose()
                return
            }
            
        case .topupMenu:
            
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let vc = IGPSTopUpMainVC()
                    vc.hidesBottomBarWhenPushed = true
                    vc.pageType = .TopUp
                    UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
                    return
                }
            } else {
                let vc = IGPSTopUpMainVC()
                vc.hidesBottomBarWhenPushed = true
                vc.pageType = .TopUp
                UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
                return
            }
        case .billMenu:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGFinancialServiceBill.BillInfo = nil
                    IGFinancialServiceBill.isTrafficOffenses = false
                    let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                    let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                    messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: discoveryInfo.igpValue)
                    messagesVc.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                    return
                }
            } else {
                IGFinancialServiceBill.BillInfo = nil
                IGFinancialServiceBill.isTrafficOffenses = false
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: discoveryInfo.igpValue)
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                return
            }
            
        case .trafficBillMenu:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGFinancialServiceBill.BillInfo = nil
                    IGFinancialServiceBill.isTrafficOffenses = true
                    let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                    let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                    messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: discoveryInfo.igpValue)
                    messagesVc.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                    return
                }
            } else {
                IGFinancialServiceBill.BillInfo = nil
                IGFinancialServiceBill.isTrafficOffenses = true
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBill") as! IGFinancialServiceBill
                messagesVc.defaultBillInfo = IGHelperJson.parseBillInfo(data: discoveryInfo.igpValue)
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                return
            }
            
        case .mobileBillMenu:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGFinancialServiceBillingInquiry.isMobile = true
                    let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                    let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
                    messagesVc.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                    return
                }
            } else {
                IGFinancialServiceBillingInquiry.isMobile = true
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                return
            }
        case .phoneBillMenu:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)

                } else {
                    IGFinancialServiceBillingInquiry.isMobile = false
                    let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                    let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
                    messagesVc.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                    return
                }
            } else {
                IGFinancialServiceBillingInquiry.isMobile = false
                let storyBoard = UIStoryboard(name: "IGSettingStoryboard", bundle: nil)
                let messagesVc = storyBoard.instantiateViewController(withIdentifier: "IGFinancialServiceBillingInquiry") as! IGFinancialServiceBillingInquiry
                messagesVc.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(messagesVc, animated:true)
                return
            }
        case .nearbyMenu:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    SwiftEventBus.post(EventBusManager.discoveryNearbyClick)
                    return
                }
            } else {
                SwiftEventBus.post(EventBusManager.discoveryNearbyClick)
                return
            }
        case .call:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    if let url = NSURL(string: "tel://\(discoveryInfo.igpValue)"), UIApplication.shared.canOpenURL(url as URL) {
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    }
                    return
                    
                }
            } else {
                if let url = NSURL(string: "tel://\(discoveryInfo.igpValue)"), UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
                return
                
            }
        case .stickerShop:

            
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    if #available(iOS 10.0, *) {
                        IGTabBarStickerController.openStickerCategories()
                    }
                    return
                }
            } else {
                if #available(iOS 10.0, *) {
                    IGTabBarStickerController.openStickerCategories()
                }
                return
            }
        case .ivand:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let scanner = IGScoreViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    scanner.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(scanner, animated:true)
                    return
                }
            } else {
                let scanner = IGScoreViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                scanner.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(scanner, animated:true)
                return
            }

            
        case .ivandqr:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let scanner = IGSettingQrScannerViewController.instantiateFromAppStroryboard(appStoryboard: .Setting)
                    scanner.scannerPageType = .IVandScore
                    scanner.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(scanner, animated:true)
                    return
                }
            } else {
                let scanner = IGSettingQrScannerViewController.instantiateFromAppStroryboard(appStoryboard: .Setting)
                scanner.scannerPageType = .IVandScore
                scanner.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(scanner, animated:true)
                return
            }
        case .ivandlist:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    let scoreHistory = IGScoreHistoryViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                    scoreHistory.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(scoreHistory, animated:true)
                    return
                }
            } else {
                let scoreHistory = IGScoreHistoryViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                scoreHistory.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(scoreHistory, animated:true)
                return
            }
            
        case .ivandscore:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
        
                    
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .question, title: nil, showIconView: true, showDoneButton: true, showCancelButton: false, message: IGStringsManager.SureToSubmit.rawValue.localized,doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized,done: {
                        IGUserIVandSetActivityRequest.sendRequest(plancode: discoveryInfo.igpValue)
                        return

                    })

                }
            } else {
                
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .question, title: nil, showIconView: true, showDoneButton: true, showCancelButton: false, message: IGStringsManager.SureToSubmit.rawValue.localized,doneText: IGStringsManager.GlobalOK.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized,done: {
                    IGUserIVandSetActivityRequest.sendRequest(plancode: discoveryInfo.igpValue)
                    return

                })

            }
            
        case .cardToCard:

            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGHelperFinancial.shared.sendCardToCardRequest()
                    return
                }
            } else {
                IGHelperFinancial.shared.sendCardToCardRequest()
                return
            }
            
        case .payDirect:
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: discoveryInfo.igpValue, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                }
            } else {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: discoveryInfo.igpValue, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            }
        case .walletMenu:
            
            if !(agreementSlug == "") {
                if (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                    carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
                    
                } else {

                    switch valueType {
                    case "QR_USER_WALLET" :
                        let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)
                        let qrVC: QRMainTabbarController = (storyboard.instantiateViewController(withIdentifier: "qrMainTabbar") as! QRMainTabbarController)
                        qrVC.hidesBottomBarWhenPushed = true
                        UIApplication.topViewController()!.navigationController!.pushViewController(qrVC, animated: true)
                        
                        break
                        
                    case "QR_MERCHANT_WALLET" :
                        break
                    default :
                        let vc = packetTableViewController.instantiateFromAppStroryboard(appStoryboard: .Wallet)
                        vc.hidesBottomBarWhenPushed = true
                        UIApplication.topViewController()!.navigationController!.pushViewController(vc, animated: true)
                        
                        break
                    }
                    
                }
            } else {

                switch valueType {
                case "QR_USER_WALLET" :
                    let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)
                    let qrVC: QRMainTabbarController = (storyboard.instantiateViewController(withIdentifier: "qrMainTabbar") as! QRMainTabbarController)
                    qrVC.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(qrVC, animated: true)
                    
                    break
                    
                case "QR_MERCHANT_WALLET" :
                    break
                default :
                    let vc = packetTableViewController.instantiateFromAppStroryboard(appStoryboard: .Wallet)
                    vc.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(vc, animated: true)
                    
                    break
                }
            }
            
        case .financialHistory:
            let financialHistory = IGFinancialHistoryViewController.instantiateFromAppStroryboard(appStoryboard: .FinancialHistory)
            financialHistory.hidesBottomBarWhenPushed = true
            UIApplication.topViewController()!.navigationController!.pushViewController(financialHistory, animated:true)
            break
            
        case .internetPackageMenu:
            
            let vc = IGPSTopUpMainVC()
            vc.hidesBottomBarWhenPushed = true
            vc.pageType = .NetworkPackage
            UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
            break
            
        case .charity:
            guard let jsonValue = valueType.toJSON() as? [String:AnyObject], let id = jsonValue["charityId"] as? String, var price = jsonValue["price"] as? Int else {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                break
            }
            if price == 0 {
                IGHelperMBAlert.shared.showEnterAmount(view: UIApplication.topViewController(),showCloseIcon: false, alertType: .twoButton, title: IGStringsManager.AmountInRial.rawValue.localized, buttonOneTitleColor: .white, buttonOneBackColor: UIColor.iGapRed(), buttonOneText: IGStringsManager.GlobalClose.rawValue.localized, buttonOneAction: {
                    print("CLOSETAPPED")
                }, buttonTwoTitleColor: .white, buttonTwoBackColor: ThemeManager.currentTheme.NavigationSecondColor, buttonTwoText: IGStringsManager.GlobalOK.rawValue.localized, buttonTwoAction: {
                    print("SENDTAPPED")
                    if (IGHelperMBAlert.shared.imputTextfield.text!) != "" {
                        price = Int(IGHelperMBAlert.shared.imputTextfield.text!)!
                    }
                    IGGlobal.prgShow()

                    IGApiCharity.shared.getHelpPaymentToken(charityId: id, amount: price) { (isSuccess, token) in
                        if isSuccess {
                            guard let token = token else { IGGlobal.prgHide(); return }
                            print("Success: " + token)
                            IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                                IGGlobal.prgHide()
                                let paymentView = IGPaymentView.sharedInstance
                                if success {
                                    guard let paymentData = payment else {
                                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                                        return
                                    }
                                    paymentView.show(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Charity.rawValue.localized, payToken: token, payment: paymentData)
                                } else {
                                    paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Charity.rawValue.localized, message: errorMessage ?? "", payToken: token)
                                }
                            })
                        } else {
                            IGGlobal.prgHide()
                        }
                    }

                })
                break

            } else {
                IGGlobal.prgShow()
                IGApiCharity.shared.getHelpPaymentToken(charityId: id, amount: price) { (isSuccess, token) in
                    if isSuccess {
                        guard let token = token else { IGGlobal.prgHide(); return }
                        print("Success: " + token)
                        IGApiPayment.shared.orderCheck(token: token, completion: { (success, payment, errorMessage) in
                            IGGlobal.prgHide()
                            let paymentView = IGPaymentView.sharedInstance
                            if success {
                                guard let paymentData = payment else {
                                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                                    return
                                }
                                paymentView.show(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Charity.rawValue.localized, payToken: token, payment: paymentData)
                            } else {
                                paymentView.showOnErrorMessage(on: UIApplication.shared.keyWindow!, title: IGStringsManager.Charity.rawValue.localized, message: errorMessage ?? "", payToken: token)
                            }
                        })
                    } else {
                        IGGlobal.prgHide()
                    }
                }
                break
            }
        case .news:
            if !(agreementSlug == "") && (agreementValue == false) && (IGGlobal.carpinoAgreement == false) {
                carpinoAggrement(agrementSlug: discoveryInfo.igpAgreementSlug ,itemID : discoveryInfo.igpID , url : discoveryInfo.igpValue)
            } else {
                if !discoveryInfo.igpValue.isEmpty {
                    let finalUrl = URL(string: discoveryInfo.igpValue)

                    DeepLinkManager.shared.handleDeeplink(url: finalUrl!)
                    DeepLinkManager.shared.checkDeepLink()
                } else {
                    let dashboard = IGNewsTableViewController.instantiateFromAppStroryboard(appStoryboard: .News)
                        dashboard.hidesBottomBarWhenPushed = true
                    UIApplication.topViewController()!.navigationController!.pushViewController(dashboard, animated: true)
                }
            }
            break
            
        case .virtualGiftCard:
            
            IGGlobal.prgShow()
            IGApiSticker.shared.giftStickerFirstPageInfo { giftStickerFirstPageInfo in
                IGGlobal.prgHide()
                let giftStickerInfo = IGGiftStickerFirstPageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                giftStickerInfo.pageInfo = giftStickerFirstPageInfo
                UIApplication.topViewController()!.navigationController!.pushViewController(giftStickerInfo, animated: true)
            }
            break
        
        case .parsland:
            UIApplication.topViewController()?.navigationController?.pushViewController(IGMBLoginVC(), animated: true)
            break
            
        case .blockchain:
            if IGKKeychainHandler.getFromKeychain(key: .Pin) == "" {
                let igk = IGKIntroVC()
                igk.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(igk, animated: true)
            }else {
                IGKNewTokenVM.make()
                IGKNewTokenVM.shared?.getDataFromKeychain()
                let igk = IGKPinLoginVC(vc: IGKProfileVC())
                igk.hidesBottomBarWhenPushed = true
                UIApplication.topViewController()!.navigationController!.pushViewController(igk, animated: true)
            }

        default:
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.InstallLatestVersion.rawValue.localized, cancelText: IGStringsManager.GlobalOK.rawValue.localized)
            return
        }
    }
    private func removeCreditCellView() {
        lblStar.removeFromSuperview()
        lblYourScoreTitle.removeFromSuperview()
        lblYourScore.removeFromSuperview()
        viewSeparatorLine.removeFromSuperview()
        lblTitle.removeFromSuperview()
    }
    private func makeCreditCellView() {
        addSubview(lblStar)
        addSubview(lblYourScoreTitle)
        addSubview(lblYourScore)
        addSubview(viewSeparatorLine)
        addSubview(lblTitle)
        
        NSLayoutConstraint.activate([viewSeparatorLine.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     viewSeparatorLine.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     viewSeparatorLine.widthAnchor.constraint(equalToConstant: 2),
                                     viewSeparatorLine.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65)
        ])
        
        NSLayoutConstraint.activate([lblStar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                                     lblStar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
                                     lblStar.widthAnchor.constraint(equalTo: lblStar.heightAnchor),
                                     lblStar.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([lblYourScoreTitle.bottomAnchor.constraint(equalTo: centerYAnchor),
                                     lblYourScoreTitle.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5),
                                     lblYourScoreTitle.trailingAnchor.constraint(equalTo: viewSeparatorLine.leadingAnchor, constant: -8),
                                     lblYourScoreTitle.leadingAnchor.constraint(equalTo: lblStar.trailingAnchor, constant: 8)
        ])
        
        NSLayoutConstraint.activate([lblYourScore.leadingAnchor.constraint(equalTo: lblYourScoreTitle.leadingAnchor),
                                     lblYourScore.trailingAnchor.constraint(equalTo: lblYourScoreTitle.trailingAnchor),
                                     lblYourScore.topAnchor.constraint(equalTo: centerYAnchor, constant: 4),
                                     lblYourScore.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5, constant: -4)
        ])
        
        NSLayoutConstraint.activate([lblTitle.leadingAnchor.constraint(equalTo: viewSeparatorLine.trailingAnchor, constant: 8),
                                     lblTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                                     lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     lblTitle.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9)
        ])
        
        getScore()
        
        layoutSubviews()
        lblTitle.layoutIfNeeded()
        Animations.circularShake(on: lblTitle)
        
        if LocaleManager.isRTL {
            self.semanticContentAttribute = .forceRightToLeft
            viewSeparatorLine.semanticContentAttribute = .forceRightToLeft
            lblStar.semanticContentAttribute = .forceRightToLeft
            lblYourScoreTitle.semanticContentAttribute = .forceRightToLeft
            lblYourScore.semanticContentAttribute = .forceRightToLeft
            lblTitle.semanticContentAttribute = .forceRightToLeft
        }else {
            self.semanticContentAttribute = .forceLeftToRight
            viewSeparatorLine.semanticContentAttribute = .forceLeftToRight
            lblStar.semanticContentAttribute = .forceLeftToRight
            lblYourScoreTitle.semanticContentAttribute = .forceLeftToRight
            lblYourScore.semanticContentAttribute = .forceLeftToRight
            lblTitle.semanticContentAttribute = .forceLeftToRight
        }
        lblStar.textColor = ThemeManager.currentTheme.iVandColor
        lblYourScore.textColor = ThemeManager.currentTheme.iVandColor
        lblTitle.textColor = ThemeManager.currentTheme.iVandColor

    }
    
 
    private func getScore(){
        lblYourScore.text = "..."
        IGUserIVandGetScoreRequest.Generator.generate().success({ [weak self] (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self?.lblYourScore.text = String(describing: response.igpScore).inRialFormat()
                }
            }
        }).error({ [weak self] (errorCode, waitTime) in
            
            switch errorCode {
            case .timeout :
                self?.getScore()
            default:
                break
            }
        }).send()
    }
    
}
