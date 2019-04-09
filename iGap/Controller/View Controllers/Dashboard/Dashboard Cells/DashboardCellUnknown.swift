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

class DashboardCellUnknown: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var txtUnknown: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func nib() -> UINib {
        return UINib(nibName: "DashboardCellUnknown", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    public func initView(){
        txtUnknown.layer.masksToBounds = true
        txtUnknown.layer.cornerRadius = IGDashboardViewController.itemCorner
    }
}
