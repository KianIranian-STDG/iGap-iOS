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
import FSPagerView

class IGMediaPager: BaseViewController, FSPagerViewDelegate, FSPagerViewDataSource {
    
    public var roomId: Int64!
    public var messageId: Int64!
    public var mediaPagerType: MediaPagerType!

    private var mediaList: [IGRoomMessage]!
    private var mediaCount: Int!
    private var startIndex: Int!
    private var totalCount: Int!
    private var currentIndex: Int!
    private var showItemInfoLayout = true
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var txtCount: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMedia()
        btnShare.isHidden = true
        let pagerView = FSPagerView(frame: self.view.frame)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.transformer = FSPagerViewTransformer(type: .depth)
        pagerView.fadeOut(0)
        pagerView.register(IGMediaPagerCell.nib(), forCellWithReuseIdentifier: IGMediaPagerCell.cellReuseIdentifier())
        self.view.addSubview(pagerView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            pagerView.scrollToItem(at: self.startIndex, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            pagerView.fadeIn(0.05)
        }
        
        self.manageCurrentMedia()
        
        self.topViewHeight.constant = 60 + UIApplication.shared.statusBarFrame.size.height
        self.view.bringSubviewToFront(topView)
        self.view.bringSubviewToFront(bottomView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    
    private func fetchMedia(){
        
        let sortProperties = [SortDescriptor(keyPath: "id", ascending: true)]
        
        var mediaPredicate: NSPredicate!
        var currentMediaPredicate: NSPredicate!
        
        if mediaPagerType == .imageAndVideo { // user for chat media pager
            mediaPredicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", roomId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue)
            currentMediaPredicate = NSPredicate(format: "roomId = %lld AND id =< %lld AND (typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", roomId, messageId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue)
            
        } else if mediaPagerType == .image { // use for avatar or share media image type
            mediaPredicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", roomId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue)
            currentMediaPredicate = NSPredicate(format: "roomId = %lld AND id =< %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", roomId, messageId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue)
            
        } else if mediaPagerType == .video { // user for share media video type
            mediaPredicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", roomId, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue)
            currentMediaPredicate = NSPredicate(format: "roomId = %lld AND id =< %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", roomId, messageId, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue)
        }
        
        let mediaListResult = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(mediaPredicate).sorted(by: sortProperties)
        let mediaListIndex = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(currentMediaPredicate).sorted(by: sortProperties)
        
        startIndex = mediaListIndex.count - 1
        currentIndex = startIndex
        
        mediaList = Array(mediaListResult)
        totalCount = mediaList.count
    }
    
    /** set media message and update count if room message has text value */
    private func manageCurrentMedia(time:TimeInterval = 0) {
        
        if mediaList.count <= currentIndex {
            return //index out of bound
        }
        var totalCountString: String!
        var currentIndexString: String!
        
        if self.TextAlignment == .right {
            totalCountString = "\(totalCount!)".inPersianNumbersNew()
            currentIndexString = "\(currentIndex+1)".inPersianNumbersNew()
        } else {
            totalCountString = "\(totalCount!)"
            currentIndexString = "\(currentIndex+1)"
        }
        
        txtCount.text = "\(currentIndexString!) \(IGStringsManager.Of.rawValue.localized) \(totalCountString!)"
        let roomMessage = mediaList[currentIndex]
        let finalMessage = roomMessage.getFinalMessage()
        if let message = finalMessage.message, !message.isEmpty {
            txtMessage.text = message
            bottomViewHeight.constant = CellSizeCalculator.sharedCalculator.mediaViewerCellSize(message: roomMessage).messageHeight.height
            if showItemInfoLayout {
                self.bottomView.fadeIn(time)
            }
            
            if message.isRTL() {
                self.txtMessage.textAlignment = NSTextAlignment.right
            } else {
                self.txtMessage.textAlignment = NSTextAlignment.left
            }
            
        } else {
            self.bottomView.fadeOut(time)
        }
    }
    
    // MARK:- User Actions
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    // MARK:- FSPagerView
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return mediaList.count
    }
        
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: IGMediaPagerCell.cellReuseIdentifier(), at: index) as! IGMediaPagerCell
        cell.setMessageItem(message: mediaList[index], size: CellSizeCalculator.sharedCalculator.mediaViewerCellSize(message: mediaList[index]))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if showItemInfoLayout {
            showItemInfoLayout = false
            self.topView.fadeOut(0.3)
            self.bottomView.fadeOut(0.3)
        } else {
            showItemInfoLayout = true
            self.topView.fadeIn(0.3)
            manageCurrentMedia(time: 0.3)
        }
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        currentIndex = targetIndex
        manageCurrentMedia()
    }
}
