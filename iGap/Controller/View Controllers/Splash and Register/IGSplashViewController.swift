//
//  IGSplashViewController.swift
//  iGap
//
//  Created by Hossein MacBook Pro on 8/27/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGSplashViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var selectLanguageTV: UITableView!
    
    // MARK: - Variables
    private var languagesArray = Array<(key: String, value: String)>()

    // MARK: - built in functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectLanguageTV.isHidden = true
        languagesArray = Array(LocaleManager.availableLocalizations.filter({ $0.key != "Base" })).sorted(by: { $0.key < $1.key })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `2.0` to the desired number of seconds.
            UIView.transition(with: self.selectLanguageTV, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.selectLanguageTV.isHidden = false
            })
        }
        
        selectLanguageTV.delegate = self
        selectLanguageTV.dataSource = self
        
        selectLanguageTV.layer.masksToBounds = true
        selectLanguageTV.layer.cornerRadius = 8
        selectLanguageTV.layer.borderWidth = 1
        selectLanguageTV.layer.borderColor = UIColor(named: themeColor.labelGrayColor.rawValue)?.cgColor
    }

}


extension IGSplashViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        //        label.textColor = UIColor.red
        label.text = "Choose Language - انتخاب زبان"
        
        label.font = UIFont.igFont(ofSize: 15)
        label.textAlignment = .center
        
        return label
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LangCell", for: indexPath) as? LanguageCell else {
            return LanguageCell()
        }
        
        let language = languagesArray[indexPath.row]
        cell.langIsoCodeLbl.text = language.key.uppercased()
        cell.langNameLbl.text = language.value
        
        return cell
    }
    
    //MARK: - tableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let language = languagesArray[indexPath.row]
        LocaleManager.apply(identifier: language.key, animated: false)
//        RootVCSwitcher.updateRootVC(storyBoard: "Register", viewControllerID: "IGSplashNavigationController")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}


class LanguageCell: BaseTableViewCell {
    
    @IBOutlet weak var langNameLbl: UILabel!
    @IBOutlet weak var langIsoCodeLbl: UILabel!
    @IBOutlet weak var selectedLangIconLbl: UILabel!
    
}

