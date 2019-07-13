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

class DashboardCell1: AbstractDashboardCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var img: IGImageView!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "DashboardCell1", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    public override func initView(dashboard: [IGPDiscoveryField]){
        mainViewAbs = mainView
        img1Abs = img
        view1Abs = view
        super.initView(dashboard: dashboard)
    }
    public override func initViewPoll(dashboard: [IGPPollField]){
        mainViewAbs = mainView
        img1Abs = img
        view1Abs = view
        super.initViewPoll(dashboard: dashboard)
    }
}
