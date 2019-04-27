//
//  IGWalletSettingTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/13/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGWalletSettingTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var lblChangePassCode : UILabel!
    @IBOutlet weak var lblRessetPassCode : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Wallet Setting")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewCell
        if cell.tag == 0 {
            return 67

        }
        else if cell.tag == 1 {
            let isprotected = SMUserManager.isProtected
            if isprotected! {
                return 67
            }
            else {
                return 0
            }
        }
        else {
            return 67
        }

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewCell

         let isprotected = SMUserManager.isProtected

        let walletSettingInnerPage : IGWalletSettingInnerTableViewController? = storyboard?.instantiateViewController(withIdentifier: "walletSettingInnerPage") as! IGWalletSettingInnerTableViewController
        if cell.tag == 0 {
            walletSettingInnerPage?.isOTP = false
            if isprotected! {
                walletSettingInnerPage?.isFirstTime = false
            }
            else {
                walletSettingInnerPage?.isFirstTime = true

            }
        }
        if cell.tag == 1 {
            walletSettingInnerPage?.isOTP = true

        }
        self.navigationController!.pushViewController(walletSettingInnerPage!, animated: true)

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

}