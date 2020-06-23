//
//  IGPSBillTypes.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/14/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGPSBillTypesVC: BaseTableViewController {
    
    var isShortFormEnabled = true
    var types = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor

    }

        override func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return (types.count) + 1
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
            cell.textLabel?.font = UIFont.igFont(ofSize: 15)
            cell.textLabel?.textAlignment = .center
        
            
            switch indexPath.row {
            case 0 :
                    cell.textLabel!.text = IGStringsManager.PSChooseBill.rawValue.localized
                return cell

            default :
                cell.textLabel!.text = types[indexPath.row - 1]
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
                    switch sSelf.types[indexPath.row - 1] {
                    case IGStringsManager.PSGasBill.rawValue.localized :
                        (UIApplication.topViewController() as! IGPSBillMainVC).billType = IGBillType.Gas
                    case IGStringsManager.PSElecBill.rawValue.localized :
                        (UIApplication.topViewController() as! IGPSBillMainVC).billType = IGBillType.Elec
                    default : break
                    }
                })
            }
        }

    }

    extension IGPSBillTypesVC: PanModalPresentable {
        
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        
        
        var panScrollable: UIScrollView? {
            return tableView
        }
        
        var shortFormHeight: PanModalHeight {
            return .contentHeight(min(300,(CGFloat((80) * types.count))))
        }
        var longFormHeight: PanModalHeight {

            return .contentHeight(max(400,(CGFloat((80) * types.count))))

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
