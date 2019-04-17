//
//  SMIsDefaultCard.swift
//  PayGear
//
//  Created by a on 4/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
protocol DefaultStatus {
    func valueChanged(value : Bool)
}

class SMIsDefaultCard: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wholeView: UIView!
    @IBOutlet weak var isDefault: UISwitch!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var delegate:DefaultStatus?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    @IBAction func isDefaultSwitch(_ sender: Any) {
        delegate?.valueChanged(value: (sender as! UISwitch).isOn)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func instanceFromNib() -> SMIsDefaultCard {
        
        return UINib(nibName: "IsDefaultCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMIsDefaultCard
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let direction = SMDirection.PageAffineTransform()
        wholeView.transform = direction
        titleLabel.text = "defaultcard.title".localized
        titleLabel.transform = SMDirection.PageAffineTransform()
        titleLabel.textAlignment = SMDirection.TextAlignment()
    }

    
    
}
