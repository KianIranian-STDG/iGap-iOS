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
import RealmSwift
import IGProtoBuff

class IGScoreViewController: BaseViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var imgAvatar: IGAvatarView!
    @IBOutlet weak var txtDisplayName: UILabel!
    @IBOutlet weak var txtReferralCode: UILabel!
    @IBOutlet weak var txtScoreTitle: UILabel!
    @IBOutlet weak var txtScore: UILabel!
    @IBOutlet weak var btnSeeRecords: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        customizeView()
        
        let user = IGRegisteredUser.getUserInfo(id: IGAppManager.sharedManager.userID()!)!
        imgAvatar.setUser(user)
        txtDisplayName.text = user.displayName
        
        if let session = try! Realm().objects(IGSessionInfo.self).first, let representerCode = session.representer, !representerCode.isEmpty {
            txtReferralCode.text = "REFERRAL".localizedNew + representerCode.inLocalizedLanguage()
        } else {
            txtReferralCode.isHidden = true
        }
        btnSeeRecords.setTitle("SHOW_HISTORY".localizedNew, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getScore()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtScoreTitle.text = "YOUR_SCORE".localizedNew
        txtScoreTitle.font = UIFont.igFont(ofSize: 30)
        txtScore.font = UIFont.igFont(ofSize: 25)
        btnSeeRecords.titleLabel?.font = UIFont.igFont(ofSize: 17)
    }
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_ACCOUNT_SCORE_PAGE".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func customizeView(){
        btnSeeRecords.layer.masksToBounds = true
        btnSeeRecords.layer.cornerRadius = 20
        btnSeeRecords.layer.shadowOffset = CGSize(width: 1, height: 1)
        btnSeeRecords.layer.shadowRadius = 1
        btnSeeRecords.layer.shadowColor = UIColor.gray.cgColor
        btnSeeRecords.layer.shadowOpacity = 0.4
    }
    
    private func getScore(){
        IGUserIVandGetScoreRequest.Generator.generate().success({ (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self.txtScore.text = String(describing: response.igpScore).inLocalizedLanguage()
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    /****************************** Actions ******************************/
    
    @IBAction func btnSeeRecords(_ sender: UIButton) {
        let scoreHistory = IGScoreHistoryViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
        self.navigationController!.pushViewController(scoreHistory, animated:true)
    }
}
