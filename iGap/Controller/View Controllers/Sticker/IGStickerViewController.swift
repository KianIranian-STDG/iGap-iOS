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
import Lottie
import SwiftEventBus
import SDWebImage

private let reuseIdentifier = "StickerCell"

@available(iOS 10.0, *)
class IGStickerViewController: BaseCollectionViewController, UIGestureRecognizerDelegate {
    
    var numberOfItemsPerRow = 5.0 as CGFloat
    let interItemSpacing = 1.0 as CGFloat
    let interRowSpacing = 1.0 as CGFloat
    let sectionTitleKey = "SectionTitle"
    let sectionItemsKey = "Items"
    var selectedIndexManually: Int = -1
    var stickerPageType = StickerPageType.MAIN
    var offset: Int = 0
    let FETCH_LIMIT = 20
    var stickerGroupId: String? // use this variable at PREVIEW page type
    var stickerCategoryId: String? // use this variable at CATEGORY page type
    var currentIndexPath: IndexPath!
    var isWaitingForRequest = false
    var isGift = false
    var dismissBtn: UIButton!
    var giftStickerBuyModal: SMCheckBuyGiftSticker!
    
    // Due to the type of sticker page for collection view will be used one of the following variables
    var stickerTabs: Results<IGRealmSticker>! // use this variable at main sticker page (MAIN)
    var stickerList: [StickerTab] = [] // use this variable at sticker list page (PREVIEW, CATEGORY)
    var backGroundColor = UIColor.sticker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationBar()
        eventBusListeners()
        
        self.collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.view.backgroundColor = backGroundColor
        
        if stickerPageType == StickerPageType.MAIN {
            fetchMySticker()
            manageStickerPostion()
        } else if self.stickerPageType == StickerPageType.CATEGORY {
            if isGift {
                fetchGiftableStickerList()
            } else {
                fetchStickerList()
            }
        } else if stickerPageType == StickerPageType.PREVIEW {
            self.collectionView!.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            if isGift {
                numberOfItemsPerRow = 2.0 as CGFloat
            } else {
                numberOfItemsPerRow = 3.0 as CGFloat
            }
            fetchStickerPreview(groupId: stickerGroupId!)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if IGGlobal.stickerPreviewSectionIndex != -1 && stickerPageType == StickerPageType.CATEGORY {
            if self.collectionView!.numberOfSections >= IGGlobal.stickerPreviewSectionIndex + 1 {
                self.collectionView?.reloadSections(IndexSet([IGGlobal.stickerPreviewSectionIndex]))
            }
            IGGlobal.stickerPreviewSectionIndex = -1
        }
    }
    
    deinit {
        print("Deinit IGStickerViewController")
    }
    
    private func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.AddSticker.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    /***** go to default position if 'stickerCurrentGroupId' has value *****/
    private func manageStickerPostion(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var position = -1
            if IGGlobal.stickerCurrentGroupId != nil {
                for (index, stickerTab) in self.stickerTabs.enumerated() {
                    if stickerTab.id == IGGlobal.stickerCurrentGroupId {
                        position = index
                        break
                    }
                }
            }
            
            if position != -1 {
                self.selectedIndexManually = position
                self.goToPosition(position: position)
                self.highlightSelected(index: position)
            }
            IGGlobal.stickerCurrentGroupId = nil
        }
    }
    
    /*******************************************************************************/
    /**************************** Fetch Sticker Methods ****************************/
    
    private func fetchMySticker(){
        stickerTabs = try! Realm().objects(IGRealmSticker.self)
    }
    
    private func fetchStickerPreview(groupId: String){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            SMLoading.showLoadingPage(viewcontroller: self)
            IGApiSticker.shared.stickerGroup(groupId: groupId) { [weak self] (stickers) in
                SMLoading.hideLoadingPage()
                if stickers.count == 0 { return }
                
                for sticker in stickers {
                    self?.stickerList.append(sticker)
                }
                
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
    
    private func fetchStickerList(){
        if stickerCategoryId == nil {return}
        isWaitingForRequest = true
        SMLoading.showLoadingPage(viewcontroller: self)
        IGApiSticker.shared.stickerCategory(categoryId: stickerCategoryId!, offset: self.offset, limit: self.FETCH_LIMIT) { [weak self] (stickers) in
            self?.showStickerList(stickers: stickers)
        }
    }
    
    private func fetchGiftableStickerList(){
        isWaitingForRequest = true
        SMLoading.showLoadingPage(viewcontroller: self)
        IGApiSticker.shared.getGiftableStickerGroups(offset: self.offset, limit: self.FETCH_LIMIT) { [weak self] (stickers) in
            self?.showStickerList(stickers: stickers)
        }
    }
    
    /* after get sticker list from server use following method for show stickers in view */
    private func showStickerList(stickers: [StickerTab]){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SMLoading.hideLoadingPage()
        }
        
        var indexSet : [Int] = []
        
        var extraIndex = 0
        if self.offset > 0 {
            extraIndex = self.offset
        }
        
        for (index,sticker) in stickers.enumerated() {
            indexSet.append(index + extraIndex)
            self.stickerList.append(sticker)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertSections(IndexSet(indexSet))
            })
        }
        
        self.offset += self.FETCH_LIMIT
        
        /***** mabye exist value so set 'isWaitingForRequest' false to allow user get other of items from server *****/
        if stickers.count == self.FETCH_LIMIT {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.isWaitingForRequest = false
            }
        }
    }
    
    /*******************************************************************************/
    /***************************** Observers & Events ******************************/
    
    private func eventBusListeners(){
        
        /***** On Toolbar Click *****/
        SwiftEventBus.onMainThread(self, name: EventBusManager.stickerToolbarClick) { [weak self] (result) in
            if let index = result?.object as? Int {
                self?.selectedIndexManually = index
                self?.goToPosition(position: index)
                self?.highlightSelected(index: index)
            }
        }
        
        /***** Fetch Current Sticker State GroupId *****/
        SwiftEventBus.onMainThread(self, name: EventBusManager.stickerCurrentGroupId) { [weak self] (result) in
            if self?.currentIndexPath != nil, self?.collectionView?.numberOfSections ?? 0 > 0, let cell = self?.collectionView?.cellForItem(at: self?.currentIndexPath ?? IndexPath(row: 0, section: 0)) as? IGStickerCell {
                IGGlobal.stickerCurrentGroupId = cell.stickerItemRealm.groupID
                return
            }
            IGGlobal.stickerCurrentGroupId = ""
        }
        
        /***** Sticker Add *****/
        SwiftEventBus.onMainThread(self, name: EventBusManager.stickerAdd) { [weak self] (result) in
            if let index = result?.object as? Int {
                self?.collectionView?.reloadSections(IndexSet([index]))
            }
        }
        
        /***** Gift Card Buy *****/
        SwiftEventBus.onMainThread(self, name: EventBusManager.giftCardTap) { [weak self] result in
        
            if self == nil {return}
            if self!.stickerPageType != StickerPageType.PREVIEW || !self!.isGift {return}
            guard let stickerItem = result?.object as? Sticker else {return}
            
            self!.dismissBtn = UIButton()
            self!.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
            self!.view.insertSubview(self!.dismissBtn, at: 2)
            self!.dismissBtn.addTarget(self, action: #selector(self!.didtapOutSide), for: .touchUpInside)
                   
            self!.dismissBtn?.snp.makeConstraints { (make) in
                make.top.equalTo(self!.view.snp.top)
                make.bottom.equalTo(self!.view.snp.bottom)
                make.right.equalTo(self!.view.snp.right)
                make.left.equalTo(self!.view.snp.left)
            }
            
            self!.giftStickerBuyModal = SMCheckBuyGiftSticker.loadFromNib()
            self!.giftStickerBuyModal.confirmBtn.addTarget(self, action: #selector(self!.confirmTapped), for: .touchUpInside)
            self!.giftStickerBuyModal.setInfo(token: stickerItem.token, amount: String(describing: stickerItem.giftAmount ?? 0))
            self!.giftStickerBuyModal.frame = CGRect(x: 0, y: self!.view.frame.height , width: self!.view.frame.width, height: self!.giftStickerBuyModal.frame.height)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            self!.giftStickerBuyModal.addGestureRecognizer(swipeDown)
            self!.view.addSubview(self!.giftStickerBuyModal)
            
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.3) {
                self!.giftStickerBuyModal.frame = CGRect(x: 0, y: self!.view.frame.height - self!.giftStickerBuyModal.frame.height - 5 -  bottomPadding!, width: self!.view.frame.width, height: self!.giftStickerBuyModal.frame.height)
            }
        }
    }
    
    private func goToPosition(position: Int){
        if let attributes = self.collectionView!.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: position)) {
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
    
    @objc func didtapOutSide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.giftStickerBuyModal.frame.origin.y = self.view.frame.height
        }) { (true) in
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
            self.giftStickerBuyModal?.removeFromSuperview()
            self.giftStickerBuyModal = nil
            
            self.dismissBtn?.removeFromSuperview()
            self.dismissBtn = nil
        }
    }
    
    @objc func handleGesture(gesture: UITapGestureRecognizer) {
        self.didtapOutSide()
    }
    
    @objc func confirmTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        print("BBB || buy card tapped")
    }
    
    /*******************************************************************************/
    /****************************** Collection View ********************************/
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if stickerPageType == StickerPageType.MAIN {
            if stickerTabs.count == 0 {
                self.collectionView!.setEmptyMessage("")
            } else {
                self.collectionView!.restore()
            }
            return stickerTabs.count
        }
        return stickerList.count
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.stickerPageType == StickerPageType.CATEGORY {
            if !isWaitingForRequest {
                let height = scrollView.frame.size.height
                let contentYoffset = scrollView.contentOffset.y
                let distanceFromBottom = scrollView.contentSize.height - (contentYoffset + 100)
                if distanceFromBottom < height {
                    fetchStickerList()
                }
            }
        }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.selectedIndexManually = -1
                }
            }
            if self.stickerPageType == StickerPageType.MAIN {
                self.currentIndexPath = indexPath
                stickerItem.configure(stickerItem: self.stickerTabs[indexPath.section].stickerItems[indexPath.row])
            } else if self.stickerPageType == StickerPageType.CATEGORY {
                stickerItem.configureListPage(stickerItem: self.stickerList[indexPath.section].stickers[indexPath.row], sectionIndex: indexPath.section, isGift: self.isGift)
            } else if self.stickerPageType == StickerPageType.PREVIEW {
                stickerItem.configurePreview(stickerItem: self.stickerList[indexPath.section].stickers[indexPath.row], isGift: self.isGift)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:String(describing: IGStickerSectionHeader.self), for: indexPath)
        
        if let foodHeader = headerView as? IGStickerSectionHeader {
            if self.stickerPageType == StickerPageType.CATEGORY {
                foodHeader.configureListPage(sticker: self.stickerList[indexPath.section], sectionIndex: indexPath.section, isGift: self.isGift)
            } else if self.stickerPageType == StickerPageType.PREVIEW {
                foodHeader.configurePreview(sticker: self.stickerList[indexPath.section], sectionIndex: indexPath.section, isGift: self.isGift)
            } else { //StickerPageType.MAIN
                foodHeader.configure(sticker: self.stickerTabs[indexPath.section])
            }
        }
        return headerView
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.stickerPageType == StickerPageType.CATEGORY {
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
