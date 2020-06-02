//
//  IGMBPayLoanTVController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEventBus

class IGMBPayLoanTVController: BaseTableViewController {
    var issecuredPass : Bool = false
    let transparentView = UIView()
    var selectedButton = UIButton()
    let backView = DropBackView()
    var selectedLoan : String = ""
    var mode : String = "BLOCK_CARD"
    var articleID : String = ""
    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var isCustomAccount = true
    var userInDb : IGRegisteredUser!
    var payAmount: String = "0"
    var payAccount : String = "0"
    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var lblAccount : UILabel!
    @IBOutlet weak var lblSecondaryPass : UILabel!

    @IBOutlet weak var tfAmount : UITextField!
    @IBOutlet weak var tfAccount : UITextField!
    @IBOutlet weak var tfSecondaryPass : UITextField!

    @IBOutlet weak var btnPay : UIButton!
    @IBOutlet weak var btnAccounts : UIButton!
    @IBOutlet weak var btnCustomDepo : UIButton!
    @IBOutlet weak var btnDefaultDepo : UIButton!

    private let defaultCheckMark : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1.0
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        return view
    }()
    private let customCheckMark : UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1.0
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()

        
        switch mode {
        case "PAY_LOAN" :
            initView()
            break
        default :
            break
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        initTheme()
        addCheckMarks()
        //cardsDropDown
        SwiftEventBus.onMainThread(self, name: EventBusManager.DroppDownPicked) { result in
            self.tfAccount.text = result?.object as? String
            self.removeTransparentView()
        }

        
    }
    
    func addTransparentView(frames: CGRect) {
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
//        cardTable.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        backView.backgroundColor = .red
        self.view.addSubview(backView)
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
//        self.view.addSubview(cardTable)
//        cardTable.layer.cornerRadius = 5
        
        backView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(IGMBUser.current.deposits.count * 50))

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
//        cardTable.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
//            self.cardTable.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(IGMBUser.current.deposits.count * 50))
        }, completion: nil)
    }
        @objc func removeTransparentView() {
            let frames = selectedButton.frame
    //        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentView.alpha = 0
//                self.cardTable.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)

            backView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)

            //        }, completion: nil)
        }
    private func addCheckMarks() {
        btnDefaultDepo.addSubview(defaultCheckMark)
        defaultCheckMark.translatesAutoresizingMaskIntoConstraints = false
        defaultCheckMark.leftAnchor.constraint(equalTo: btnDefaultDepo.leftAnchor, constant: 10).isActive = true
        defaultCheckMark.centerYAnchor.constraint(equalTo: btnDefaultDepo.centerYAnchor, constant: 0).isActive = true
        defaultCheckMark.widthAnchor.constraint(equalTo: btnDefaultDepo.heightAnchor, multiplier: 0.5).isActive = true
        defaultCheckMark.heightAnchor.constraint(equalTo: btnDefaultDepo.heightAnchor, multiplier: 0.5).isActive = true

        btnCustomDepo.addSubview(customCheckMark)
        customCheckMark.translatesAutoresizingMaskIntoConstraints = false
        customCheckMark.leftAnchor.constraint(equalTo: btnCustomDepo.leftAnchor, constant: 10).isActive = true
        customCheckMark.centerYAnchor.constraint(equalTo: btnCustomDepo.centerYAnchor, constant: 0).isActive = true
        customCheckMark.widthAnchor.constraint(equalTo: btnCustomDepo.heightAnchor, multiplier: 0.5).isActive = true
        customCheckMark.heightAnchor.constraint(equalTo: btnCustomDepo.heightAnchor, multiplier: 0.5).isActive = true
    }
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        lblAmount.textColor = ThemeManager.currentTheme.LabelColor
        lblAccount.textColor = ThemeManager.currentTheme.LabelColor
        lblSecondaryPass.textColor = ThemeManager.currentTheme.LabelColor

        tfAmount.textColor = ThemeManager.currentTheme.LabelColor
        tfAccount.textColor = ThemeManager.currentTheme.LabelColor
        tfSecondaryPass.textColor = ThemeManager.currentTheme.LabelColor


        tfAmount.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfAccount.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfSecondaryPass.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor

        tfAmount.layer.borderWidth = 1.0
        tfAccount.layer.borderWidth = 1.0
        tfSecondaryPass.layer.borderWidth = 1.0

        tfAmount.layer.cornerRadius = 8.0
        tfAccount.layer.cornerRadius = 8.0
        tfSecondaryPass.layer.cornerRadius = 8.0

        //borders color set
        tfAccount.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        tfAmount.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        tfSecondaryPass.backgroundColor = ThemeManager.currentTheme.BackGroundColor

        btnPay.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        btnCustomDepo.backgroundColor = UIColor.clear
        btnAccounts.backgroundColor = UIColor.clear
        btnAccounts.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnDefaultDepo.backgroundColor = UIColor.clear
        let lblArrow = UILabel()
        lblArrow.font = UIFont.iGapFonticon(ofSize: 15)
        lblArrow.textColor = .darkGray
        lblArrow.text = ""
        tfAccount.rightView = lblArrow
        tfAccount.rightViewMode = .always
        tfAccount.isEnabled = false
        btnAccounts.addTarget(self, action: #selector(didTapOnAccounts(sender:)), for: .touchUpInside)
        tfAccount.text = payAccount.inEnglishNumbersNew()
        tfAmount.text = payAmount.inEnglishNumbersNew()
    }
    @objc func didTapOnAccounts(sender: UIButton) {
        addTransparentView(frames: btnAccounts.frame)

     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    @objc func keyboardWillShow(notification: NSNotification) {
        //Do something here
        print("KEYBOARD DID APPEAR")
        
        isKeyboardPresented = true
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        //Do something here
        print("KEYBOARD DID DISAPPEAR")
        isKeyboardPresented = false
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)
    }
    
    @IBAction func didTapOnPay(_ sender: UIButton) {
        //        SwiftEventBus.post("didRequestHotCard", sender: ["cardNumber": lblFirstRow.text ?? "", "password": lblSecondRow.text ?? "", "cvv2": lblThirdRow.text ?? "", "exp_year": "99", "exp_month": "8"])
        payRequest()
        
        
    }
    private func payRequest() {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiMobileBank.shared.payLoan(loanNumber: selectedLoan.inEnglishNumbersNew(), amount: Int( tfAmount.text!.RemoveingCurrencyFormat().inEnglishNumbersNew())!, secondPass: tfSecondaryPass.text!.inEnglishNumbersNew(), paymentMethod: isCustomAccount ? .CustomDeposit : .DefaultDeposit, depositNumber: isCustomAccount ? tfAccount.text!.inEnglishNumbersNew() : IGMBUser.current.currentDeposit?.depositNumber) { (result, error) in
            if error != nil {
                
                IGLoading.hideLoadingPage()
                
                
                if error!.isAuthError {
                    isMBAuthError = true
                    UIApplication.topViewController()!.navigationController?.pushViewController(IGMBLoginVC(), animated: true)
                } else {
                    isMBAuthError = false
                    IGHelperMBAlert.shared.showCustomAlert(view: UIApplication.topViewController()!, alertType: .oneButton, title: IGStringsManager.GlobalWarning.rawValue.localized, showDoneButton: false, showCancelButton: true, message: error?.message, cancelText: IGStringsManager.GlobalOK.rawValue.localized, isLoading: false) {
                        UIApplication.topViewController()!.dismiss(animated: true, completion: nil)
                    }
                    
                }
                
                return
            } else {
                IGLoading.hideLoadingPage()
                IGHelperMBAlert.shared.showMessageAlert(alertType: .oneButton, title: IGStringsManager.GlobalSuccess.rawValue.localized , doneBackColor: UIColor.hexStringToUIColor(hex: "B6774E"), doneText: IGStringsManager.GlobalClose.rawValue.localized, message: IGStringsManager.SuccessPayment.rawValue.localized,done: {
                    SwiftEventBus.post(EventBusManager.UpdateData,sender: true)
                    self.dismiss(animated: true, completion: nil)

                })
                
            }
        }
    }
    @IBAction func didTapOnCustomDepo(_ sender: UIButton) {
        customCheckMark.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        defaultCheckMark.backgroundColor = .clear
        isCustomAccount = true
        let indexPath = IndexPath(item: 3, section: 0)

        self.tableView.reloadData()
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)


    }
    @IBAction func didTapOnDefaultDepo(_ sender: UIButton) {
        defaultCheckMark.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        customCheckMark.backgroundColor = .clear
        let indexPath = IndexPath(item: 3, section: 0)

        self.tableView.reloadData()
        isCustomAccount = false
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .longForm)


    }

    private func initView() {
        lblHeader.text = IGStringsManager.Pay.rawValue.localized
        lblAmount.text = IGStringsManager.Amount.rawValue.localized
        lblAccount.text = IGStringsManager.AccountNumber.rawValue.localized
        lblSecondaryPass.text = IGStringsManager.MBSecondPass.rawValue.localized

        
        btnPay.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)

        btnPay.layer.cornerRadius = 20
        btnPay.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnPay.setTitleColor(UIColor.white, for: .normal)
        btnCustomDepo.setTitle(IGStringsManager.MBCustomAccount.rawValue.localized, for: .normal)
        btnCustomDepo.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnCustomDepo.setTitleColor(UIColor.darkGray, for: .normal)
        btnDefaultDepo.setTitle(IGStringsManager.MBDefaultAccount.rawValue.localized, for: .normal)
        btnDefaultDepo.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnDefaultDepo.setTitleColor(UIColor.darkGray, for: .normal)

//        let indexPath0 = IndexPath(row: 3, section: 0)
//        let indexPath1 = IndexPath(row: 4, section: 0)
//        let indexPath2 = IndexPath(row: 5, section: 0)
//        let indexPath3 = IndexPath(row: 6, section: 0)
//        let indexPath4 = IndexPath(row: 7, section: 0)
//        self.tableView.insertRows(at: [indexPath0,indexPath1,indexPath2,indexPath3,indexPath4], with: .automatic)

        tfSecondaryPass.isSecureTextEntry = true
        
    }
    private func initFont() {
        
        lblHeader.textColor = UIColor.darkGray
        lblAccount.textColor = UIColor.darkGray
        lblAmount.textColor = UIColor.darkGray
        lblSecondaryPass.textColor = UIColor.darkGray

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblAmount.font = UIFont.igFont(ofSize: 13)
        lblAccount.font = UIFont.igFont(ofSize: 13)
        lblSecondaryPass.font = UIFont.igFont(ofSize: 13)

        tfAmount.font = UIFont.igFont(ofSize: 13)
        tfAccount.font = UIFont.igFont(ofSize: 13)
        tfSecondaryPass.font = UIFont.igFont(ofSize: 13)

        

        lblHeader.textAlignment = .center
        lblAccount.textAlignment = lblAccount.localizedDirection
        lblAmount.textAlignment = lblAmount.localizedDirection
        lblSecondaryPass.textAlignment = lblSecondaryPass.localizedDirection

        tfAmount.textAlignment = .center
        tfAccount.textAlignment = .center
        tfSecondaryPass.textAlignment = .center

        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            switch indexPath.row {
            case 0 : return 46
            case 1 : return 80
            case 2 : return 80
            case 3 : return isCustomAccount ? 80 : 0
            case 4 : return 80
            case 5 : return 70
            case 6 : return 250

            default : return 80
            }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 7
    }


    


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }


}


extension IGMBPayLoanTVController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(isCustomAccount ? 450 : 370)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(isCustomAccount ? 650 : 570)
        } else {
            return .contentHeight(isCustomAccount ? 450 : 370)
        }

    }
    var anchorModalToLongForm: Bool {
        return false
    }


    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    func panModalDidDismiss() {
        print("didDismiss pan modal")
    }
}

class DropBackView : UIView, UITableViewDataSource,UITableViewDelegate {
    let cardTable = UITableView()


    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        cardTable.delegate = self
        cardTable.dataSource = self
        cardTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        addSubview(cardTable)
        cardTable.translatesAutoresizingMaskIntoConstraints = false
        cardTable.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        cardTable.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        cardTable.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        cardTable.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IGMBUser.current.deposits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = IGMBUser.current.deposits[indexPath.row].depositNumber
        cell.textLabel!.textAlignment = .center
        cell.selectionStyle = .none
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftEventBus.post(EventBusManager.DroppDownPicked, sender : IGMBUser.current.deposits[indexPath.row].depositNumber)
    }
    
    
}
