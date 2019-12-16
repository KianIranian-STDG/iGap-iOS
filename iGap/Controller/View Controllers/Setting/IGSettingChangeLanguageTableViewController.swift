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
import SwiftEventBus

class IGSettingChangeLanguageTableViewController: BaseTableViewController {
    
    private var languagesArray = Array<(key: String, value: String)>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        languagesArray = Array(LocaleManager.availableLocalizations.filter({ $0.key != "Base" })).sorted(by: { $0.key < $1.key })
    }
    private func initTheme() {}
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.ChangeLang.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    //MARK: - tableView dataSource and Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languagesArray.count
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LangCell", for: indexPath) as? LanguageCell else {
            return LanguageCell()
        }
        
        let language = languagesArray[indexPath.row]
        cell.langIsoCodeLbl.text = language.key.uppercased()
        cell.langNameLbl.text = language.value
        
        if Locale.userPreferred.languageCode == language.key {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            cell.selectedLangIconLbl.isHidden = false
        } else {
            cell.selectedLangIconLbl.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LanguageCell
        cell.selectedLangIconLbl.isHidden = false
        
        let language = languagesArray[indexPath.row]
        if Locale.userPreferred.languageCode != language.key {
            LocaleManager.apply(identifier: language.key, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LanguageCell
        cell.selectedLangIconLbl.isHidden = true
    }
    
}
