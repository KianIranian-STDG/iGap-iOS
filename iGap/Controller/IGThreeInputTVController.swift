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

class IGThreeInputTVController: BaseTableViewController {

    var mode : String = "NEWS_COMMENTS"
    var articleID : String = ""
    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var userInDb : IGRegisteredUser!
    @IBOutlet weak var lblFirstRow : UILabel!
    @IBOutlet weak var lblSecondRow : UILabel!
    @IBOutlet weak var lblThirdRow : UILabel!
    
    @IBOutlet weak var tfFirstRow : UITextField!
    @IBOutlet weak var tfSecondRow : UITextField!
    @IBOutlet weak var tfThirdRow : UITextField!
    
    @IBOutlet weak var btnSubmit : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()
        fetchUSerInfo()
        
        switch mode {
        case "NEWS_COMMENTS" :
            initNewsComments()
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
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblFirstRow.textColor = ThemeManager.currentTheme.LabelColor
        lblThirdRow.textColor = ThemeManager.currentTheme.LabelColor
        lblSecondRow.textColor = ThemeManager.currentTheme.LabelColor
        
        tfFirstRow.textColor = ThemeManager.currentTheme.LabelColor
        tfSecondRow.textColor = ThemeManager.currentTheme.LabelColor
        tfThirdRow.textColor = ThemeManager.currentTheme.LabelColor
        //borders color set
        tfFirstRow.backgroundColor = ThemeManager.currentTheme.TextFieldBackGround
        tfSecondRow.backgroundColor = ThemeManager.currentTheme.TextFieldBackGround
        tfThirdRow.backgroundColor = ThemeManager.currentTheme.TextFieldBackGround
        btnSubmit.backgroundColor = ThemeManager.currentTheme.SliderTintColor

    }
    private func fetchUSerInfo() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

        
        
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
    
  
    
    @IBAction func didTapOnPost(_ sender: UIButton) {
        postComment()
    }
    
    private func postComment() {
        IGApiNews.shared.postComment(articleid: self.articleID,comment: tfThirdRow.text ?? "", author: tfFirstRow.text!,email: tfThirdRow.text ?? "" , completion: {(success, response, errorMessage) in
            SMLoading.hideLoadingPage()
            if success {
                print("successfully Posted")
                if response?.success == "true" {

                    self.dismiss(animated: true, completion: {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.addComment.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.successComment.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    })

                } else if response?.success == "false" {
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.addComment.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.GlobalTryAgain.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                }
            } else {
                print(errorMessage)
            }
        })
    }
    private func initNewsComments() {
        lblFirstRow.text = IGStringsManager.FirstName.rawValue.localized
        lblSecondRow.text = IGStringsManager.Email.rawValue.localized
        lblThirdRow.text = IGStringsManager.WhatsUrComment.rawValue.localized
        
        btnSubmit.setTitle(IGStringsManager.Send.rawValue.localized, for: .normal)
        btnSubmit.setTitleColor(UIColor.white, for: .normal)
        btnSubmit.backgroundColor = UIColor.iGapGreen()
        btnSubmit.layer.cornerRadius = 10
        
        let indexPath1 = IndexPath(row: 4, section: 0)
        let indexPath2 = IndexPath(row: 5, section: 0)
        let indexPath3 = IndexPath(row: 6, section: 0)
        self.tableView.insertRows(at: [indexPath1,indexPath2,indexPath3], with: .automatic)
        
        tfFirstRow.text = userInDb.username
        tfThirdRow.text = userInDb.email

    }
    private func initFont() {
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 15)
        
        lblFirstRow.textColor = UIColor.darkGray
        lblSecondRow.textColor = UIColor.darkGray
        lblThirdRow.textColor = UIColor.darkGray

        lblFirstRow.font = UIFont.igFont(ofSize: 13)
        lblSecondRow.font = UIFont.igFont(ofSize: 13)
        lblThirdRow.font = UIFont.igFont(ofSize: 13)

        tfFirstRow.font = UIFont.igFont(ofSize: 13)
        tfSecondRow.font = UIFont.igFont(ofSize: 13)
        tfThirdRow.font = UIFont.igFont(ofSize: 13)
        
        lblFirstRow.textAlignment = .right
        lblSecondRow.textAlignment = .right
        lblThirdRow.textAlignment = .right

        tfFirstRow.textAlignment = .center
        tfSecondRow.textAlignment = .center
        tfThirdRow.textAlignment = .center

        
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

extension IGThreeInputTVController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(500)
        } else {
            return .contentHeight(300)
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
