/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation
import UIKit

class phoneBookCellTypeTwo: UITableViewCell {

    @IBOutlet weak var lblIcon : UILabel!
    @IBOutlet weak var lblText : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblText.textAlignment = lblText.localizedDirection
        lblText.textColor = ThemeManager.currentTheme.LabelColor
        lblIcon.textColor = ThemeManager.currentTheme.LabelColor
        lblIcon.textAlignment = .center
        lblIcon.font = UIFont.iGapFonticon(ofSize: 25)
        self.contentView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
    }
}
