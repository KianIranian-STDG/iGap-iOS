//
//  SMHistoryTableViewCell.swift
//  PayGear
//
//  Created by amir soltani on 5/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMHistoryDetailTableViewCell: UITableViewCell {

   

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var sum: UILabel!
    
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initChangeCellLang()
    }
    func initChangeCellLang() {
        if SMLangUtil.lang == "fa" || SMLangUtil.lang == "ar"  {
            
            title.textAlignment = .right
            value.textAlignment = .right
           
        }
        else {
            
            title.textAlignment = .left
            value.textAlignment = .left
        }
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
	
    }

}
