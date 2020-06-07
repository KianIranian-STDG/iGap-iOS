//
//  IGPSChargeListTVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/7/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit


class IGPSChargeListTVC: BaseTableViewController {

    var chargeList = [String]()
    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var delegate: chargeDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.tableView.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel?.font = UIFont.igFont(ofSize: 15)
        cell.textLabel?.textAlignment = .center
    
        
        switch indexPath.row {
        case 0 :
            cell.textLabel!.text = IGStringsManager.EnterChargePrice.rawValue.localized
            return cell
        case 1,2,3,4,5 :
            cell.textLabel!.text = "\(chargeList[(indexPath.row) - 1])".inLocalizedLanguage()
            return cell
        default : return UITableViewCell()
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 : break
        case 1,2,3,4,5 :
            self.delegate?.passData(charge: "\(chargeList[(indexPath.row) - 1])".inLocalizedLanguage())

        default : break
        }
    }

}
class chargeCell : UITableViewCell {}

extension IGPSChargeListTVC: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(500)
        } else {
            return .contentHeight(300)
        }

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
