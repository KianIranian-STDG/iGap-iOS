//
//  BillCellInner.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/29/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class BillCellInner: BaseTableViewCell {
    


    let lblHeader : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.MBCategoryServices.rawValue.localized
        return lbl

    }()
    let viewHeader : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view

    }()


    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addBGView()

        

    }
    
  
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
