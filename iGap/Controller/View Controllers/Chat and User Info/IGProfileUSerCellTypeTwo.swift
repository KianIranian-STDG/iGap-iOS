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

class IGProfileUSerCellTypeTwo: UITableViewCell {
    @IBOutlet weak var lblActionName : UILabel!
    @IBOutlet weak var lblActionDetail : UISwitch!
    weak var delegate : cellTypeTwoDelegate?

    // the youtuber (Model), you can use your custom model class here
    var tmpSTring : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        defaultInitLabels()
    }
    
    func initLabels(nameLblString : String! = "") {
        
        lblActionName.text = nameLblString
    }
    
    private func defaultInitLabels() {
        lblActionName.textAlignment = lblActionName.localizedDirection
        lblActionName.font = UIFont.igFont(ofSize: 15)
        lblActionName.textColor = ThemeManager.currentTheme.LabelColor
        lblActionDetail.onTintColor = ThemeManager.currentTheme.SliderTintColor

    }
    
    @IBAction func muteSwitchTapped(_ sender: UISwitch) {
        delegate?.didPressMuteSwitch()
    }
    
    override func prepareForReuse() {
        lblActionName.text = nil
    }

}

protocol cellTypeTwoDelegate : class {
    func didPressMuteSwitch()
}
