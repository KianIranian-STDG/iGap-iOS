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

class DashboardCell2: AbstractDashboardCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    class func nib() -> UINib {
        return UINib(nibName: "DashboardCell2", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    override public func initView(dashboard: Dashboard){
        mainViewAbs = mainView
        img1Abs = img1
        img2Abs = img2
        super.initView(dashboard: dashboard)
    }
}
