//
//  IGPSArrayVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/9/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class IGPSDataArrayVC: BaseTableViewController {
    var items = [IGPSInternetCategory]()
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
        return (items.count) + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel?.font = UIFont.igFont(ofSize: 15)
        cell.textLabel?.textAlignment = .center
    
        
        switch indexPath.row {
        case 0 :
            if isTraffic {
                cell.textLabel!.text = IGStringsManager.PSChooseVolume.rawValue.localized
            } else {
                cell.textLabel!.text = IGStringsManager.PSChooseDuration.rawValue.localized

            }
            return cell
        case 1 :
                cell.textLabel!.text = IGStringsManager.All.rawValue.localized
            return cell

        default :
            let x : CGFloat = (items[(indexPath.row) - 2].category?.value)!
            if ((items[(indexPath.row) - 2].category?.type)!) == "TRAFFIC" {
                var g : String = IGStringsManager.GB.rawValue.localized
                if ((items[(indexPath.row) - 2].category?.subType)!) == "GB" {
                    g = IGStringsManager.GB.rawValue.localized
                } else if ((items[(indexPath.row) - 2].category?.subType)!) == "MB" {
                    g = IGStringsManager.MB.rawValue.localized
                } else if ((items[(indexPath.row) - 2].category?.subType)!) == "TB" {
                    g = IGStringsManager.TB.rawValue.localized
                } else {
                    g = ""
                }
                if (x.description).last == "0" {
                    cell.textLabel!.text = String(Int(Float(x.description) ?? 0)).inLocalizedLanguage() + " " + (g)
                } else {
                    cell.textLabel!.text = (((x.description))).inLocalizedLanguage() + " " + (g)
                }
            } else {
                var m : String = IGStringsManager.Month.rawValue.localized
                if ((items[(indexPath.row) - 2].category?.subType)!) == "MONTH" {
                    m = IGStringsManager.GlobalMonth.rawValue.localized
                } else if ((items[(indexPath.row) - 2].category?.subType)!) == "DAY" {
                    m = IGStringsManager.GlobalDay.rawValue.localized
                } else if ((items[(indexPath.row) - 2].category?.subType)!) == "YEAR" {
                    m = IGStringsManager.GlobalYear.rawValue.localized
                } else if ((items[(indexPath.row) - 2].category?.subType)!) == "HOUR" {
                    m = IGStringsManager.GlobalHour.rawValue.localized
                }
                cell.textLabel!.text = String(Int(Float(x.description) ?? 0)).inLocalizedLanguage() + (m)

            }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 : break
        case 1 :
            self.dismiss(animated: true, completion: {[weak self] in
                guard let sSelf = self else {
                    return
                }
                if ((sSelf.items[(indexPath.row)].category?.type)!) == "TRAFFIC" {
                    let ttl = IGStringsManager.Voloume.rawValue.localized + ": " + IGStringsManager.All.rawValue.localized
                    (UIApplication.topViewController() as! IGPSInternetPackagesVC).btnVolume.setTitle(ttl, for: .normal)
                    (UIApplication.topViewController() as! IGPSInternetPackagesVC).vm.selectedVolume = nil

                } else {
                    let ttl = IGStringsManager.Time.rawValue.localized + ": " + IGStringsManager.All.rawValue.localized
                    (UIApplication.topViewController() as! IGPSInternetPackagesVC).btnTime.setTitle(ttl, for: .normal)
                    (UIApplication.topViewController() as! IGPSInternetPackagesVC).vm.seletedDuration = nil

                }

                })
        default :
            self.dismiss(animated: true, completion: {[weak self] in
                guard let sSelf = self else {
                    return
                }

                let x : CGFloat = (sSelf.items[(indexPath.row) - 2].category?.value)!
                if ((sSelf.items[(indexPath.row)].category?.type)!) == "TRAFFIC" {
                    var g : String = IGStringsManager.GB.rawValue.localized
                    if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "GB" {
                        g = IGStringsManager.GB.rawValue.localized
                    } else if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "MB" {
                        g = IGStringsManager.MB.rawValue.localized
                    } else if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "TB" {
                        g = IGStringsManager.TB.rawValue.localized
                    } else {
                        g = ""
                    }
                    if (x.description).last == "0" {
                        let ttl = IGStringsManager.Voloume.rawValue.localized + ": " + String(Int(Float(x.description) ?? 0)).inLocalizedLanguage() + " " + (g)
                        (UIApplication.topViewController() as! IGPSInternetPackagesVC).btnVolume.setTitle(ttl, for: .normal)
                        (UIApplication.topViewController() as! IGPSInternetPackagesVC).vm.selectedVolume = ((sSelf.items[(indexPath.row) - 2]))

                    } else {
                        let ttl = IGStringsManager.Voloume.rawValue.localized + ": " +  String(Int(Float(x.description) ?? 0)).inLocalizedLanguage() + " " + (g)
                        (UIApplication.topViewController() as! IGPSInternetPackagesVC).btnVolume.setTitle(ttl, for: .normal)
                        (UIApplication.topViewController() as! IGPSInternetPackagesVC).vm.selectedVolume = ((sSelf.items[(indexPath.row) - 2]))

                    }
                } else {
                    var m : String = IGStringsManager.Month.rawValue.localized
                    if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "MONTH" {
                        m = IGStringsManager.GlobalMonth.rawValue.localized
                    } else if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "DAY" {
                        m = IGStringsManager.GlobalDay.rawValue.localized
                    } else if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "YEAR" {
                        m = IGStringsManager.GlobalYear.rawValue.localized
                    } else if ((sSelf.items[(indexPath.row) - 2].category?.subType)!) == "HOUR" {
                        m = IGStringsManager.GlobalHour.rawValue.localized
                    }
                    let ttl = IGStringsManager.Time.rawValue.localized + ": " + String(Int(Float(x.description) ?? 0)).inLocalizedLanguage() + (m)
                    (UIApplication.topViewController() as! IGPSInternetPackagesVC).btnTime.setTitle(ttl, for: .normal)
                    (UIApplication.topViewController() as! IGPSInternetPackagesVC).vm.seletedDuration = ((sSelf.items[(indexPath.row) - 2]))
                }

                
            })
        }
    }

}

extension IGPSDataArrayVC: PanModalPresentable {
    
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
