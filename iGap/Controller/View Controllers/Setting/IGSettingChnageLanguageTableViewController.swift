//
//  IGSettingChnageLanguageTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/17/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGSettingChnageLanguageTableViewController: BaseTableViewController {
    
    @IBOutlet weak var lblPersianLang: UILabel!
    @IBOutlet weak var lblEnglishLang: UILabel!
    @IBOutlet weak var lblArabicLang: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLanguage()
    }
    func initChangeLanguage() {
        //        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        
        lblPersianLang.text = SMLangUtil.changeLblText(tag: lblPersianLang.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblEnglishLang.text = SMLangUtil.changeLblText(tag: lblEnglishLang.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblArabicLang.text = SMLangUtil.changeLblText(tag: lblArabicLang.tag, parentViewController: NSStringFromClass(self.classForCoder))
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0 :
            if lastLang == "fa" {

            }
            else {
                
                SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Persian.rawValue)
                let appDelegate = AppDelegate()
                appDelegate.resetApp()

            }
        case 1:
            if lastLang == "en" {
                
            }
            else {
                SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.English.rawValue)
                
                let appDelegate = AppDelegate()
                appDelegate.resetApp()
            }
           

        case 2:
            if lastLang == "ar" {
                
            }
            else {
                SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Persian.rawValue)
                let appDelegate = AppDelegate()
                appDelegate.resetApp()
            }
            

        default :
            break
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
