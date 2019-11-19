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
import SnapKit

class ProgressCell: IGMessageGeneralCollectionViewCell {

    public var fakeId: Int64!
    @IBOutlet weak var progress: AnimateloadingView!
    
    //MARK: - Class Methods
    class func nib() -> UINib {
        return UINib(nibName: "ProgressCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    //MARK: - Instance Method
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func showProgress(){
        progress.stopAnimating()
        progress.startAnimating()
    }
}
