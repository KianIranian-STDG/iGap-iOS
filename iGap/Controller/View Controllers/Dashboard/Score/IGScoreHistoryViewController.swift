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

class IGScoreHistoryViewController: UIViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var isLoadingMore: Bool = false
    var numberOfGetScoreFetchedInLastRequest: Int = -1
    let GET_SCORE_CONFIG: Int32 = 25
    var iVandActivities: [IGPIVandActivity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        customizeView()
        manageShowActivties(isFirst: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getHistory()
    }
    
    @IBAction func btnScan(_ sender: UIButton) {
        let scanner = IGSettingQrScannerViewController.instantiateFromAppStroryboard(appStoryboard: .Setting)
        scanner.scannerPageType = .IVandScore
        self.navigationController!.pushViewController(scanner, animated:true)
    }
    
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Score History")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func customizeView(){
        bottomView.layer.masksToBounds = false
        bottomView.layer.shadowOffset = CGSize(width: 0, height: -15)
        bottomView.layer.shadowColor = UIColor.white.cgColor
        bottomView.layer.shadowOpacity = 0.9
        
        btnScan.layer.masksToBounds = true
        btnScan.layer.cornerRadius = 20
        btnScan.layer.shadowOffset = CGSize(width: 1, height: 1)
        btnScan.layer.shadowRadius = 1
        btnScan.layer.shadowColor = UIColor.gray.cgColor
        btnScan.layer.shadowOpacity = 0.4
    }
    
    private func manageShowActivties(isFirst: Bool = false){
        if isFirst {
            self.collectionView!.setEmptyMessage("Please wait for get info!")
        } else if iVandActivities.count == 0 {
            self.collectionView!.setEmptyMessage("not exist history!")
        } else {
            self.collectionView!.restore()
        }
    }
    
    private func getHistory(){
        IGUserIVandGetActivitiesRequest.Generator.generate(offset: 0, limit: 10).success({ (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetActivitiesResponse {
                self.iVandActivities = response.igpActivities
                self.numberOfGetScoreFetchedInLastRequest = self.iVandActivities.count
                DispatchQueue.main.async {
                    self.manageShowActivties()
                    self.collectionView.reloadData()
                }
            }
        }).error({ (errorCode, waitTime) in }).send()
    }
    
    /**************************************************************/
    /*********************** collectionView ***********************/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return iVandActivities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: IGScoreHistoryCell = self.collectionView!.dequeueReusableCell(withReuseIdentifier: "IGScoreHistoryCell", for: indexPath) as! IGScoreHistoryCell
        cell.initView(activity: iVandActivities[indexPath.section])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: IGGlobal.fetchUIScreen().width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

extension IGScoreHistoryViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let remaining = scrollView.contentSize.height - (scrollView.frame.size.height + scrollView.contentOffset.y)
        if remaining < 150 {
            self.loadMore()
        }
    }
    
    func loadMore() {
        if !isLoadingMore && numberOfGetScoreFetchedInLastRequest > 0 {
            isLoadingMore = true
            let offset = iVandActivities.count
            IGUserIVandGetActivitiesRequest.Generator.generate(offset: Int32(offset), limit: GET_SCORE_CONFIG).success ({ (responseProtoMessage) in
                DispatchQueue.main.async {
                    if let response = responseProtoMessage as? IGPUserIVandGetActivitiesResponse {
                        self.numberOfGetScoreFetchedInLastRequest = response.igpActivities.count
                        self.iVandActivities += response.igpActivities
                        self.collectionView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.isLoadingMore = false
                    }
                }
            }).error({ (errorCode, waitTime) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.isLoadingMore = false
                }
            }).send()
        }
    }
}
