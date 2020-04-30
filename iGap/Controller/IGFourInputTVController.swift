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

class IGFourInputTVController: BaseTableViewController {

    var mode : String = "BLOCK_CARD"
    var articleID : String = ""
    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var userInDb : IGRegisteredUser!
    @IBOutlet weak var lblFirstRow : UILabel!
    @IBOutlet weak var lblSecondRow : UILabel!
    @IBOutlet weak var lblThirdRow : UILabel!
    @IBOutlet weak var lblFourRow : UILabel!

    @IBOutlet weak var tfFirstRow : UITextField!
    @IBOutlet weak var tfSecondRow : UITextField!
    @IBOutlet weak var tfThirdRow : UITextField!
    @IBOutlet weak var tfFourRow : UITextField!

    @IBOutlet weak var btnSubmit : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initFont()

        
        switch mode {
        case "BLOCK_CARD" :
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
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        lblFirstRow.textColor = ThemeManager.currentTheme.LabelColor
        lblThirdRow.textColor = ThemeManager.currentTheme.LabelColor
        lblSecondRow.textColor = ThemeManager.currentTheme.LabelColor
        lblFourRow.textColor = ThemeManager.currentTheme.LabelColor

        tfFirstRow.textColor = ThemeManager.currentTheme.LabelColor
        tfSecondRow.textColor = ThemeManager.currentTheme.LabelColor
        tfThirdRow.textColor = ThemeManager.currentTheme.LabelColor
        tfFourRow.textColor = ThemeManager.currentTheme.LabelColor


        tfFirstRow.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfSecondRow.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfThirdRow.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
        tfFourRow.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor

        tfFirstRow.layer.borderWidth = 1.0
        tfSecondRow.layer.borderWidth = 1.0
        tfThirdRow.layer.borderWidth = 1.0
        tfFourRow.layer.borderWidth = 1.0

        tfFirstRow.layer.cornerRadius = 10.0
        tfSecondRow.layer.cornerRadius = 10.0
        tfThirdRow.layer.cornerRadius = 10.0
        tfFourRow.layer.cornerRadius = 10.0

        //borders color set
        tfFirstRow.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        tfSecondRow.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        tfThirdRow.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        tfFourRow.backgroundColor = ThemeManager.currentTheme.BackGroundColor
        btnSubmit.backgroundColor = ThemeManager.currentTheme.SliderTintColor

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
    
  
    
    @IBAction func didTapOnInquery(_ sender: UIButton) {

    }
    
    
    private func initView() {
        lblFirstRow.text = IGStringsManager.FirstName.rawValue.localized
        lblSecondRow.text = IGStringsManager.Email.rawValue.localized
        lblThirdRow.text = IGStringsManager.WhatsUrComment.rawValue.localized
        lblFourRow.text = IGStringsManager.WhatsUrComment.rawValue.localized

        btnSubmit.setTitle(IGStringsManager.Send.rawValue.localized, for: .normal)
        btnSubmit.setTitleColor(UIColor.white, for: .normal)
        btnSubmit.backgroundColor = UIColor.iGapGreen()
        btnSubmit.layer.cornerRadius = 10
        
        let indexPath1 = IndexPath(row: 4, section: 0)
        let indexPath2 = IndexPath(row: 5, section: 0)
        let indexPath3 = IndexPath(row: 6, section: 0)
        let indexPath4 = IndexPath(row: 7, section: 0)
        self.tableView.insertRows(at: [indexPath1,indexPath2,indexPath3,indexPath4], with: .automatic)
        
    }
    private func initFont() {
        btnSubmit.titleLabel?.font = UIFont.igFont(ofSize: 15)
        
        lblFirstRow.textColor = UIColor.darkGray
        lblSecondRow.textColor = UIColor.darkGray
        lblThirdRow.textColor = UIColor.darkGray
        lblFourRow.textColor = UIColor.darkGray

        lblFirstRow.font = UIFont.igFont(ofSize: 13)
        lblSecondRow.font = UIFont.igFont(ofSize: 13)
        lblThirdRow.font = UIFont.igFont(ofSize: 13)
        lblFourRow.font = UIFont.igFont(ofSize: 13)

        tfFirstRow.font = UIFont.igFont(ofSize: 13)
        tfSecondRow.font = UIFont.igFont(ofSize: 13)
        tfThirdRow.font = UIFont.igFont(ofSize: 13)
        tfFourRow.font = UIFont.igFont(ofSize: 13)

        lblFirstRow.textAlignment = .right
        lblSecondRow.textAlignment = .right
        lblThirdRow.textAlignment = .right
        lblFourRow.textAlignment = .right

        tfFirstRow.textAlignment = .center
        tfSecondRow.textAlignment = .center
        tfThirdRow.textAlignment = .center
        tfFourRow.textAlignment = .center

        
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

extension IGFourInputTVController: PanModalPresentable {
    
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
