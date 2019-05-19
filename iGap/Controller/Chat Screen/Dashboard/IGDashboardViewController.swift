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
import MapKit

class IGDashboardViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate, CLLocationManagerDelegate, DiscoveryObserver {

    static let itemCorner: CGFloat = 15
    let screenWidth = UIScreen.main.bounds.width
    public var pageId: Int32 = 0
    private var discovery: [IGPDiscovery] = []
    private var refresher: UIRefreshControl!
    private let locationManager = CLLocationManager()
    static var discoveryObserver: DiscoveryObserver!
    static var needGetFirstPage = true
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnRefresh: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        registerCellsNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.gray
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        
        btnRefresh.layer.cornerRadius = 25
        btnRefresh.layer.masksToBounds = false
        btnRefresh.layer.shadowColor = UIColor.gray.cgColor
        btnRefresh.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnRefresh.layer.shadowOpacity = 0.3
        
        getDiscoveryList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(UIView.appearance().semanticContentAttribute.rawValue)
        print(UITableView.appearance().semanticContentAttribute.rawValue)
        print(UICollectionView.appearance().semanticContentAttribute.rawValue)
        IGDashboardViewController.discoveryObserver = self
        print(UIView.appearance().semanticContentAttribute.rawValue)
        print(UITableView.appearance().semanticContentAttribute.rawValue)
        print(UICollectionView.appearance().semanticContentAttribute.rawValue)
        collectionView.reloadData()

        
        /*
        if let navigationItem = self.tabBarController?.navigationItem as? IGNavigationItem {
            navigationItem.addiGapLogo()
        }
        */
    }
    
    private func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func registerCellsNib(){
        self.collectionView!.register(DashboardCellUnknown.nib(), forCellWithReuseIdentifier: DashboardCellUnknown.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell1.nib(), forCellWithReuseIdentifier: DashboardCell1.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell2.nib(), forCellWithReuseIdentifier: DashboardCell2.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell3.nib(), forCellWithReuseIdentifier: DashboardCell3.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell4.nib(), forCellWithReuseIdentifier: DashboardCell4.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell5.nib(), forCellWithReuseIdentifier: DashboardCell5.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell6.nib(), forCellWithReuseIdentifier: DashboardCell6.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell7.nib(), forCellWithReuseIdentifier: DashboardCell7.cellReuseIdentifier())
    }
    
    @objc private func loadData(){
        getDiscoveryList()
        stopRefresher()
    }
    
    @IBAction func btnRefresh(_ sender: UIButton) {
        getDiscoveryList()
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    private func getDiscoveryList(){

        if pageId == 0 ,let discovery = IGRealmDiscovery.getDiscoveryInfo() {
            self.discovery = discovery.igpDiscoveries
            self.collectionView.reloadData()
        }
        
        if !IGAppManager.sharedManager.isUserLoggiedIn() {
            return
        }
        
        IGClientGetDiscoveryRequest.Generator.generate(pageId: pageId).successPowerful({ (protoResponse, requestWrapper) in
            if let response = protoResponse as? IGPClientGetDiscoveryResponse {
                self.discovery = response.igpDiscoveries
                
                /* just save first page info */
                if let request = requestWrapper.message as? IGPClientGetDiscovery, request.igpPageID == 0 {
                    IGDashboardViewController.needGetFirstPage = false
                    IGFactory.shared.addDiscoveryPageInfo(discoveryList: self.discovery)
                }
                
                DispatchQueue.main.async {
                    let navigationItem = self.navigationItem as! IGNavigationItem
                    navigationItem.addNavigationViewItems(rightItemText: nil, title: response.igpTitle)
                    self.collectionView.reloadData()
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getDiscoveryList()
                self.manageShowDiscovery()
            default:
                break
            }
        }).send()
    }
    
    private func computeHeight(scale: String) -> CGFloat{
        let split = scale.split(separator: ":")
        let heightScale = NumberFormatter().number(from: split[1].description)
        let widthScale = NumberFormatter().number(from: split[0].description)
        let scale = CGFloat(truncating: heightScale!) / CGFloat(truncating: widthScale!)
        let height: CGFloat = IGGlobal.fetchUIScreen().width * scale
        return height
    }
    
    /* if user is login show collectionView, otherwise show btnRefresh */
    private func manageShowDiscovery(){
        if IGAppManager.sharedManager.isUserLoggiedIn() || pageId == 0 {
            self.collectionView!.isHidden = false
            self.btnRefresh!.isHidden = true
            if discovery.count == 0 {
                self.collectionView!.setEmptyMessage("PLEASE_WAIT_DATA_LOAD".localizedNew)
            } else {
                self.collectionView!.restore()
            }
        } else {
            self.collectionView!.isHidden = true
            self.btnRefresh!.isHidden = false
        }
    }
    
    /*************************************************************/
    /************************* callbacks *************************/
    
    func onFetchFirstPage() {
        if IGDashboardViewController.needGetFirstPage && pageId == 0 {
            getDiscoveryList()
        }
    }
    
    func onNearbyClick() {
        manageOpenMap()
    }
    
    func manageOpenMap(){
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            IGHelperNearby.shared.openMap()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            IGHelperNearby.shared.openMap()
        }
    }
    
    /**************************************************************/
    /*********************** collectionView ***********************/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        manageShowDiscovery()
        return discovery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = discovery[indexPath.section]

        if item.igpModel == .model1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell1.cellReuseIdentifier(), for: indexPath) as! DashboardCell1
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else if item.igpModel == .model2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell2.cellReuseIdentifier(), for: indexPath) as! DashboardCell2
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else if item.igpModel == .model3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell3.cellReuseIdentifier(), for: indexPath) as! DashboardCell3
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else if item.igpModel == .model4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell4.cellReuseIdentifier(), for: indexPath) as! DashboardCell4
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else if item.igpModel == .model5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell5.cellReuseIdentifier(), for: indexPath) as! DashboardCell5
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else if item.igpModel == .model6 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell6.cellReuseIdentifier(), for: indexPath) as! DashboardCell6
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else if item.igpModel == .model7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell7.cellReuseIdentifier(), for: indexPath) as! DashboardCell7
            cell.initView(dashboard: discovery[indexPath.section].igpDiscoveryfields)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCellUnknown.cellReuseIdentifier(), for: indexPath) as! DashboardCellUnknown
            cell.initView()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Hint: plus height with 16 ,because in storyboard we used 4 space from top and 4 space from bottom
        return CGSize(width: screenWidth, height: computeHeight(scale: discovery[indexPath.section].igpScale) + 8)
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
