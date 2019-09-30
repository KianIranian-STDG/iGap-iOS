//
//  IGProfileUSerCellTypeTwo.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 9/18/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

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
        lblActionName.textAlignment = lblActionName.localizedNewDirection
        lblActionName.font = UIFont.igFont(ofSize: 15)
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
