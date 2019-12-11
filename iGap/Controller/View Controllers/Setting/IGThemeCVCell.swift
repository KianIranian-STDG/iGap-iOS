//
//  IGThemeCVCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/9/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGThemeCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewSender : UIView!
    @IBOutlet weak var viewReciever : UIView!
    @IBOutlet weak var viewBG : UIView!
    @IBOutlet weak var lblThemeName : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    func setCellData() {
        
    }
    private func initView() {
        lblThemeName.font = UIFont.igFont(ofSize: 12)
        viewBG.layer.cornerRadius = 10
        


        viewSender.roundCorners(corners: [.layerMinXMaxYCorner,.layerMinXMinYCorner,.layerMaxXMaxYCorner], radius: 5.0)


        //sample2

        viewReciever.roundCorners(corners: [.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: 5.0)        
        
        viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
        viewBG.layer.borderWidth = 2

        


    }

}
