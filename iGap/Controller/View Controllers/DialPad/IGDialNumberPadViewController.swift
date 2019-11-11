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

class IGDialNumberPadViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tfInputNumbers: UITextField!
    @IBOutlet weak var numberOne: UIButtonX!
    @IBOutlet weak var numberTwo: UIButtonX!
    @IBOutlet weak var numberThree: UIButtonX!
    @IBOutlet weak var numberFour: UIButtonX!
    @IBOutlet weak var numberFive: UIButtonX!
    @IBOutlet weak var numberSix: UIButtonX!
    @IBOutlet weak var numberSeven: UIButtonX!
    @IBOutlet weak var numberEight: UIButtonX!
    @IBOutlet weak var numberNine: UIButtonX!
    @IBOutlet weak var numberZero: UIButtonX!
    @IBOutlet weak var numberStar: UIButtonX!
    @IBOutlet weak var numberDelete: UIButtonX!
    
    var inputNumbersArray : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        hideDefaultKeyboard(textfield: tfInputNumbers)
        
    }
    func updateTfInputNumbers(number:String,insert : Bool!,tmpTXT : String!) {
        
        if insert {
            inputNumbersArray.append(number)
            tfInputNumbers.text = tmpTXT + number
            
        }
        else {
            
            inputNumbersArray =  inputNumbersArray.dropLast()
            tfInputNumbers.text = String(tfInputNumbers.text!.dropLast())
        }
        if inputNumbersArray.count > 0 {
            for number in inputNumbersArray {
            }
        }
        else {
            tfInputNumbers.text = ""
        }
    }
    func hideDefaultKeyboard(textfield : UITextField) {
        let dummyView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        textfield.inputView = dummyView as? UIInputView
    }
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_ACCOUNT_PHONENUMBER".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    // MARK: - Actions
    @IBAction func didTapOnOne(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "1", insert: true, tmpTXT: tfInputNumbers.text!)
    }
    @IBAction func didTapOnTwo(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "2", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnThree(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "3", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnFour(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "4", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnFive(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "5", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnSix(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "6", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnSeven(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "7", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnEight(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "8", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnNine(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "9", insert: true, tmpTXT: tfInputNumbers.text!)
        
    }
    @IBAction func didTapOnZero(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "0", insert: true, tmpTXT: tfInputNumbers.text!)
    }
    @IBAction func didTapOnStar(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "*", insert: true, tmpTXT: tfInputNumbers.text!)
    }
    @IBAction func didTapOnDelete(_ sender: Any) {
        AudioServicesPlaySystemSound(1103);
        updateTfInputNumbers(number: "", insert: false, tmpTXT: tfInputNumbers.text!)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
