//
//  IGSettingsDataAndStorageTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/26/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGSettingsDataAndStorageTableViewController: BaseTableViewController {
    
    
    @IBOutlet weak var lblStorageUsage: UILabel!
    @IBOutlet weak var lblDataUsage: UILabel!
    @IBOutlet weak var lblWhenUsingMobileData: UILabel!
    @IBOutlet weak var lblWhenConnectedToWIFI: UILabel!
    @IBOutlet weak var lblResetAutoDownload: UILabel!
    @IBOutlet weak var lblGifs: UILabel!
    @IBOutlet weak var lblVideos: UILabel!
    @IBOutlet weak var lblUseLessData: UILabel!
    @IBOutlet weak var lblProxySettings: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Change Strings based On Language
        initChangeLang()
        // MARK: - Initialize Default NavigationBar
        initDefaultNav()
        
        
    }
    
    func initChangeLang() {
        // MARK: - Section 0
        lblStorageUsage.text = "STORAGE_USAGE".localizedNew
        lblDataUsage.text = "DATA_USAGE".localizedNew
        // MARK: - Section 1
        lblWhenUsingMobileData.text = "WHEN_USING_MOBILE_DATA".localizedNew
        lblWhenConnectedToWIFI.text = "WHEN_CONNECTED_TO_WIFI".localizedNew
        lblResetAutoDownload.text = "RESET_AUTO_DOWNLOAD_SETTINGS".localizedNew
        // MARK: - Section 2
        lblGifs.text = "GIFS".localizedNew
        lblVideos.text = "VIDEOS".localizedNew
        // MARK: - Section 3
        lblUseLessData.text = "USE_LESS_DATA".localizedNew
        // MARK: - Section 4
        lblProxySettings.text = "PROXY_SETTINGS".localizedNew
        
    }
    func initDefaultNav() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "DATA_STORAGE".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0 :
            if indexPath.row == 0 {
//                self.tableView.isUserInteractionEnabled = false
                
                performSegue(withIdentifier: "goToStorageUsage", sender: self)
                
            }
            else {
                
            }
        case 1 :
            break
        default :
            break
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return 5
        //Hint: uncomment above line if the settings were available
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            //return 2
            return 1
        case 1:
            return 3
        case 2:
            return 2
        case 3:
            return 1
        case 4:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let containerHeaderView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 1 :
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 2 :
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 3 :
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        case 4 :
            containerHeaderView.textLabel?.font = UIFont.igFont(ofSize: 15)
        default :
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "HEADER_NETWORK_STORAGE_USAGE".localizedNew
        case 1:
            return "HEADER_AUTOMATIC_DOWNLOAD".localizedNew
        case 2:
            return "HEADER_AUTO_PLAY".localizedNew
        case 3:
            return "HEADER_VOICECALLS".localizedNew
        case 4:
            return "HEADER_PROXYE".localizedNew
        default:
            return ""
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
    
}
