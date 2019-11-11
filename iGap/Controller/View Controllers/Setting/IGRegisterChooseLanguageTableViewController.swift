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
import maincore
import SwiftEventBus

class IGRegisterChooseLanguageTableViewController: UITableViewController {
    
    private var languagesArray = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        languagesArray = LocaleManager.availableLocalizations.filter({ $0.key != "Base" })
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
        
        print(LocaleManager.availableLocalizations)
        print(languagesArray)
        
        return label
    }
    
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: " ")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
    }
    
    
    //MARK: - tableView dataSource and Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languagesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LangCell", for: indexPath) as? LanguageCell else {
            return LanguageCell()
        }
        
        let language = Array(languagesArray)[indexPath.row]
        cell.langIsoCodeLbl.text = language.key.uppercased()
        cell.langNameLbl.text = language.value
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let language = Array(languagesArray)[indexPath.row]
        LocaleManager.apply(identifier: language.key, animated: false)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kIGGoDissmissLangNotificationName), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

}

class LanguageCell: BaseTableViewCell {
    
    @IBOutlet weak var langNameLbl: UILabel!
    @IBOutlet weak var langIsoCodeLbl: UILabel!
    @IBOutlet weak var selectedLangIconLbl: UILabel!
    
}
