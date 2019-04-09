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

struct Dashboard {
    var type: Int!
    var height: CGFloat!
}

class IGDashboardViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    static let itemCorner: CGFloat = 10
    
    var dashboardList: [Dashboard] = [
        Dashboard(type: 1, height: 150),
        Dashboard(type: 2, height: 150),
        Dashboard(type: 3, height: 200),
        Dashboard(type: 4, height: 150),
        Dashboard(type: 5, height: 190),
        Dashboard(type: 6, height: 170)]
    
    let screenWidth = UIScreen.main.bounds.width
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCellsNib()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationItem = self.tabBarController?.navigationItem as? IGNavigationItem {
            navigationItem.addiGapLogo()
        }
    }
    
    private func registerCellsNib(){
        self.collectionView!.register(DashboardCell1.nib(), forCellWithReuseIdentifier: DashboardCell1.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell2.nib(), forCellWithReuseIdentifier: DashboardCell2.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell3.nib(), forCellWithReuseIdentifier: DashboardCell3.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell4.nib(), forCellWithReuseIdentifier: DashboardCell4.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell5.nib(), forCellWithReuseIdentifier: DashboardCell5.cellReuseIdentifier())
        self.collectionView!.register(DashboardCell6.nib(), forCellWithReuseIdentifier: DashboardCell6.cellReuseIdentifier())
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dashboardList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = dashboardList[indexPath.section]
        
        if item.type == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell1.cellReuseIdentifier(), for: indexPath) as! DashboardCell1
            cell.initView(dashboard: dashboardList[indexPath.section])
            return cell
        } else if item.type == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell2.cellReuseIdentifier(), for: indexPath) as! DashboardCell2
            cell.initView(dashboard: dashboardList[indexPath.section])
            return cell
        } else if item.type == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell3.cellReuseIdentifier(), for: indexPath) as! DashboardCell3
            cell.initView(dashboard: dashboardList[indexPath.section])
            return cell
        } else if item.type == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell4.cellReuseIdentifier(), for: indexPath) as! DashboardCell4
            cell.initView(dashboard: dashboardList[indexPath.section])
            return cell
        } else if item.type == 5 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell5.cellReuseIdentifier(), for: indexPath) as! DashboardCell5
            cell.initView(dashboard: dashboardList[indexPath.section])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCell6.cellReuseIdentifier(), for: indexPath) as! DashboardCell6
            cell.initView(dashboard: dashboardList[indexPath.section])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = dashboardList[indexPath.section]
        return CGSize(width: screenWidth, height: item.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(-1, 0, -1, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
