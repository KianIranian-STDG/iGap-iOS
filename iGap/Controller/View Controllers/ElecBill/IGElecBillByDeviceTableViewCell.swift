/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import IGProtoBuff
import PecPayment
import RealmSwift
import SwiftEventBus

class IGElecBillByDeviceTableViewCell: BaseTableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var lblTTlBillNumber : UILabel!
    @IBOutlet weak var lblDataBillNumber : UILabel!
    @IBOutlet weak var lblTTlCustomerName : UILabel!
    @IBOutlet weak var lblDataCustomerName : UILabel!
    @IBOutlet weak var lblTTlCustomerAddress : UILabel!
    @IBOutlet weak var lblDataCustomerAddress : UILabel!
    @IBOutlet weak var topViewHolder : UIViewX!
    @IBOutlet weak var stackHolder : UIStackView!
    @IBOutlet var stackHolderInner : [UIStackView]!
    
    // MARK: - Variables
    var userPhoneNumber : String!
    // MARK: - View LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }
    // MARK: - Development Funcs
    private func initView() {
        initFont()
        initAlignments()
        initColors()
        initStrings()
        customiseView()
    }
    
    
    private func customiseView() {
        self.topViewHolder.borderWidth = 0.5
        self.topViewHolder.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        
        self.semanticContentAttribute = self.semantic
        self.stackHolder.semanticContentAttribute = self.semantic
        for stk in stackHolderInner {
            stk.semanticContentAttribute = self.semantic
        }
        
    }
    
    private func initFont() {
        lblTTlBillNumber.font = UIFont.igFont(ofSize: 14)
        lblTTlCustomerAddress.font = UIFont.igFont(ofSize: 14)
        lblTTlCustomerName.font = UIFont.igFont(ofSize: 14)
        lblDataBillNumber.font = UIFont.igFont(ofSize: 14)
        lblDataCustomerName.font = UIFont.igFont(ofSize: 14)
        lblDataCustomerAddress.font = UIFont.igFont(ofSize: 14)
    }
    
    private func initStrings() {
        lblTTlBillNumber.text = IGStringsManager.ElecBillID.rawValue.localized
        lblTTlCustomerAddress.text = IGStringsManager.ElecCustomerAdd.rawValue.localized
        lblTTlCustomerName.text = IGStringsManager.ElecCustomerName.rawValue.localized
        lblDataBillNumber.text = "..."
        lblDataCustomerName.text = "..."
        lblDataCustomerAddress.text = "..."
    }
    
    private func initColors() {
        self.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        self.topViewHolder.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        lblTTlBillNumber.textColor = ThemeManager.currentTheme.LabelColor
        lblTTlCustomerAddress.textColor = ThemeManager.currentTheme.LabelColor
        lblTTlCustomerName.textColor = ThemeManager.currentTheme.LabelColor
        lblDataBillNumber.textColor = ThemeManager.currentTheme.LabelColor
        lblDataCustomerName.textColor = ThemeManager.currentTheme.LabelColor
        lblDataCustomerAddress.textColor = ThemeManager.currentTheme.LabelColor
    }
    
    private func initAlignments() {
        lblTTlBillNumber.textAlignment = lblTTlBillNumber.localizedDirection
        lblTTlCustomerAddress.textAlignment = lblTTlCustomerAddress.localizedDirection
        lblTTlCustomerName.textAlignment = lblTTlCustomerName.localizedDirection
        lblDataCustomerAddress.textAlignment = lblDataCustomerAddress.localizedDirection
        lblDataCustomerName.textAlignment = lblDataCustomerName.localizedDirection
        lblDataBillNumber.textAlignment = lblDataBillNumber.localizedDirection
    }
    
    func setBillsData(billData: billByDeviceStruct!) {
        lblDataCustomerAddress.text = billData.billIdentifier?.inLocalizedLanguage()
        lblDataBillNumber.text = billData.serviceAdd?.inLocalizedLanguage()
        lblDataCustomerName.text = (billData.customerName ?? "") + (billData.customerFamily ?? "")
    }
    // MARK: - Actions
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
