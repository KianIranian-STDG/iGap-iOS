//
//  IGColorsSetCVCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/9/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGColorsSetCVCell: UICollectionViewCell {
      @IBOutlet weak var btnColor : UIButton!
    
        @IBOutlet weak var viewColorInner : UIView!
    @IBOutlet weak var viewColorOuter: UIView!

      override func awakeFromNib() {
          super.awakeFromNib()
          initView()
      }
    private func initView() {
        viewColorInner.layer.borderWidth = 2

        viewColorOuter.layer.cornerRadius = viewColorOuter.bounds.width / 2
        viewColorInner.layer.cornerRadius = viewColorInner.bounds.width / 2
    }
}
