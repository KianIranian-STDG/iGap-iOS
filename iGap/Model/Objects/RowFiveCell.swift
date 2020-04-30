//
//  RowFiveCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/29/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class RowFiveCell: BaseTableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    


    let lblHeader : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .darkGray
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.MBCategoryServices.rawValue.localized
        return lbl

    }()
    let viewHeader : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view

    }()

    private let cvContainerBottomCellIdentifier = "cvContainerBottomTileCellIdentifier"
    private let cvContainer: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            cv.contentInsetAdjustmentBehavior = .never
        }
        return cv
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addBGView()
        addSubview(lblHeader)
        addSubview(viewHeader)

        addHeader()
        
        lblHeader.semanticContentAttribute = self.semantic
        viewHeader.semanticContentAttribute = self.semantic
        initCollection()


    }
    private func initCollection() {
        cvContainer.delegate = self
        cvContainer.dataSource = self
        
        cvContainer.register(MBSubTileCell.self, forCellWithReuseIdentifier: cvContainerBottomCellIdentifier)
        
        addSubview(cvContainer)
        
        
        cvContainer.translatesAutoresizingMaskIntoConstraints = false
        cvContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        cvContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        cvContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        cvContainer.topAnchor.constraint(equalTo: lblHeader.bottomAnchor, constant: 10).isActive = true
        cvContainer.isScrollEnabled = false
        

    }
  
    
    private func addHeader() {
        lblHeader.translatesAutoresizingMaskIntoConstraints = false
        lblHeader.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        lblHeader.topAnchor.constraint(equalTo: self.topAnchor, constant: 30).isActive = true

        lblHeader.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        viewHeader.translatesAutoresizingMaskIntoConstraints = false
        viewHeader.leadingAnchor.constraint(equalTo: lblHeader.trailingAnchor, constant: 10).isActive = true
        viewHeader.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        viewHeader.centerYAnchor.constraint(equalTo: lblHeader.centerYAnchor, constant: 0).isActive = true
        viewHeader.heightAnchor.constraint(equalToConstant: 1).isActive = true

        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 3
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvContainerBottomCellIdentifier, for: indexPath) as! MBSubTileCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width/2 - 10, height: collectionView.frame.width/5)

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
