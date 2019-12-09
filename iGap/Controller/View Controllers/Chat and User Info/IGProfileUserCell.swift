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

class IGProfileUserCell: BaseTableViewCell {

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
        lblActionName.textAlignment = lblActionName.localizedDirectionDescriptions
        lblActionDetail.textAlignment = lblActionDetail.localizedDirectionDescriptions
        lblActionDetail.font = UIFont.igFont(ofSize: 15)
        lblActionName.font = UIFont.igFont(ofSize: 15)

    }
    private func changedInitLabels() {
        if self.isRTL {
            lblActionDetail.textAlignment = .right
        } else {
            lblActionDetail.textAlignment = .left
        }
        lblActionName.textAlignment = lblActionName.localizedDirectionDescriptions
        lblActionDetail.font = UIFont.igFont(ofSize: 15)
        lblActionName.font = UIFont.igFont(ofSize: 15)

    }
    override func prepareForReuse() {
        lblActionName.text = nil
        lblActionDetail.text = nil
        lblActionDetail.textColor = ThemeManager.currentTheme.LabelColor
        lblActionName.textColor = ThemeManager.currentTheme.LabelColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
