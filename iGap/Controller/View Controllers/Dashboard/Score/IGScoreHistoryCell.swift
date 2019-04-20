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

class IGScoreHistoryCell: UICollectionViewCell {
    
    @IBOutlet weak var txtScoreIcon: UILabel!
    @IBOutlet weak var txtScoreNumber: UILabel!
    @IBOutlet weak var txtTime: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func initView(activity: IGPIVandActivity){
        txtScoreNumber.text = String(describing: activity.igpScore)
        txtTime.text = String(describing: activity.igpTime)
        txtTitle.text = activity.igpTitle
    }
}
