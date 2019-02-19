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
import RealmSwift

private let reuseIdentifier = "StickerCell"

@available(iOS 10.0, *)
class IGStickerViewController: UICollectionViewController, UIGestureRecognizerDelegate, StickerToolbarObserver, StickerAddListener {
    
    var numberOfItemsPerRow = 5.0 as CGFloat
    let interItemSpacing = 1.0 as CGFloat
    let interRowSpacing = 1.0 as CGFloat
    let sectionTitleKey = "SectionTitle"
    let sectionItemsKey = "Items"
    var selectedIndexManually: Int = -1
    var stickerPageType = StickerPageType.MAIN
    var stickerTabs: Results<IGRealmSticker>!
    var stickerList: [StickerTab] = []// use this variable at sticker list page
    var offset: Int = 0
    let FETCH_LIMIT = 10
    var stickerGroupId: String?

    static var previewSectionIndex: Int = -1
    static var addStickerIndex: Int = -1
    static var stickerTapListener: StickerTapListener!
    static var stickerToolbarObserver: StickerToolbarObserver!
    static var stickerAddListener: StickerAddListener!
    
    override func viewDidAppear(_ animated: Bool) {
        IGStickerViewController.stickerToolbarObserver = self
        IGStickerViewController.stickerAddListener = self
        if IGStickerViewController.previewSectionIndex != -1 && stickerPageType == StickerPageType.ADD_REMOVE {
            self.collectionView?.reloadSections(IndexSet([IGStickerViewController.previewSectionIndex]))
            IGStickerViewController.previewSectionIndex = -1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        
        self.collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.view.backgroundColor = UIColor.sticker()
        
        if stickerPageType == StickerPageType.MAIN {
            fetchMySticker()
        } else if stickerPageType == StickerPageType.ADD_REMOVE {
            fetchStickerList()
        } else if stickerPageType == StickerPageType.PREVIEW {
            self.collectionView!.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            numberOfItemsPerRow = 3.0 as CGFloat
            fetchStickerPreview(groupId: stickerGroupId!)
        }
    }
    
    private func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "Add Sticker")
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func fetchMySticker(){
        stickerTabs = try! Realm().objects(IGRealmSticker.self).sorted(by: [SortDescriptor(keyPath: "sort", ascending: false)])
    }
    
    private func fetchStickerList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            IGGlobal.prgShow(self.view)
            IGApiSticker.shared.stickerList(offset: self.offset, limit: self.FETCH_LIMIT) { (stickers) in
                IGGlobal.prgHide()
                
                for sticker in stickers {
                    self.stickerList.append(sticker)
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData() // TODO - insert item instead of reloadData
                }
                
                if stickers.count < self.FETCH_LIMIT { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.offset += self.FETCH_LIMIT
                    self.fetchStickerList()
                }
            }
        }
    }
    
    private func fetchStickerPreview(groupId: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            IGGlobal.prgShow(self.view)
            IGApiSticker.shared.stickerGroup(groupId: groupId) { (stickers) in
                IGGlobal.prgHide()
                if stickers.count == 0 { return }
                
                for sticker in stickers {
                    self.stickerList.append(sticker)
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    
    /************* Observer *************/
    func onToolbarClick(index: Int) {
        selectedIndexManually = index
        goToPosition(position: index)
        highlightSelected(index: index)
    }
    
    func onStickerAdd(index: Int) {
        self.collectionView?.reloadSections(IndexSet([index]))
    }
    
    private func goToPosition(position: Int){
        if let attributes = self.collectionView!.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: position)) {
            self.collectionView!.setContentOffset(CGPoint(x: 0, y: attributes.frame.origin.y - self.collectionView!.contentInset.top), animated: true)
        }
    }
    
    private func highlightSelected(index: Int){
        for btn in IGStickerToolbar.buttonArray {
            if btn.tag == index {
                btn.backgroundColor = UIColor.stickerToolbarSelected()
            } else {
                btn.backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if stickerPageType == StickerPageType.MAIN {
            return stickerTabs.count
        }
        return stickerList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if stickerPageType == StickerPageType.MAIN {
            return stickerTabs[section].stickerItems.count
        } else if stickerPageType == StickerPageType.PREVIEW {
            return stickerList[section].stickers.count
        }
        let stickerCount = stickerList[section].stickers.count
        if stickerCount < 5 {
            return stickerCount
        }
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // Configure the cell
        guard let stickerItem = cell as? IGStickerCell else {
            return
        }
        DispatchQueue.main.async {
            if self.selectedIndexManually == -1 ||
                self.selectedIndexManually == IGStickerToolbar.shared.STICKER_SETTING ||
                self.selectedIndexManually == IGStickerToolbar.shared.STICKER_ADD { // if user selected an item manually don't do current action
                
                self.highlightSelected(index: indexPath.section)
            } else if self.selectedIndexManually == indexPath.section {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.selectedIndexManually = -1
                }
            }
            if self.stickerPageType == StickerPageType.MAIN {
                stickerItem.configure(stickerItem: self.stickerTabs[indexPath.section].stickerItems[indexPath.row])
            } else if self.stickerPageType == StickerPageType.ADD_REMOVE {
                stickerItem.configureListPage(stickerItem: self.stickerList[indexPath.section].stickers[indexPath.row], sectionIndex: indexPath.section)
            } else if self.stickerPageType == StickerPageType.PREVIEW {
                stickerItem.configurePreview(stickerItem: self.stickerList[indexPath.section].stickers[indexPath.row])
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:String(describing: IGStickerSectionHeader.self), for: indexPath)
        
        if let foodHeader = headerView as? IGStickerSectionHeader {
            if self.stickerPageType == StickerPageType.ADD_REMOVE {
                foodHeader.configureListPage(sticker: self.stickerList[indexPath.section], sectionIndex: indexPath.section)
            } else if self.stickerPageType == StickerPageType.PREVIEW {
                foodHeader.configurePreview(sticker: self.stickerList[indexPath.section], sectionIndex: indexPath.section)
            } else { //StickerPageType.MAIN
                foodHeader.configure(sticker: self.stickerTabs[indexPath.section])
            }
        }
        return headerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.stickerPageType == StickerPageType.ADD_REMOVE {
            return CGSize(width: UIScreen.main.bounds.width, height: 60)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: 40)
    }
}

@available(iOS 10.0, *)
extension IGStickerViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = (numberOfItemsPerRow - 1.0)  * interItemSpacing
        let width = (view.frame.size.width - padding) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interRowSpacing
    }
}
