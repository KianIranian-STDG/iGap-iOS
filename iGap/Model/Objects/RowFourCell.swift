//
//  RowFourCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class RowFourCell: BaseTableViewCell,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    

    var dateArray : [String] = []
    var YearArray : [String] = []
    var MonthArray : [String] = []
    var selectedIndexPath: IndexPath? = IndexPath(row: 0, section: 0)

    var past12Months: [String] {
        let today = Date()
        let dates = (-12...0).compactMap{ Calendar.current.date(byAdding: .month, value: $0, to: today)}

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strings = dates.map{ SMDateUtil.toPersianWithoutDay($0) }
        return strings
    }
    
    private let callenderCollectionCellIdentifier = "callenderCollectionCellIdentifier"
    private var callenderCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = false
        if #available(iOS 11.0, *) {
            cv.contentInsetAdjustmentBehavior = .never
        }
        cv.backgroundColor = .clear
        
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initView()
        

    }
    
    private func initView() {
        getCallenderData()
        initCallender()

    }
    
    private func getCallenderData() {
        print("CALLENDER :",past12Months)
        for date in past12Months {
            dateArray.append(date.replacingOccurrences(of: "13", with: ""))
            let stringArray = date.replacingOccurrences(of: "13", with: "").components(separatedBy: CharacterSet.decimalDigits.inverted)
            let monthsArray = date.replacingOccurrences(of: "13", with: "").components(separatedBy: CharacterSet.letters.inverted)
            for item in stringArray {
                if let number = Int(item) {
                    print("number: \(number)")
                    YearArray.append(String(number))
                }
            }

            for item in monthsArray {

                if  item != "" {
                    print("month: ",item)
                    MonthArray.append(item)

                }
            }

        }
        MonthArray.reverse()
        YearArray.reverse()
    }
    
    private func initCallender() {
        self.addSubview(callenderCollection)

        callenderCollection.translatesAutoresizingMaskIntoConstraints = false
        callenderCollection.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        callenderCollection.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        callenderCollection.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        callenderCollection.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        callenderCollection.register(CallenderCell.self, forCellWithReuseIdentifier: callenderCollectionCellIdentifier)


        callenderCollection.layoutIfNeeded()
        
        callenderCollection.delegate = self
        callenderCollection.dataSource = self
        callenderCollection.semanticContentAttribute = self.semantic
//        callenderCollection.scrollToItem(at: [0,12], at: .centeredHorizontally, animated: true)


    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: callenderCollectionCellIdentifier, for: indexPath) as! CallenderCell
        
        if self.selectedIndexPath != nil && indexPath == self.selectedIndexPath {
            cell.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
            cell.layer.cornerRadius = 25
            cell.lblBottom.textColor = .white
            cell.lblTop.textColor = .white

        } else {
            cell.backgroundColor = .clear
            cell.lblBottom.textColor = .darkGray
            cell.lblTop.textColor = .darkGray
            cell.layer.cornerRadius = 0

        }

        cell.lblTop.text = YearArray[indexPath.item]
        cell.lblBottom.text = MonthArray[indexPath.item]

        return cell
        
        

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = callenderCollection.cellForItem(at: indexPath) as? CallenderCell else { return }
        cell.backgroundColor = UIColor.hexStringToUIColor(hex: "B6774E")
        cell.layer.cornerRadius = 25
        cell.lblBottom.textColor = .white
        cell.lblTop.textColor = .white
        self.selectedIndexPath = indexPath
        print(indexPath)
        callenderCollection.reloadData()
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = callenderCollection.cellForItem(at: indexPath) as? CallenderCell else { return }
        cell.backgroundColor = .clear
        cell.lblBottom.textColor = .darkGray
        cell.lblTop.textColor = .darkGray
        cell.layer.cornerRadius = 0
        self.selectedIndexPath = nil

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            return CGSize(width: callenderCollection.frame.height - 40 , height: callenderCollection.frame.height)
            
    }


}

