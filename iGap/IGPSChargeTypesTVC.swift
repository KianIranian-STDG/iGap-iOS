//
//  IGPSChargeTypesTVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/7/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGPSChargeTypesTVC: BaseTableViewController {
    
    var numberOfRows : Int = 2
    var chargeTypes = [String]()
    var isShortFormEnabled = true
    var isKeyboardPresented = false
    var selectedOperator : selectedOperator!
    
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
        return (chargeTypes.count) + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel?.font = UIFont.igFont(ofSize: 15)
        cell.textLabel?.textAlignment = .center
    
        
        switch indexPath.row {
        case 0 :
            cell.textLabel!.text = IGStringsManager.ChooseChargeType.rawValue.localized
            return cell
        default :
            cell.textLabel!.text = "\(chargeTypes[(indexPath.row) - 1])".inLocalizedLanguage()
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
                (UIApplication.topViewController() as! IGPSTopUpMainVC).btnChargeType.setTitle("\(sSelf.chargeTypes[(indexPath.row) - 1])", for: .normal)
                (UIApplication.topViewController() as! IGPSTopUpMainVC).selectedChargeType["\(sSelf.chargeTypes[(indexPath.row) - 1])"] = (indexPath.row) - 1
                
            })
        }
    }

}

extension IGPSChargeTypesTVC: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(CGFloat((80) * chargeTypes.count))
    }
    var longFormHeight: PanModalHeight {

        if isKeyboardPresented {
            return .contentHeight(500)
        } else {
            return .contentHeight(CGFloat((80) * chargeTypes.count))
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
