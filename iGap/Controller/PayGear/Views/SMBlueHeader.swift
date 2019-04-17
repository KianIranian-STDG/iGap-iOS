//
//  SMIsDefaultCard.swift
//  PayGear
//
//  Created by a on 4/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMBlueHeader: UIView,UITextFieldDelegate{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabelValue: UILabel!
    
    class func instanceFromNib() -> SMBlueHeader {
        return UINib(nibName: "blueHeader", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMBlueHeader
    }
	
    func setupUI(){
        self.backgroundColor = SMColor.PrimaryColor
        titleLabel.text = "pay.header.title".localized
    }
	
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

}
