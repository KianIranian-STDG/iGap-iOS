//
//  IGPSPhoneTVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/18/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSPhoneTVC: BaseTableViewController {
    var items = [String]()
    var isShortFormEnabled = true
    var isTraffic = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (items.count) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel?.font = UIFont.igFont(ofSize: 15)
        cell.textLabel?.textAlignment = .center
    
        
        switch indexPath.row {
        case 0 :
            cell.textLabel!.text = IGStringsManager.PhoneNumbers.rawValue.localized
            return cell
        default :
            cell.textLabel!.text = items[indexPath.row - 1].inLocalizedLanguage()
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 : break
        default :
            self.dismiss(animated: true, completion: {[weak self] in
                guard let sSelf = self else {
                    return
                }
                (UIApplication.topViewController() as! IGPSTopUpMainVC).tfPhoneNUmber.text = (sSelf.items[indexPath.row - 1]).replacingOccurrences(of: " ", with: "").remove98()
            })
        }
    }

}

extension IGPSPhoneTVC: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(min(300,(CGFloat((80) * items.count))))
    }
    var longFormHeight: PanModalHeight {

        return .contentHeight(max(400,(CGFloat((80) * items.count))))

    }
    var anchorModalToLongForm: Bool {
        return false
    }


    
    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }
        
        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
    
    
}
