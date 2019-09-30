//
//  IGProfileUserCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/18/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGProfileUserCell: UITableViewCell {

    @IBOutlet weak var lblActionName : UILabel!
    @IBOutlet weak var lblActionDetail : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initLabels(nameLblString : String! = "",detailLblString : String! = "",changeColor : Bool! = false,shouldChangeDetailDirection : Bool! = false) {
        
        lblActionName.text = nameLblString
        lblActionDetail.text = detailLblString
        if changeColor {
            if shouldChangeDetailDirection {
                lblActionDetail.textColor = UIColor.iGapRed()
            } else {
                lblActionName.textColor = UIColor.iGapRed()
            }
        }
        if shouldChangeDetailDirection {
            changedInitLabels()
        } else {
            defaultInitLabels()
        }

    }
    private func defaultInitLabels() {
        lblActionName.textAlignment = lblActionName.localizedNewDirection
        lblActionDetail.textAlignment = lblActionDetail.localizedNewDirection
        lblActionDetail.font = UIFont.igFont(ofSize: 15)
        lblActionName.font = UIFont.igFont(ofSize: 15)

    }
    private func changedInitLabels() {
        if  lastLang == Language.persian.rawValue  {
            lblActionDetail.textAlignment = .left

        } else if  lastLang == Language.english.rawValue  {
            lblActionDetail.textAlignment = .right

        } else {
            
        }
        lblActionName.textAlignment = lblActionName.localizedNewDirection
        lblActionDetail.font = UIFont.igFont(ofSize: 15)
        lblActionName.font = UIFont.igFont(ofSize: 15)

    }
    override func prepareForReuse() {
        lblActionName.text = nil
        lblActionDetail.text = nil
        lblActionDetail.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblActionName.textColor = UIColor(named: themeColor.labelColor.rawValue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
