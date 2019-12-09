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

class IGMediaViewer: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionViewFlowLayout!
    private var indexOfCellBeforeDragging = 0
    
    public var roomId: Int64!
    public var messageId: Int64!
    public var mediaViewerType: MediaViewerType!
    
    private var mediaList: Results<IGRoomMessage>!
    private var mediaCount: Int!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        collectionView.minimumLineSpacing = 0
        fetchMedia()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewLayoutItemSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func registerNibs(){
        self.collectionView.collectionView!.register(IGMediaViewerCell.nib(), forCellWithReuseIdentifier: IGMediaViewerCell.cellReuseIdentifier())
    }
    
    // MARK:- User Actions
    
    @IBAction func btnClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnShare(_ sender: UIButton) {
        
    }
    
    // MARK:- MediaLoader Management Methods
    private func fetchMedia(){
        if mediaViewerType == .image {
            let predicate = NSPredicate(format: "roomId = %lld AND id = %lld AND (typeRaw = %d OR typeRaw = %d)", roomId, messageId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue)
            mediaList = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate)
        } else if mediaViewerType == .video {
            let predicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d)", roomId, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue)
            mediaList = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate)
        }
    }
    
    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMediaViewerCell.cellReuseIdentifier(), for: indexPath) as! IGMediaViewerCell
        cell.setMessageItem(message: mediaList[indexPath.row], size: CellSizeCalculator.sharedCalculator.mediaViewerCellSize(message: mediaList[indexPath.row]))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionFrame = collectionView.frame
        return CGSize(width: collectionFrame.width, height: collectionFrame.height)
    }
    
    
    // MARK: - Horizontal Collection Pager Management
    private func calculateSectionInset() -> CGFloat {
        let deviceIsIpad = UIDevice.current.userInterfaceIdiom == .pad
        let deviceOrientationIsLandscape = UIDevice.current.orientation.isLandscape
        let cellBodyViewIsExpended = deviceIsIpad || deviceOrientationIsLandscape
        let cellBodyWidth: CGFloat = 236 + (cellBodyViewIsExpended ? 174 : 0)
        let buttonWidth: CGFloat = 50
        return (collectionView.collectionView!.frame.width - cellBodyWidth + buttonWidth) / 4
    }
    
    private func configureCollectionViewLayoutItemSize() {
        //Hint: With Inset
        /*
        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionViewLayout.itemSize = CGSize(width: collectionViewLayout.collectionView!.frame.size.width - inset * 2, height: collectionViewLayout.collectionView!.frame.size.height)
        */
        
        collectionView.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.itemSize = CGSize(width: CellSizeLimit.MediaViewerCellSize.MaxWidth , height: CellSizeLimit.MediaViewerCellSize.MaxHeight )
    }
    
    private func indexOfMajorCell() -> Int {
        let itemWidth = collectionView.itemSize.width
        let proportionalOffset = collectionView.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(mediaList.count - 1, index))
        return safeIndex
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()
        
        // calculate conditions:
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < mediaList.count && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            if hasEnoughVelocityToSlideToTheNextCell {
                let indexPath = IndexPath(row: indexOfCellBeforeDragging + 1, section: 0)
                collectionView.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            } else if hasEnoughVelocityToSlideToThePreviousCell {
                let indexPath = IndexPath(row: indexOfCellBeforeDragging - 1, section: 0)
                collectionView.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        } else {
            // This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionView.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}
