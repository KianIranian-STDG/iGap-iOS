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
        
        initTheme()
    }
    private func initTheme() {
        self.lblGifs.textColor = ThemeManager.currentTheme.LabelColor
        self.lblStorageUsage.textColor = ThemeManager.currentTheme.LabelColor
        self.lblDataUsage.textColor = ThemeManager.currentTheme.LabelColor
        self.lblWhenUsingMobileData.textColor = ThemeManager.currentTheme.LabelColor
        self.lblWhenConnectedToWIFI.textColor = ThemeManager.currentTheme.LabelColor
        self.lblResetAutoDownload.textColor = ThemeManager.currentTheme.LabelColor
        self.lblVideos.textColor = ThemeManager.currentTheme.LabelColor
        self.lblUseLessData.textColor = ThemeManager.currentTheme.LabelColor
        self.lblProxySettings.textColor = ThemeManager.currentTheme.LabelColor
    }
    func initChangeLang() {
        // MARK: - Section 0
        lblStorageUsage.text = IGStringsManager.ManageStorage.rawValue.localized
        // MARK: - Section 1
        // MARK: - Section 2
        lblVideos.text = IGStringsManager.Videos.rawValue.localized
        // MARK: - Section 3
        // MARK: - Section 4
        
    }
    func initDefaultNav() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.DataStorage.rawValue.localized)
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

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
            return IGStringsManager.DiskNetworkUsageHeader.rawValue.localized
        case 1:
            return ""
        case 2:
            return ""
        case 3:
            return ""
        case 4:
            return ""
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
