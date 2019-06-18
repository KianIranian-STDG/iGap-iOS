//
//  multiForwardShareUsers.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/18/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class multiForwardShareUsers: UICollectionViewCell {
    @IBOutlet weak var btnCheckMark: UIButtonX!
    @IBOutlet weak var viewHolder: UIViewX!
    @IBOutlet weak var imgUser: UIImageViewX!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInitials: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.height = 80.0
        self.btnCheckMark.isHidden = true
        self.viewHolder.layer.borderWidth = 0.0

    }
    func setImage(avatar: IGAvatar?=nil,initials: String?,color:String) {
        self.imgUser!.image = nil
        self.lblInitials!.text = initials
        let color = UIColor.hexStringToUIColor(hex: color)
        self.viewHolder!.backgroundColor = color
        
        if let avatar = avatar {
            self.imgUser!.setImage(avatar: avatar)
        }

    }
}
