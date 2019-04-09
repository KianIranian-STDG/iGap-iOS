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

class AbstractDashboardCell: UICollectionViewCell {

    var dashboardAbs: [IGPDiscoveryField]!
    var mainViewAbs:  UIView?
    var img1Abs: UIImageView?
    var img2Abs: UIImageView?
    var img3Abs: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func initView(dashboard: [IGPDiscoveryField]){
        self.dashboardAbs = dashboard
        if img1Abs != nil {
            img1Abs?.layer.cornerRadius = IGDashboardViewController.itemCorner
            img1Abs?.layer.masksToBounds = true
            if let url = URL(string: dashboard[0].igpImageurl) {
                img1Abs?.setImage(url: url)
            }
        }
        
        if img2Abs != nil {
            img2Abs?.layer.cornerRadius = IGDashboardViewController.itemCorner
            img2Abs?.layer.masksToBounds = true
            if let url = URL(string: dashboard[1].igpImageurl) {
                img2Abs?.setImage(url: url)
            }
        }
        
        if img3Abs != nil {
            img3Abs?.layer.cornerRadius = IGDashboardViewController.itemCorner
            img3Abs?.layer.masksToBounds = true
            if let url = URL(string: dashboard[2].igpImageurl) {
                img3Abs?.setImage(url: url)
            }
        }
        
        manageGesture()
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
    
    func didTapImage1(_ gestureRecognizer: UITapGestureRecognizer){
        
    }
    
    func didTapImage2(_ gestureRecognizer: UITapGestureRecognizer){
        
    }
    
    func didTapImage3(_ gestureRecognizer: UITapGestureRecognizer){

    }
}
