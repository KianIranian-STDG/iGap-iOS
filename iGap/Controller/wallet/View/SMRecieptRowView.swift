//
//  SMIsDefaultCard.swift
//  PayGear
//
//  Created by a on 4/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMRecieptRowView: UIView{
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var rialLabel: UILabel!
    @IBOutlet weak var spaceLabel: UILabel!
    @IBOutlet weak var recieptTitleLabel: UILabel!
   
    
    class func instanceFromNib() -> SMRecieptRowView {
        return UINib(nibName: "RecieptRow", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMRecieptRowView
        
    }
    
    func setupUI(){
//        self.transform = SMDirection.PageAffineTransform()
        recieptTitleLabel.textAlignment = valueLabel.localizedNewDirection
        valueLabel.textAlignment = valueLabel.localizedNewDirection
       
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       setupUI()
        
    }

}
