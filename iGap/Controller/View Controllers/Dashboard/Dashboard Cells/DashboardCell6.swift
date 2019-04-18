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

class DashboardCell6: AbstractDashboardCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var img1: IGImageView!
    @IBOutlet weak var img2: IGImageView!
    @IBOutlet weak var img3: IGImageView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "DashboardCell6", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override public func initView(dashboard: [IGPDiscoveryField]){
        mainViewAbs = mainView
        img1Abs = img1
        img2Abs = img2
        img3Abs = img3
        view1Abs = view1
        view2Abs = view2
        view3Abs = view3
        super.initView(dashboard: dashboard)
    }
}
