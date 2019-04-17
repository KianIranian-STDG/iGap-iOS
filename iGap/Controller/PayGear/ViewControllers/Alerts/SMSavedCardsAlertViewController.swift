//
//  TextFieldAlertViewController.swift
//  PayGear
//
//  Created by amir soltani on 4/30/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

class SMSavedCardsAlertViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: SMBottomButton!
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var cardsPicker: UIPickerView!
	@IBOutlet var defaultSwitchView: UIView!
	@IBOutlet var defaultSwitchLabel: UILabel!
	@IBOutlet var defaultSwitch: UISwitch!
	
    var dialogT : String?
    var savedCards = [SMCashout]()
	var savedIBANs = [SMIBAN]()
    var leftButtonTitle:String?
    var rightButtonTitle:String?
    var leftButtonAction: SimpleCallBack?
    var rightButtonAction: MoreActionCallBack?
	
	//show switch to check default iban
	var showDefaultSwitch : Bool = false
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        leftButton.setTitle(leftButtonTitle, for: .normal)
        rightButton.setTitle(rightButtonTitle, for: .normal)
        dialogTitle.text = dialogT
        let alignment = SMDirection.TextAlignment()
        dialogTitle.textAlignment = alignment
        cardsPicker.delegate = self
        cardsPicker.dataSource = self
        rightButton.enable()
		
		if showDefaultSwitch {
			defaultSwitchView.isHidden = false
			defaultSwitch.isOn = true
			defaultSwitchLabel.text = "save.as.default".localized
			defaultSwitchLabel.textAlignment = alignment
			
			let transform = SMDirection.PageAffineTransform()
			defaultSwitchView.transform = transform
			defaultSwitchLabel.transform = transform
			defaultSwitch.transform = transform
			
		}
       
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func leftButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        leftButtonAction?()
    }
    @IBAction func rightButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
		if savedCards.count != 0 {
			rightButtonAction?(savedCards[cardsPicker.selectedRow(inComponent: 0)], defaultSwitch.isOn)

		}
		else if savedIBANs.count != 0 {
			
			rightButtonAction?(savedIBANs[cardsPicker.selectedRow(inComponent: 0)], defaultSwitch.isOn)

		}
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if savedCards.count != 0 {
			return savedCards.count
		}
		else if savedIBANs.count != 0 {
			return savedIBANs.count
		}
		return 0
		
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 30
    }
    

    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = SMFonts.IranYekanBold(14)
		if savedCards.count != 0 {
        	let card = savedCards[row]
			let bank = SMBank()
			bank.setBankInfo(code: card.bankCode!)
			label.text = card.pan!.inLocalizedLanguage()

		}
		else if savedIBANs.count != 0 {
			let card = savedIBANs[row]
			label.text = card.ibanNumber!.inLocalizedLanguage()
		}
		/*
		this code shows bank name too but it has a bug on persian numbers
		if SMDirection.TextAlignment() == .left {
			label.text = "\(String(describing: card.pan!.inLocalizedLanguage())) (\(String(describing: bank.nameFA!)))"
		}
		else {
			var st = "«"
			st.append(bank.nameFA!)
			st.append("» ")
			st.append(card.pan!.inLocalizedLanguage())
			
			label.text = st
			
//			\(String(describing: bank.nameFA!))
		}*/
        label.textAlignment = .center
        return label
    }
    
    
    
}
