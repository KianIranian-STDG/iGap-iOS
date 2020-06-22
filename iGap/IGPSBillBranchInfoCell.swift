//
//  IGPSBillMyBillsCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/16/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import IGProtoBuff
import PecPayment

class IGPSBillBranchInfoCell: BaseTableViewCell {
    
    var indexPath : IndexPath!
    let holder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let lblInfo : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13,weight: .bold)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.textAlignment = .center
        lbl.text = "info"
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirectionOposit
        return lbl
    }()
    let lblData : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        lbl.font = UIFont.igFont(ofSize: 13,weight: .bold)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.textAlignment = .center
        lbl.text = "..."
        lbl.numberOfLines = 1
        lbl.textAlignment = lbl.localizedDirection
        return lbl
    }()

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
        holder.semanticContentAttribute = .forceRightToLeft
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initView() {
        addHolder()
        self.selectionStyle = .none
    }
    
    
    private func addHolder () {
        //MARK: Add Holder
        addSubview(holder)
        holder.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        holder.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        holder.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 15).isActive = true
        holder.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -15).isActive = true
        holder.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.8).isActive = true
        

        //MARK: Bill Name
        holder.addSubview(lblInfo)
        lblInfo.centerYAnchor.constraint(equalTo: holder.centerYAnchor).isActive = true
        lblInfo.leadingAnchor.constraint(equalTo: holder.leadingAnchor).isActive = true
        lblInfo.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.4).isActive = true

        holder.addSubview(lblData)
        lblData.centerYAnchor.constraint(equalTo: holder.centerYAnchor).isActive = true
        lblData.leadingAnchor.constraint(equalTo: lblInfo.trailingAnchor).isActive = true
        lblData.trailingAnchor.constraint(equalTo: holder.trailingAnchor).isActive = true
        lblInfo.widthAnchor.constraint(equalTo: holder.widthAnchor,multiplier: 0.4).isActive = true

    }
    
    

    
}
