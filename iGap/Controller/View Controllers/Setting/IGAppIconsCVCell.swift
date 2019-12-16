//
//  IGColorsSetCVCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/9/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGAppIconsCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewColorOuter: UIView!
    @IBOutlet weak var viewColorInner: UIView!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblbIconName: UILabel!

      override func awakeFromNib() {
          super.awakeFromNib()
          initView()
      }
    private func initView() {
        viewColorOuter.layer.cornerRadius = 10
//        viewColorInner.layer.cornerRadius = 10
        viewColorInner.clipsToBounds = true
        lblbIconName.font = UIFont.igFont(ofSize: 12)
        viewColorOuter.layer.borderWidth = 0
        self.viewColorOuter.layer.borderColor = ThemeManager.currentTheme.SliderTintColor.cgColor


    }
}
