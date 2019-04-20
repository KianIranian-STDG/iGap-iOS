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

class IGScoreViewController: UIViewController, UIGestureRecognizerDelegate {

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
            txtReferralCode.text = "referral : " + representerCode
        } else {
            txtReferralCode.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getScore()
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Score")
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
                    self.txtScore.text = String(describing: response.igpScore)
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
