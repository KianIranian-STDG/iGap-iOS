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

class IGDashboardViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    static let itemCorner: CGFloat = 10
    let screenWidth = UIScreen.main.bounds.width
    public var pageId: Int32 = 0
    private var discovery: [IGPDiscovery] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        registerCellsNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDiscoveryList()
        if let navigationItem = self.tabBarController?.navigationItem as? IGNavigationItem {
            navigationItem.addiGapLogo()
        }
    }
    
    private func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Discovery")
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
    }
    
    private func getDiscoveryList(){
        IGClientGetDiscoveryRequest.Generator.generate(pageId: pageId).success({ (protoResponse) in
            if let response = protoResponse as? IGPClientGetDiscoveryResponse {
                self.discovery = response.igpDiscoveries
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getDiscoveryList()
            default:
                break
            }
        }).send()
    }
    
    /**************************************************************/
    /*********************** collectionView ***********************/
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCellUnknown.cellReuseIdentifier(), for: indexPath) as! DashboardCellUnknown
            cell.initView()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = discovery[indexPath.section]
        if item.igpModel.rawValue > 5 {
            return CGSize(width: screenWidth, height: 60)
        }
        return CGSize(width: screenWidth, height: CGFloat(item.igpHeight))
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
