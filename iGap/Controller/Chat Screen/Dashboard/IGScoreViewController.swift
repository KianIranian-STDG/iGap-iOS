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
import SnapKit


    class IGScoreViewController: BaseViewController {

    @IBOutlet weak var imgAvatar: IGAvatarView!
    @IBOutlet weak var txtDisplayName: UILabel!
    @IBOutlet weak var txtReferralCode: UILabel!
    @IBOutlet weak var progreccCIrcularRank : UICircularProgressRing!
    
    @IBOutlet weak var progreccCIrcular : UICircularProgressRing!
    @IBOutlet weak var txtScoreTitle: UILabel!
    
    @IBOutlet weak var txtRankTitle: UILabel!
    @IBOutlet weak var btnSeeRecords: UIButton!
    @IBOutlet weak var lblInviteFriends: UILabel!
    @IBOutlet weak var lblPayments: UILabel!
    @IBOutlet weak var lblScanQR: UILabel!
    @IBOutlet weak var lblBotChannels: UILabel!
    
    @IBOutlet weak var btnPointInviteFriends: UILabel!
    @IBOutlet weak var btnPointPayments: UILabel!
    @IBOutlet weak var btnPointScanQR: UILabel!
    @IBOutlet weak var btnPointBotChannels: UILabel!
    var tmpScore : Int32!
    var tmpRank : Int32!
    var tmpRankTotal : Int32!
    var tmpScoresList : [IGProtoBuff.IGPUserIVandGetScoreResponse.IGPIVandScore]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        customizeView()
        btnSeeRecords.setTitle("SETTING_PAGE_ACCOUNT_GIFT_PAGE".localizedNew, for: .normal)
        initCircularProgressBar()
    }
    
    
    func initCircularProgressBar(ranMax : CGFloat? = 0.0,scoreMax : CGFloat? = 0.0) {
        progreccCIrcular.maxValue = scoreMax!
        progreccCIrcular.style = .bordered(width: 2.0, color: UIColor.clear)
        progreccCIrcular.innerRingColor = UIColor.iGapDarkYellow()
        progreccCIrcular.innerRingWidth = 7.0
        progreccCIrcular.outerRingColor = UIColor.iGapDarkYellow()
        progreccCIrcular.outerRingWidth = 1.0
        
        progreccCIrcularRank.maxValue = ranMax!
        progreccCIrcularRank.style = .bordered(width: 2.0, color: UIColor.clear)
        progreccCIrcularRank.innerRingColor = UIColor.iGapPurple()
        progreccCIrcularRank.innerRingWidth = 7.0
        progreccCIrcularRank.outerRingColor = UIColor.iGapPurple()
        progreccCIrcularRank.outerRingWidth = 1.0
    }
    func addScoreListItems(array : [IGProtoBuff.IGPUserIVandGetScoreResponse.IGPIVandScore]? = nil) {
        let view = UIView()
        let lbl = UILabel()
        let btnScore = UIButton()
        self.view.addSubview(lbl)
        self.view.addSubview(view)
        
        var space : CGFloat! = 0
        var count : Int! = 0
        
        if array!.count > 0 {
            
            for item in array! {
                view.snp.makeConstraints { (make) in
                    make.leading.equalTo(txtScoreTitle.snp.leading)
                    make.trailing.equalTo(txtRankTitle.snp.trailing)
                    make.top.equalTo(txtScoreTitle.snp.bottom).offset(30 + space)
                    make.height.equalTo(30)
                }
                view.backgroundColor = .clear
                view.addSubview(lbl)
                view.addSubview(btnScore)
                

                if lastLang == "fa" {
                    btnScore.snp.makeConstraints { (make) in
                        make.leading.equalTo(view.snp.leading).offset(10)
                        make.centerY.equalTo(view.snp.centerY)
                        make.height.equalTo(30)
                        make.width.equalTo(80)
                    }
                    lbl.snp.makeConstraints { (make) in
                        make.trailing.equalTo(view.snp.trailing).offset(-10)
                        make.leading.equalTo(btnScore.snp.trailing).offset(10)
                        make.centerY.equalTo(view.snp.centerY)
                    }

                } else if lastLang == "en" {
                    btnScore.snp.makeConstraints { (make) in
                        make.trailing.equalTo(view.snp.trailing).offset(-10)
                        make.centerY.equalTo(view.snp.centerY)
                        make.height.equalTo(30)
                        make.width.equalTo(80)
                    }
                    lbl.snp.makeConstraints { (make) in
                        make.leading.equalTo(view.snp.leading).offset(10)
                        make.trailing.equalTo(btnScore.snp.leading).offset(10)
                        make.centerY.equalTo(view.snp.centerY)
                    }

                }

                btnScore.backgroundColor = UIColor.iGapBars()
                btnScore.layer.cornerRadius = 10.0
                btnScore.setTitle( String(array![count].igpScore).inLocalizedLanguage() + " + " , for: .normal)
                btnScore.titleLabel?.font = UIFont.igFont(ofSize: 15,weight: .bold)
                lbl.font = UIFont.igFont(ofSize: 14,weight: .bold)
                lbl.textAlignment = lbl.localizedNewDirection
                if lastLang == "fa"  {
                    lbl.text = array![count].igpFaName
                } else {
                    lbl.text = array![count].igpEnName
                }
                count += 1
                space += 5 + (view.bounds.height)
            }

        }
        SMLoading.hideLoadingPage()
    }
    
    
    func startAnimatingCircular(value: Int32!) {
        progreccCIrcular.startProgress(to: CGFloat(value), duration: 2.0) {
            print("Done animating!")
        }
        
    }
    func startAnimatingCircularRank(value: Int32!) {
        progreccCIrcularRank.startProgress(to: CGFloat(value), duration: 2.5) {
            print("Done animating!")
        }
        
    }
    func animateProgress() {
        UIView.animate(withDuration: 1.0, animations: {
            //            self.progressBar.value = CGFloat(9999999)
        })
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //        self.progressBar.maxValue = 10000000
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        txtScoreTitle.text = "YOUR_SCORE".localizedNew
        txtScoreTitle.font = UIFont.igFont(ofSize: 20)
        
        txtRankTitle.text = "YOUR_RANK".localizedNew
        txtRankTitle.font = UIFont.igFont(ofSize: 20)
        //        txtScore.font = UIFont.igFont(ofSize: 25)
        btnSeeRecords.titleLabel?.font = UIFont.igFont(ofSize: 17)
        getScore()

    }
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        
        navigationItem.addNavigationViewItems(rightItemText: "", title: "SETTING_PAGE_ACCOUNT_SCORE_PAGE".localizedNew,iGapFont :true)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        navigationItem.rightViewContainer?.addAction {
            
            let scoreHistory = IGScoreHistoryViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            self.navigationController!.pushViewController(scoreHistory, animated:true)
        }
    }
    
    private func customizeView(){
        btnSeeRecords.isHidden = true
        btnSeeRecords.layer.masksToBounds = true
        btnSeeRecords.layer.cornerRadius = 20
        btnSeeRecords.layer.shadowOffset = CGSize(width: 1, height: 1)
        btnSeeRecords.layer.shadowRadius = 1
        btnSeeRecords.layer.shadowColor = UIColor.gray.cgColor
        btnSeeRecords.layer.shadowOpacity = 0.4
    }
    
    private func getScore(){
        SMLoading.showLoadingPage(viewcontroller: self)

        IGUserIVandGetScoreRequest.Generator.generate().success({ (protoResponse) in
            
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self.tmpScore = (response.igpScore)
                    self.tmpRank = (response.igpUserRank)
                    self.tmpRankTotal = (response.igpTotalRank)
                    self.tmpScoresList = (response.igpScores)
                    self.addScoreListItems(array : self.tmpScoresList)

                    self.initCircularProgressBar(ranMax: CGFloat(self.tmpRankTotal), scoreMax: CGFloat(self.tmpScore))
                    self.startAnimatingCircular(value: self.tmpScore)
                    self.startAnimatingCircularRank(value: self.tmpRank)
                    
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    /****************************** Actions ******************************/
    
    @IBAction func btnSeeRecords(_ sender: UIButton) {
    }
}
