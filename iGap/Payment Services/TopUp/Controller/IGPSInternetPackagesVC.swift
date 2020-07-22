//
//  IGPSInternetPackagesVC.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/9/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftEventBus
class IGPSInternetPackagesVC : MainViewController {
    var vm : IGPSInternetPackagesVM!
//    let scrollView = IGScrollView()
    var table = UITableView()
    let stk = UIStackView()
    var selectedPhone : String!
    var selectedOp : IGSelectedOperator!

    let btnTime : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.LabelColor.lighter(by: 10), for: .normal)
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.lighter(by: 10)?.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Time.rawValue.localized, for: .normal)
        return btn
    }()
    
    let btnVolume : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1.0
        btn.setTitleColor(ThemeManager.currentTheme.LabelColor.lighter(by: 10), for: .normal)
        btn.layer.borderColor = ThemeManager.currentTheme.LabelColor.lighter(by: 10)?.cgColor
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Voloume.rawValue.localized, for: .normal)
        return btn
    }()
    
    private let btnBuy : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 10
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.igFont(ofSize: 13)
        btn.setTitle(IGStringsManager.Buy.rawValue.localized, for: .normal)
        btn.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        return btn
    }()
    
    //internet packages
    var internetPackages: [IGPSInternetPackages]!
    var internetCategories: [IGPSInternetCategory]!
    var selectedCategory : IGPSInternetCategory!
    var selectedPackage : IGPSLastInternetPackagesPurchases!
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = IGPSInternetPackagesVM(viewController: self)
        initView()
        initServices()
        table.delegate = vm
        table.dataSource = vm
        table.separatorStyle = .none
        table.register(IGPSInternetPackagesCell.self, forCellReuseIdentifier: "IGPSInternetPackagesCell")
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        
        initCustomtNav(title: IGStringsManager.BuyInternetPackage.rawValue.localized)
        self.view.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        initEventBus()
    }
    private func initEventBus() {

        SwiftEventBus.onMainThread(self, name: EventBusManager.InternetPackageAddToFavourite) { result in
            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .question, title: nil, showIconView: true, showDoneButton: true, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.PSAddToLastPurchases.rawValue.localized, doneText: IGStringsManager.Add.rawValue.localized, cancelText: IGStringsManager.GlobalCancel.rawValue.localized, cancel: {
                print("TAP CANCEL")
            }, done: {
                self.vm.addToHistory()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SwiftEventBus.unregister(self)
    }

    private func initServices() {
        vm.internetPackages = internetPackages
        vm.filteredPackages = internetPackages
        vm.selectedPhone = selectedPhone
        vm.selectedOp = selectedOp

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectedPackage != nil {
            vm.selectedLastPackage = selectedPackage
            let itemsS = internetPackages.filter { (pack) -> Bool in
                return pack.isSpecial == true
            }
            print("ITEMS: ",itemsS)
            let itemsN = internetPackages.filter { (pack) -> Bool in
                return (pack.isSpecial == false)
            }
            print("ITEMN: ",itemsN)

            if let index = itemsN.firstIndex(where: {$0.type == selectedPackage.packageType}) {
                self.table.scrollToRow(at: IndexPath(row: index, section: 1), at: .bottom, animated: true)
                vm.indexOfSelectedPackage = IndexPath(row: index, section: 1)
            } else {
                if let i = itemsS.firstIndex(where: {$0.type == selectedPackage.packageType}) {
                    self.table.scrollToRow(at: IndexPath(row: i, section: 0), at: .bottom, animated: true)
                    vm.indexOfSelectedPackage = IndexPath(row: i, section: 0)

                }
            }
        }
    }
    
    private func initView() {
        addContents()
        manageSemantics()
        manageActions()
    }
    
    private func addContents() {
        addFilterHolder()
        addButton()
        addTable()
    }
    
    private func manageSemantics() {
        view.semanticContentAttribute = self.semantic
    }
    
    private func addFilterHolder() {
        stk.translatesAutoresizingMaskIntoConstraints = false
        stk.distribution = .fillEqually
        stk.alignment = .fill
        stk.axis = .horizontal
        stk.spacing = 10

        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.textAlignment = lbl.localizedDirection
        lbl.text = IGStringsManager.GlobalSort.rawValue.localized
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)

        lbl.topAnchor.constraint(equalTo: view.topAnchor,constant: 20).isActive = true
        lbl.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20).isActive = true
        lbl.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20).isActive = true
        view.addSubview(stk)
        
        stk.addArrangedSubview(btnTime)
        stk.addArrangedSubview(btnVolume)

        stk.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stk.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stk.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20).isActive = true
        stk.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20).isActive = true
        stk.topAnchor.constraint(equalTo: lbl.bottomAnchor,constant: 10).isActive = true

    }
    
    private func addTable() {
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        
        table.topAnchor.constraint(equalTo: stk.bottomAnchor,constant: 20).isActive = true
        table.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20).isActive = true
        table.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20).isActive = true
        table.bottomAnchor.constraint(equalTo: btnBuy.topAnchor,constant: -20).isActive = true

    }
    
    private func addButton() {
        view.addSubview(btnBuy)

        btnBuy.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -10).isActive = true
        btnBuy.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20).isActive = true
        btnBuy.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20).isActive = true
        btnBuy.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }
    
    private func manageActions() {
        btnTime.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.fetchDurationPackage()
        })
        btnVolume.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}

            sSelf.fetchTrafficPackage()
        })
        btnBuy.addTapGestureRecognizer(action: { [weak self] in
            guard let sSelf = self else {return}
            sSelf.vm.buyInternetPackage()

        })

    }
    
    func fetchDurationPackage() {
        
        let timeArray  = internetCategories.filter({ $0.category?.type == "DURATION" })

        var hourArray = timeArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "HOUR"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return fabsf(Float((elemOne.category?.value)!)) < fabsf(Float((elemTwo.category?.value)!))
        }
        var dayArray = timeArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "DAY"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return fabsf(Float((elemOne.category?.value)!)) < fabsf(Float((elemTwo.category?.value)!))
        }
        var weakArray = timeArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "WEAK"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return fabsf(Float((elemOne.category?.value)!)) < fabsf(Float((elemTwo.category?.value)!))
        }
        var monthArray = timeArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "MONTH"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return fabsf(Float((elemOne.category?.value)!)) < fabsf(Float((elemTwo.category?.value)!))
        }
        var yearArray = timeArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "YEAR"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return fabsf(Float((elemOne.category?.value)!)) < fabsf(Float((elemTwo.category?.value)!))
        }
        for elem in yearArray {
            let filteredYearArray = internetPackages.contains(where: { (pkg) -> Bool in
                return pkg.duration == elem.id
            })
            if !filteredYearArray {
                yearArray = yearArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
            }
        }
        for elem in monthArray {
            let filteredMonthArray = internetPackages.contains(where: { (pkg) -> Bool in
                return pkg.duration == elem.id
            })
            if !filteredMonthArray {
                monthArray = monthArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
            }
        }
        for elem in weakArray {
            let filteredWeakArray = internetPackages.contains(where: { (pkg) -> Bool in
                return pkg.duration == elem.id
            })
            if !filteredWeakArray {
                weakArray = weakArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
            }
        }

        for elem in dayArray {
            let filteredDayArray = internetPackages.contains(where: { (pkg) -> Bool in
                return pkg.duration == elem.id
            })
            if !filteredDayArray {
                dayArray = dayArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
            }
        }

        for elem in hourArray {
            let filteredHourArray = internetPackages.contains(where: { (pkg) -> Bool in
                return pkg.duration == elem.id
            })
            if !filteredHourArray {
                hourArray = hourArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
            }
        }

        
        
        var finalDurationArray = hourArray + dayArray + weakArray + monthArray + yearArray
        if vm.selectedVolume != nil {
            let tmpFinalDurationArray = finalDurationArray
            finalDurationArray.removeAll()
            for elem in vm.filteredPackages {
                let filteredFinalDurationArray = tmpFinalDurationArray.contains(where: { (pkg) -> Bool in
                    if pkg.id == elem.duration {
                        finalDurationArray.append(pkg)
                        return true
                    } else {
                        return false
                    }
                })
            }
        }
        let tmp = finalDurationArray.filterDuplicates { $0.id == $1.id }
        finalDurationArray.removeAll()
        finalDurationArray = tmp.sorted { (elemOne, elemTwo) -> Bool in
            return (Float((elemOne.category?.value)!)) < (Float((elemTwo.category?.value)!))
        }


        IGHelperBottomModals.shared.showDataModal(categories: finalDurationArray ,isTraffic : false)
    }
    func fetchTrafficPackage() {
        let trafficArray  = internetCategories.filter({ $0.category?.type == "TRAFFIC" })
        var gbArray = trafficArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "GB"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return (Float((elemOne.category?.value)!)) < (Float((elemTwo.category?.value)!))
        }
        var mbArray = trafficArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "MB"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return (Float((elemOne.category?.value)!)) < (Float((elemTwo.category?.value)!))
        }

        var infinitArray = trafficArray.filter({ (elem) -> Bool in
            return elem.category?.subType == "INFINITE"
        }).sorted { (elemOne, elemTwo) -> Bool in
            return (Float((elemOne.category?.value)!)) < (Float((elemTwo.category?.value)!))
        }
        for elem in gbArray {
            let filtredGBArray = internetPackages.contains(where: { (pkg) -> Bool in
                return pkg.traffic == elem.id
            })
            if !filtredGBArray {
                gbArray = gbArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
            }
        }

        for elem in mbArray {
             let filteredMBArray = internetPackages.contains(where: { (pkg) -> Bool in
                 return pkg.traffic == elem.id
             })
             if !filteredMBArray {
                 mbArray = mbArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
             }
         }
        for elem in infinitArray {
             let filteredInfinitArray = internetPackages.contains(where: { (pkg) -> Bool in
                 return pkg.traffic == elem.id
             })
             if !filteredInfinitArray {
                 infinitArray = infinitArray.filter() { $0.id  as AnyObject !== elem.id as AnyObject }
             }
         }

        var finalTrafficArray = mbArray + gbArray + infinitArray
        if vm.seletedDuration != nil {
            let tmpFilteredTrafficArray = finalTrafficArray
            finalTrafficArray.removeAll()
            for elem in vm.filteredPackages {
                let filteredFinalTrafficArray = tmpFilteredTrafficArray.contains(where: { (pkg) -> Bool in
                    if pkg.id == elem.traffic {
                        finalTrafficArray.append(pkg)
                        return true
                    } else {
                        return false
                    }
                })
            }
        }
        let tmp = finalTrafficArray.filterDuplicates { $0.id == $1.id }
        finalTrafficArray.removeAll()
        finalTrafficArray = tmp.sorted { (elemOne, elemTwo) -> Bool in
            return (Float((elemOne.category?.value)!)) < (Float((elemTwo.category?.value)!))
        }
        IGHelperBottomModals.shared.showDataModal(categories: finalTrafficArray,isTraffic : true)

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnTime.setTitleColor(ThemeManager.currentTheme.LabelColor.lighter(by: 10), for: .normal)
        btnTime.layer.borderColor = ThemeManager.currentTheme.LabelColor.lighter(by: 10)?.cgColor
        btnVolume.setTitleColor(ThemeManager.currentTheme.LabelColor.lighter(by: 10), for: .normal)
        btnVolume.layer.borderColor = ThemeManager.currentTheme.LabelColor.lighter(by: 10)?.cgColor
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                btnBuy.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
            case .dark:
                btnBuy.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor.lighter(by: 20)!
            default :
                break
            }
        } else {
            btnBuy.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        }
    }
    
}
extension Array {

    func filterDuplicates(includeElement: (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
        var results = [Element]()

        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }

        return results
    }
}
