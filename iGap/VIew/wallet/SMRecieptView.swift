//
//  SMIsDefaultCard.swift
//  PayGear
//
//  Created by a on 4/12/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit

protocol HandleReciept {
    func close()
    func screenView()
}


class SMRecieptView: UIView{
    
    var delegate : HandleReciept?
    var finishDelegate : HandleDefaultCard?
    
    @IBOutlet weak var dataStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var recieptColor: UIView!
    @IBOutlet weak var statusImage: UIImageView!
    
	@IBOutlet weak var saveReciept: UIButton!
	@IBOutlet weak var closeReciept: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> SMRecieptView {
        return UINib(nibName: "RecieptView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMRecieptView
    }
    
    
    @IBAction func closeButton(_ sender: Any) {
        delegate?.close()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        delegate?.screenView()
    }
   
    func setupUI(){

		saveReciept.setTitle("ذخیره".localized, for: .normal)
		closeReciept.setTitle("بستن".localized, for: .normal)
		titleLabel.text = "پرداخت موفق".localized
        
        saveReciept.layer.cornerRadius = saveReciept.frame.height / 2
        saveReciept.layer.borderWidth = 0.5
        saveReciept.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        closeReciept.layer.cornerRadius = closeReciept.frame.height / 2
        closeReciept.layer.borderWidth = 0.5
        closeReciept.layer.borderColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

}
