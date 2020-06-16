//
//  IGPSInternetPackagesCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/9/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSInternetPackagesCell: BaseTableViewCell {
    
    var indexPath : IndexPath!
    var delegate: chargeDelegate?
    
    var item : IGPSInternetPackages! {
        didSet {
            lblPackageName.text = item.description
            lblAmount.text = "\(item.cost ?? 0)".inRialFormat() + IGStringsManager.Currency.rawValue.localized
        }
    }
    
    let holder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 4.0
        return view
    }()
    
    private let lblPackageName : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 12)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = ""
        lbl.numberOfLines = 0
        return lbl
    }()

    private let lblAmount : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 12)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = ""
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initView() {
        addHolder()
        self.selectionStyle = .none
    }
    
    private func addHolder () {
        backgroundColor = .clear
        addSubview(holder)
        holder.semanticContentAttribute = self.semantic
        
        holder.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        holder.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        holder.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 5).isActive = true
        holder.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5).isActive = true
        holder.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier: 0.8).isActive = true
        
        
        let stk = UIStackView()
        stk.translatesAutoresizingMaskIntoConstraints = false
        stk.distribution = .fillEqually
        stk.alignment = .center
        stk.axis = .horizontal
        stk.semanticContentAttribute = self.semantic
        holder.addSubview(stk)
        stk.centerYAnchor.constraint(equalTo: holder.centerYAnchor).isActive = true
        stk.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true
        stk.leadingAnchor.constraint(equalTo: holder.leadingAnchor,constant: 10).isActive = true
        stk.trailingAnchor.constraint(equalTo: holder.trailingAnchor,constant: -10).isActive = true
        stk.heightAnchor.constraint(equalTo: holder.heightAnchor).isActive = true
        
        stk.addArrangedSubview(lblPackageName)
        stk.addArrangedSubview(lblAmount)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        holder.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        lblPackageName.textColor = ThemeManager.currentTheme.LabelColor
        lblAmount.textColor = ThemeManager.currentTheme.LabelColor
    }
    
}
