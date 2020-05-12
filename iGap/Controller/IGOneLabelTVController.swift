//
//  IGThreeInputTVController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftEventBus

class IGOneLabelTVController: BaseTableViewController {
    var issecuredPass : Bool = false

    var mode : String = "SHEBA_CARD"
    var ShebaNumber : String = "...."

    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var userInDb : IGRegisteredUser!

    @IBOutlet weak var lblHeader : UILabel!
    @IBOutlet weak var lblFirstRow : UILabel!

    @IBOutlet weak var btnSubmit : UIButton!
    @IBOutlet weak var btnCopy : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initServices() // get Sheba number

        initFont()

        
        switch mode {
        case "SHEBA_CARD" :
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
        
    }
    private func initServices() {
        lblFirstRow.text = ShebaNumber.inLocalizedLanguage()
        
    }
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblHeader.textColor = ThemeManager.currentTheme.LabelColor
        lblFirstRow.textColor = ThemeManager.currentTheme.LabelColor

        btnSubmit.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IGThreeInputTVController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        requestShebaNumber()

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
    
  
    
    @IBAction func didTapOnInquery(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapOnCopy(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        if lblFirstRow.text != "" && lblFirstRow.text != IGStringsManager.FetchingInfo.rawValue.localized {
            pasteboard.string = lblFirstRow.text!
            IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.TextCopied.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})

        } else {
            IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: IGStringsManager.GlobalCanNotCopy.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
        }

    }

    
    
    private func initView() {
        lblHeader.text = IGStringsManager.ShebaNumber.rawValue.localized
//        lblFirstRow.text = "...."

        
        btnSubmit.setTitle(IGStringsManager.GlobalClose.rawValue.localized, for: .normal)
        btnSubmit.setTitleColor(UIColor.white, for: .normal)
        btnSubmit.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        btnSubmit.layer.cornerRadius = 20

        btnCopy.setTitle(IGStringsManager.Copy.rawValue.localized, for: .normal)
        btnCopy.setTitleColor(ThemeManager.currentTheme.SliderTintColor, for: .normal)
        btnCopy.backgroundColor = UIColor.clear

        
        let indexPath0 = IndexPath(row: 3, section: 0)
        let indexPath1 = IndexPath(row: 4, section: 0)

        self.tableView.insertRows(at: [indexPath0,indexPath1], with: .automatic)

        lblFirstRow.semanticContentAttribute = self.semantic
        btnCopy.semanticContentAttribute = self.semantic
        
        
    }
    private func initFont() {
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnCopy.titleLabel?.font = UIFont.igFont(ofSize: 15)

        lblHeader.textColor = UIColor.darkGray
        lblFirstRow.textColor = UIColor.darkGray

        lblHeader.font = UIFont.igFont(ofSize: 13)
        lblFirstRow.font = UIFont.igFont(ofSize: 13)

        
        lblFirstRow.textAlignment = lblFirstRow.localizedDirection
        lblHeader.textAlignment = lblHeader.localizedDirection
    }
    


    
    private func requestShebaNumber() {
        lblFirstRow.text = IGStringsManager.FetchingInfo.rawValue.localized
        guard let deposit = IGMBUser.current.currentDeposit else {
            return
        }
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiMobileBank.shared.getShebaNumber(depositNumber: deposit.depositNumber!) {[weak self] (shebaNumber, error) in
            
            guard let sSelf = self else {
                return
            }
            
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
            }
            
            IGLoading.hideLoadingPage()
            sSelf.lblFirstRow.text = shebaNumber!.inLocalizedLanguage()
            
            
        }
        
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

extension IGOneLabelTVController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(200)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(200)
        } else {
            return .contentHeight(200)
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
    
    
}
