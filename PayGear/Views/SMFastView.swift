//
//  SMFastView.swift
//  PayGear
//
//  Created by amir soltani on 4/29/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

public enum CardIdentifierType {
	case cardNumber
	case cardToken
	case none
}

protocol handleOk {
    func okpressed(amountStr:String? , cardNumber : String?)
}

class SMFastView: UIView{
	
	@IBOutlet weak var amountHeaderView: UIView!

    @IBOutlet weak var cardButton: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var okButton: SMBottomButton!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shabaInfoButton: UIButton!
    @IBOutlet weak var paygearBalance: UILabel!
    @IBOutlet weak var cashableBalance: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cardPicker: UIPickerView!
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    @IBOutlet weak var secondTextFieldView: UIView!
	
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var cashableAmountLabel: UILabel!
	@IBOutlet weak var firstTitleLabel: UILabel!
	@IBOutlet weak var savedCardBtn: UIButton!
	
	public var cardType : CardIdentifierType = .none
    var type = "fast"
    var delegate : handleOk?
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : SMFonts.IranYekanRegular(15),
        NSAttributedString.Key.foregroundColor : UIColor.init(netHex: 0x03a9f4),
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    

    class func instanceFromNib(type : String) -> SMFastView {
        let view = UINib(nibName: "Fast", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMFastView
        view.type = type
        return view
        
    }
    
	@IBAction func saveCardDidSelect(_ sender: Any) {
		
	}
	@IBAction func okPressed(_ sender: Any) {
		
		switch cardType {
		case .cardNumber:
			delegate?.okpressed(amountStr: amountTextField.text, cardNumber: secondTextField.text)
		case .cardToken:
			delegate?.okpressed(amountStr: amountTextField.text, cardNumber: "")

		default:
			//do not anything
			delegate?.okpressed(amountStr: amountTextField.text, cardNumber: secondTextField.text)
		}
    }
    
    override func layoutSubviews() {
       super.layoutSubviews()
        okButton.enable()
        self.amountTextField.inputView = LNNumberpad.default()
        self.secondTextField.inputView = LNNumberpad.default()
        amountTextField.layer.cornerRadius = 12
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.borderColor = SMColor.Silver.cgColor
        amountTextField.clipsToBounds = true
        secondTextFieldView.layer.cornerRadius = 12
        secondTextFieldView.layer.borderWidth = 1
        secondTextFieldView.layer.borderColor = SMColor.Silver.cgColor
        secondTextFieldView.clipsToBounds = true
        secondTextField.layer.cornerRadius = 12
        secondTextField.layer.borderWidth = 0
		
        amountLabel.text = "paygear_account_balance".localized
		cashableAmountLabel.text = "cashable_balance".localized
		firstTitleLabel.text = "amount_to_cash".localized
		amountTextField.placeholder = "cashout.amount.placeholder".localized
        if type == "fast"{
            secondTextField.placeholder = "destination.placeholder".localized//"destination.placeholder"
            descriptionLabel.text = "destination.desc".localized//"destination.desc"
//            cardButton.isHidden = false
            shabaInfoButton.isHidden = true
            secondTitleLabel.text = "destination.title".localized
        }
        else if type == "nor"{
            secondTextField.placeholder = "shaba.placeholder".localized
            descriptionLabel.text = "shaba.desc".localized
            shabaInfoButton.isHidden = false
            let attributeString = NSMutableAttributedString(string: "shaba.info".localized,attributes: yourAttributes)
            shabaInfoButton.setAttributedTitle(attributeString, for: .normal)
            secondTitleLabel.text = "shaba.title".localized
//            cardButton.isHidden = true
        }
        else{
            
            secondTextField.placeholder = SMUserManager.fullName
            secondTextField.isEnabled = false
            descriptionLabel.isHidden = true
            shabaInfoButton.isHidden = true
//            let attributeString = NSMutableAttributedString(string: "shaba.info".localized,attributes: yourAttributes)
            shabaInfoButton.isHidden = true
            secondTitleLabel.text = "برداشت به کیف پول"
            
            
        }
		
		let transform = SMDirection.PageAffineTransform()
		amountHeaderView.transform = transform
		paygearBalance.transform = transform
		cashableBalance.transform = transform
		amountLabel.transform = transform
		cashableAmountLabel.transform = transform
		
		let alignment = SMDirection.TextAlignment()
		amountLabel.textAlignment = alignment
		cashableAmountLabel.textAlignment = alignment
        firstTitleLabel.textAlignment = alignment
        secondTitleLabel.textAlignment = alignment
		cashableBalance.textAlignment = (alignment == .right) ? .left : .right
		paygearBalance.textAlignment = (alignment == .right) ? .left : .right
		shabaInfoButton.contentHorizontalAlignment = (alignment == .right) ? .right : .left
		
        okButton.layer.cornerRadius = okButton.frame.height / 2
        okButton.setTitle("OK".localized, for: .normal)
    }
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        }
}
