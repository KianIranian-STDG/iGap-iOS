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
import IGProtoBuff

class IGMediaPager: BaseViewController, FSPagerViewDelegate, FSPagerViewDataSource {
    
    public var ownerId: Int64!
    public var messageId: Int64?
    public var mediaPagerType: MediaPagerType?
    public var avatarType: AvatarType?

    private var mediaList: [IGRoomMessage]?
    private var avatarList: [IGAvatar]?
    private var realmAvatarList: Results<IGAvatar>?
    private var mediaCount: Int!
    private var startIndex: Int!
    private var totalCount: Int!
    private var currentIndex: Int!
    private var showItemInfoLayout = true
    private var pagerView: FSPagerView!
    private var avatarsObserver: NotificationToken?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var txtCount: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var txtMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mediaPagerType == .avatar {
            fetchAvatars()
        } else {
            fetchMessagesMedia()
        }
        
        pagerView = FSPagerView(frame: self.view.frame)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.transformer = FSPagerViewTransformer(type: .depth)
        pagerView.fadeOut(0)
        pagerView.register(IGMediaPagerCell.nib(), forCellWithReuseIdentifier: IGMediaPagerCell.cellReuseIdentifier())
        self.view.addSubview(pagerView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.pagerView.scrollToItem(at: self.startIndex, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.pagerView.fadeIn(0.35)
        }
        
        self.manageCurrentMedia()
        self.manageDeleteButton()
        
        self.topViewHeight.constant = 55 + UIApplication.shared.statusBarFrame.size.height
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /** manage show delete button or no */
    private func manageDeleteButton(){
        if mediaPagerType != .avatar {
            return
        }
        
        if avatarType == .user {
            if ownerId == IGAppManager.sharedManager.userID()! {
                btnDelete.isHidden = false
            }
        } else if let room = IGRoom.existRoomInLocal(roomId: ownerId) {
            if avatarType == .group && (room.groupRoom?.role == IGPGroupRoom.IGPRole.owner || room.groupRoom?.role == IGPGroupRoom.IGPRole.admin) {
                btnDelete.isHidden = false
            } else if avatarType == .channel && (room.channelRoom?.role == IGPChannelRoom.IGPRole.owner || room.channelRoom?.role == IGPChannelRoom.IGPRole.admin) {
                btnDelete.isHidden = false
            }
        }
    }
    
    //MARK:- Fetch Media
    
    private func fetchAvatars() {
        realmAvatarList = IGAvatar.getAvatarsLocalList(ownerId: ownerId)
        self.avatarsObserver = realmAvatarList!.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                self.pagerView.reloadData()
                break
            case .update(_, _, _, _):
                self.avatarList = Array(self.realmAvatarList!)
                // all avatar deleted so close media pager
                if self.avatarList!.count == 0 {
                    self.navigationController?.popViewController(animated: true)
                }
                self.totalCount = self.avatarList!.count
                self.manageCurrentMedia()
                self.pagerView.reloadData()
                break
            case .error(let err):
                fatalError("\(err)")
                break
            }
        }
        
        startIndex = 0
        currentIndex = startIndex
        
        avatarList = Array(realmAvatarList!)
        totalCount = avatarList!.count
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            IGHelperAvatar.shared.getList(ownerId: self.ownerId, type: self.avatarType!)
        }
    }
    
    private func fetchMessagesMedia(){
        
        let sortProperties = [SortDescriptor(keyPath: "id", ascending: true)]
        
        var mediaPredicate: NSPredicate!
        var currentMediaPredicate: NSPredicate!
        
        if mediaPagerType == .imageAndVideo { // user for chat media pager
            mediaPredicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d) AND (statusRaw != %d AND statusRaw != %d)", ownerId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
            currentMediaPredicate = NSPredicate(format: "roomId = %lld AND id =< %lld AND (typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d) AND (statusRaw != %d AND statusRaw != %d)", ownerId, messageId!, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
            
        } else if mediaPagerType == .image { // use for avatar or share media image type
            mediaPredicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d) AND (statusRaw != %d AND statusRaw != %d)", ownerId, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
            currentMediaPredicate = NSPredicate(format: "roomId = %lld AND id =< %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d) AND (statusRaw != %d AND statusRaw != %d)", ownerId, messageId!, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
            
        } else if mediaPagerType == .video { // user for share media video type
            mediaPredicate = NSPredicate(format: "roomId = %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d) AND (statusRaw != %d AND statusRaw != %d)", ownerId, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
            currentMediaPredicate = NSPredicate(format: "roomId = %lld AND id =< %lld AND (typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d) AND (statusRaw != %d AND statusRaw != %d)", ownerId, messageId!, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageStatus.sending.rawValue, IGRoomMessageStatus.failed.rawValue)
        }
        
        let mediaListResult = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(mediaPredicate).sorted(by: sortProperties)
        let mediaListIndex = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(currentMediaPredicate).sorted(by: sortProperties)
        
        startIndex = mediaListIndex.count - 1
        currentIndex = startIndex
        
        mediaList = Array(mediaListResult)
        totalCount = mediaList?.count
    }
    
    /** set media message and update count if room message has text value */
    private func manageCurrentMedia(time:TimeInterval = 0) {
        
        var listCount: Int!
        
        if mediaPagerType == .avatar {
            listCount = avatarList!.count
        } else {
            listCount = mediaList!.count
        }
        
        if listCount <= currentIndex {
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
        
        // don't continue if current pager is for avatar, because avatar dosen't have message text
        if mediaPagerType == .avatar {
            self.bottomView.fadeOut(0)
            return
        }
        
        let roomMessage = mediaList![currentIndex]
        let finalMessage = roomMessage.getFinalMessage()
        if let message = finalMessage.message, !message.isEmpty {
            txtMessage.text = message
            bottomViewHeight.constant = CellSizeCalculator.sharedCalculator.mediaPagerCellSize(message: roomMessage).messageHeight.height
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
    
    @IBAction func btnShare(_ sender: UIButton) {
        IGHelperPopular.shareAttachment(url: mediaList![currentIndex].getFinalMessage().attachment?.path(), viewController: self)
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
        // don't need to use completion because avatar observed into the class
        IGHelperAvatar.shared.delete(roomId: ownerId, avatarId: avatarList![currentIndex].id, type: avatarType!, completion: {})
    }
    
    // MARK:- FSPagerView
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        if mediaPagerType == .avatar {
            return avatarList!.count
        } else {
            return mediaList!.count
        }
    }
        
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if mediaPagerType == .avatar {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: IGMediaPagerCell.cellReuseIdentifier(), at: index) as! IGMediaPagerCell
            cell.setAvatarItem(avatar: avatarList![index], size: CellSizeCalculator.sharedCalculator.mediaPagerCellSize(avatar: avatarList![index]))
            return cell
        } else {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: IGMediaPagerCell.cellReuseIdentifier(), at: index) as! IGMediaPagerCell
            cell.setMessageItem(message: mediaList![index], size: CellSizeCalculator.sharedCalculator.mediaPagerCellSize(message: mediaList![index]))
            return cell
        }
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
