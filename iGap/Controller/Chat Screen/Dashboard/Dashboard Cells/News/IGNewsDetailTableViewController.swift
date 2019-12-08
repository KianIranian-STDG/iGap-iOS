//
//  IGNewsDetailTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/4/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGNewsDetailTableViewController: UITableViewController,UIGestureRecognizerDelegate {
    
    var categoryID : String! = "0"
    var category : String! = IGStringsManager.NewsDetail.rawValue.localized
    var currentPage: Int = 1
    var item = IGStructNewsDetail()
    var topHeaderDate : UILabel!
    var topHeaderSeenIcon : UILabel!
    var topHeaderSeenCount : UILabel!


    var TopHeaderId : String! = ""
    
    @IBOutlet weak var viewTopHeader : UIView!
    @IBOutlet weak var imgMainTopHeader : UIImageView!
    @IBOutlet weak var imgAgencyTopHeader : UIImageView!
    @IBOutlet weak var lblTitleTopHeader : UILabel!
    @IBOutlet weak var lblFullTextTopHeader : UILabel!
    @IBOutlet weak var lblFullText : UILabel!
    @IBOutlet weak var lblComments : UILabel!
    @IBOutlet weak var btnShare : UIButton!
    @IBOutlet weak var btnMoreComments : UIButton!
    @IBOutlet weak var btnComment : UIButton!
    var deepLinkID: String?

    

    override func viewDidLoad() {
        super.viewDidLoad()
        SMLoading.showLoadingPage(viewcontroller: self)
        self.tableView.estimatedSectionHeaderHeight = 40.0
        self.tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 240 // Something reasonable to help ios render your cells

        initNavigationBar()
        initTopHeader()
        getData()
        getComments()
        initView()
    }
    private func initTopHeader() {
        viewTopHeader.backgroundColor = UIColor.hexStringToUIColor(hex: "b60000")
        lblTitleTopHeader.font = UIFont.igFont(ofSize: 15)
        lblTitleTopHeader.textColor = .white
        
        lblFullTextTopHeader.textColor = .white
        lblFullTextTopHeader.font = UIFont.igFont(ofSize: 13)
        lblFullText.font = UIFont.igFont(ofSize: 15)

        lblFullTextTopHeader.textAlignment = lblFullTextTopHeader.localizedDirection
        lblTitleTopHeader.textAlignment = lblTitleTopHeader.localizedDirection
        imgAgencyTopHeader.layer.cornerRadius = 5
        imgMainTopHeader.layer.cornerRadius = 5
        lblFullText.textAlignment = lblFullText.localizedDirection
    }
    
    func getData() {
        SMLoading.hideLoadingPage()

        let urlMainImage = URL(string: ((item.image![0].Original)!))
        print(urlMainImage)
        let urlAgency = URL(string: ((item.sourceLogo)!))
        self.imgMainTopHeader.sd_setImage(with: urlMainImage, placeholderImage: UIImage(named :"1"), completed: nil)
        self.imgAgencyTopHeader.sd_setImage(with: urlAgency, placeholderImage: UIImage(named :"1"), completed: nil)
        self.lblFullTextTopHeader.text = item.lead
        self.lblTitleTopHeader.text = item.titr
        self.lblFullText.text = item.fulltext?.html2String

        SMLoading.hideLoadingPage()

    }
    
    private func getComments() {
        SMLoading.showLoadingPage(viewcontroller: self)
        IGApiNews.shared.getNewsComments(page: "1", perPage: "9999999999" , articleId: item.id!) { (isSuccess, response) in
            SMLoading.hideLoadingPage()
            if isSuccess {
                if response!.count > 0 {
                    self.lblComments.font = UIFont.igFont(ofSize: 12)
                    self.lblComments.text = ": " + response![0].userName! + "\n" +  (response![0].commentContent)! + "\n"
                    self.lblComments.textAlignment = .right

                    if response!.count > 1 {
                        self.btnMoreComments.isHidden = false
                    } else {
                        self.btnMoreComments.isHidden = true
                    }
                } else {
                    self.lblComments.font = UIFont.igFont(ofSize: 15)
                    self.lblComments.textAlignment = .center

                    self.lblComments.text = IGStringsManager.noComments.rawValue.localized
                }
            } else {
                self.lblComments.font = UIFont.igFont(ofSize: 15)
                self.lblComments.textAlignment = .center

                self.lblComments.text = IGStringsManager.noComments.rawValue.localized
                self.btnMoreComments.isHidden = true

                return
            }
        }
    }

    
    func initView() {
        lblComments.textColor = UIColor(named : themeColor.labelColor.rawValue)
        lblComments.font = UIFont.igFont(ofSize: 15)
        lblComments.textAlignment = .center
        btnShare.setTitle(IGStringsManager.Share.rawValue.localized, for: .normal)
        btnShare.layer.cornerRadius = 5
        btnShare.setTitleColor(.white, for: .normal)
        btnShare.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnComment.setTitle(IGStringsManager.addComment.rawValue.localized, for: .normal)
        btnComment.layer.cornerRadius = 5
        btnComment.setTitleColor(.white, for: .normal)
        btnComment.titleLabel?.font = UIFont.igFont(ofSize: 15)

        btnMoreComments.setTitle(IGStringsManager.More.rawValue.localized, for: .normal)
        btnMoreComments.setTitleColor(.darkGray, for: .normal)
        btnMoreComments.titleLabel?.font = UIFont.igFont(ofSize: 12)
    }
    @IBAction func didTapOnShare(_ sender: UIButton) {
        print("DID TAP ON SHARE BUTTON")

        
        // set up activity view controller
        let text = item.titr! + "\n" + item.alias! + "\n"
        let text1 = topHeaderDate.text! + "\n"
        let text2 = "این خبر را در آیگپ بخوانید:" + "\n" + "igap://news/showDetail/" + item.id!
        let text3 = "\n" + "لینک خبر :" + "\n" + item.internalLink!
        
        let textToShare = [text + text1 + text2 + text3]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)

    }
    @IBAction func didTapOnSendComment(_ sender: UIButton) {
        IGHelperBottomModals.shared.showBottomPanThreeInput(view: self,articleID: self.item.id!)
    }
    @IBAction func didTapOnMoreComments(_ sender: UIButton) {
        let moreComments = IGNewsCommentsTVController.instantiateFromAppStroryboard(appStoryboard: .News)
        
        moreComments.articleID = item.id!
        UIApplication.topViewController()!.navigationController!.pushViewController(moreComments, animated: true)

    }
    
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: category)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 100))

        if section == 0 {
            topHeaderDate = UILabel()
            v.addSubview(topHeaderDate)
          
            v.backgroundColor = UIColor(named: themeColor.tableViewBackground.rawValue)

            topHeaderDate.text = "date comes here"
            topHeaderDate.font = UIFont.igFont(ofSize: 12)
            topHeaderDate.textColor = UIColor(named: themeColor.labelColor.rawValue)
            topHeaderDate.textAlignment = .right
            topHeaderDate.translatesAutoresizingMaskIntoConstraints = false

            topHeaderDate.rightAnchor.constraint(equalTo: v.rightAnchor,constant: -10).isActive = true
            topHeaderDate.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 0).isActive = true
            topHeaderDate.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width)/3).isActive = true
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: item.publishDate!.checkTime())
            self.topHeaderDate.text = date!.completeHumanReadableTime(showHour: true)

            

            topHeaderSeenIcon = UILabel()
            v.addSubview(topHeaderSeenIcon)
            topHeaderSeenIcon.text = "🌣"
            topHeaderSeenIcon.font = UIFont.iGapFonticon(ofSize: 15)
            topHeaderSeenIcon.textColor = .black
            topHeaderSeenIcon.textAlignment = .center
            topHeaderSeenIcon.translatesAutoresizingMaskIntoConstraints = false

            topHeaderSeenIcon.leftAnchor.constraint(equalTo: v.leftAnchor,constant: 10).isActive = true
            topHeaderSeenIcon.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 0).isActive = true

            
            topHeaderSeenCount = UILabel()
            v.addSubview(topHeaderSeenCount)
            topHeaderSeenCount.text = "12K"
            topHeaderSeenCount.font = UIFont.igFont(ofSize: 12)
            topHeaderSeenCount.textColor = .black
            topHeaderSeenCount.textAlignment = .left
            topHeaderSeenCount.translatesAutoresizingMaskIntoConstraints = false
            
            topHeaderSeenCount.leftAnchor.constraint(equalTo: topHeaderSeenIcon.rightAnchor,constant: 0).isActive = true
            topHeaderSeenCount.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 0).isActive = true
            
            
            //commented due to agency policy
            topHeaderSeenIcon.isHidden = true
            topHeaderSeenCount.isHidden = true

        } else {

            let lbl = UILabel()
            v.addSubview(lbl)
            v.backgroundColor = UIColor(named: themeColor.tableViewCell.rawValue)
            lbl.text = IGStringsManager.comments.rawValue.localized
            lbl.font = UIFont.igFont(ofSize: 15)
            lbl.textColor = UIColor(named: themeColor.labelColor.rawValue)
            lbl.textAlignment = .right
            lbl.translatesAutoresizingMaskIntoConstraints = false

            lbl.rightAnchor.constraint(equalTo: v.rightAnchor,constant: -10).isActive = true
            lbl.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: 0).isActive = true
            lbl.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width)/3).isActive = true

        }
        
        
        return v
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        } else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let v = UIView()
            v.backgroundColor = UIColor(named: themeColor.tableViewBackground.rawValue)
            return v
        } else {
            let v = UIView()
            v.backgroundColor = UIColor(named: themeColor.tableViewBackground.rawValue)
            return v

        }
    }
    //MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
 
    
    
    
    
}
