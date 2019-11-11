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

class CardsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgBankLogo: UIImageView!
    @IBOutlet weak var lblCardNum: UILabel!
    @IBOutlet weak var lblBankName: UILabel!

    var cellType : Int64!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 20.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.darkGray.cgColor
        lblCardNum.font = UIFont.igFont(ofSize: 20 , weight: .bold)
        lblBankName.font = UIFont.igFont(ofSize: 15 , weight: .bold)
//        lblBankName.textAlignment = lblBankName.localizedDirection
//        imgBackground.layer.cornerRadius = 15.0
//        imgBackground.layer.masksToBounds = true
    }
}

