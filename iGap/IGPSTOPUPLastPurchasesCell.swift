//
//  IGPSTOPUPLastPurchasesCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/8/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSTOPUPLastPurchasesCell: BaseTableViewCell {
    
    var indexPath : IndexPath!
    var delegate: chargeDelegate?
    
    var item : IGPSLastTopUpPurchases! {
        didSet {
            
            lblPhoneNumber.text = item.phoneNumber?.inLocalizedLanguage()
            lblOperator.text = item.simOperatorTitle
            lblAmount.text = "\(item.amount ?? 0)".inRialFormat() + IGStringsManager.Currency.rawValue.localized        }
    }
    private let holder : UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor.lighter(by: 10)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        return view
    }()
    
    
    
    private let lblPhoneNumber : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 10)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = ""
        return lbl
    }()
    private let lblOperator : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 10)
        lbl.textColor = ThemeManager.currentTheme.LabelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.text = ""
        return lbl
    }()
    private let lblAmount : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 10)
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
    }
    
    
    private func addHolder () {
        addSubview(holder)
        holder.semanticContentAttribute = self.semantic
        
        holder.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        holder.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        holder.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0).isActive = true
        holder.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 0).isActive = true
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
        stk.leadingAnchor.constraint(equalTo: holder.leadingAnchor).isActive = true
        stk.trailingAnchor.constraint(equalTo: holder.trailingAnchor).isActive = true
        stk.heightAnchor.constraint(equalTo: holder.heightAnchor).isActive = true
        
        stk.addArrangedSubview(lblPhoneNumber)
        stk.addArrangedSubview(lblOperator)
        stk.addArrangedSubview(lblAmount)
        
        holder.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            UIApplication.topViewController()?.navigationController?.popViewController(animated: true, completion: {
                sSelf.delegate?.passData(phone: [(sSelf.item.phoneNumber)! : "\(sSelf.item.amount ?? 0)"], currentOperator: sSelf.item!.simOperator!)
            })

        })
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
