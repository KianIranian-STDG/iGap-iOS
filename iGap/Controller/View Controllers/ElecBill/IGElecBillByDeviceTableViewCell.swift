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
        self.topViewHolder.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor
        
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
        lblTTlBillNumber.text = "BILL_ID".localized
        lblTTlCustomerAddress.text = "BILL_DETAIL_CUSTOMER_ADD".localized
        lblTTlCustomerName.text = "BILL_DETAIL_CUSTOMER_NAME".localized
        lblDataBillNumber.text = "..."
        lblDataCustomerName.text = "..."
        lblDataCustomerAddress.text = "..."
    }
    
    private func initColors() {
        self.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.topViewHolder.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        lblTTlBillNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlCustomerAddress.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlCustomerName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataCustomerName.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataCustomerAddress.textColor = UIColor(named: themeColor.labelColor.rawValue)
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
