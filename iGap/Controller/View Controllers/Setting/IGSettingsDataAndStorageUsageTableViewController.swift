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

class IGSettingsDataAndStorageUsageTableViewController: UITableViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var lblKeepMedia : UILabel!
    @IBOutlet weak var lblKeepMediaTime : UILabel!
    @IBOutlet weak var lblCleaCache : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Change Strings based On Language
        initChangeLang()
        // MARK: - Initialize Default NavigationBar
        initDefaultNav()

    }
    func initChangeLang() {
        // MARK: - Section 0
        lblKeepMedia.text = "KEEP_MEDIA".localized
        lblKeepMediaTime.text = "..."
        // MARK: - Section 1
        lblCleaCache.text = "CLEAR_CACHE".localized
        
    }
    func initDefaultNav() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "STORAGE_USAGE".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
    }
    //MARK: - TableView Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
        
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "showCacheSetting", sender: self)

            }
        default:
            break
        }
        
    }
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let containerFooterView = view as! UITableViewHeaderFooterView
        
        switch section {
        case 0 :
            containerFooterView.textLabel?.font = UIFont.igFont(ofSize: 15)
        default :
            break
            
        }
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "FOOTER_KEEP_MEDIA".localized
        default:
            return ""
        }
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 80
        default:
            return 0
        }
    }

  
}
