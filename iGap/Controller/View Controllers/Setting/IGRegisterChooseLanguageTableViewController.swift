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

class IGRegisterChooseLanguageTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UITableView.appearance().semanticContentAttribute = .forceLeftToRight
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        //        label.textColor = UIColor.red
        label.text = "Choose Language - انتخاب زبان"
        
        label.font = UIFont.igFont(ofSize: 15)
        label.textAlignment = .center
        
        return label
        
        
    }
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: " ")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0 :
        
            SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Persian)
            UITableView.appearance().semanticContentAttribute = .forceRightToLeft

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoDissmissLangFANotificationName), object: nil)
            
        case 1:
           
            SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.English)
            UITableView.appearance().semanticContentAttribute = .forceLeftToRight

//                Language.language = Language.english

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoDissmissLangENNotificationName), object: nil)
            
        case 2:
            
            SMLangUtil.changeLanguage(newLang: SMLangUtil.SMLanguage.Persian)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoDissmissLangARNotificationName), object: nil)
            
        default :
            break
        }
    }

}
