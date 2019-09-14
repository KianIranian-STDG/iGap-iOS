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
import RealmSwift
class IGSettingAboutTableViewController: BaseTableViewController {
    
    var index : Int?
    var appstoreWebView : Bool = false
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var lblCurrent: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblBlog: UILabel!
    @IBOutlet weak var lblSupport: UILabel!

    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "ABOUT".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersionLabel.text = version
        }
        
        //appVersionLabel.text = Bundle.main.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblBlog.text = "SETTING_ABOUT_IGAP_BLOG".localizedNew
        lblHome.text = "SETTING_ABOUT_IGAP_HOME".localizedNew
        lblSupport.text = "SETTING_ABOUT_SUPPORT_REQUEST".localizedNew
        lblCurrent.text = "SETTING_ABOUT_CYRRENT_VERSION".localizedNew
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isUserInteractionEnabled = true
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0 :
            numberOfRows = 1
        case 1 :
            numberOfRows = 3
        default:
            break
        }
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                UIApplication.shared.openURL(URL(string: "itms://itunes.apple.com/us/app/igap/id1198257696?ls=1&mt=8")!)
            }
        }
        */
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                index = indexPath.row
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToWebPage", sender: self)
            case 1:
                index = indexPath.row
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToWebPage", sender: self)
            case 2:
                index = indexPath.row
                self.tableView.isUserInteractionEnabled = false
                performSegue(withIdentifier: "GoToWebPage", sender: self)
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToWebPage" {
            let destination = segue.destination as! IGSettingAboutWebViewViewController
            switch index! {
            case 0:
                destination.pageUrl = "https://www.igap.net"
                destination.pageTitle = "SETTING_ABOUT_IGAP_HOME".localizedNew
            case 1:
                destination.pageUrl = "https://blog.igap.net"
                destination.pageTitle = "SETTING_ABOUT_IGAP_BLOG".localizedNew
            case 2:
                destination.pageUrl = "https://support.igap.net"
                destination.pageTitle = "SETTING_ABOUT_SUPPORT_REQUEST".localizedNew
            default:
                break
            }
            
        }
    }
}
