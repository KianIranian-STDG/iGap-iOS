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
    private var isExpand = false
    private var pagerView: FSPagerView!
    private var avatarsObserver: NotificationToken?
    private var defaultHeight: CGFloat!
    private var canExpand = false
    private var extraViewHeight: CGFloat = 20 // this extra value is add because of extra space from bottom and top of the text and background view
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var txtCount: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet var txtMessage: ActiveLabel!
    @IBOutlet weak var txtMessageHeight: NSLayoutConstraint!
    
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtMessage.isUserInteractionEnabled = true
        
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
        txtMessageHeight.constant = bottomViewHeight.constant - extraViewHeight - IGGlobal.fetchBottomSafeArea() // set message height at start
        
        self.topViewHeight.constant = 55 + UIApplication.shared.statusBarFrame.size.height
        self.view.bringSubviewToFront(topView)
        self.view.bringSubviewToFront(bottomView)
        
        let bottomViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnBottomView))
        bottomViewTap.delegate = self
        bottomView.addGestureRecognizer(bottomViewTap)
        bottomView.isUserInteractionEnabled = true
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnTopView)))
        topView.isUserInteractionEnabled = true
        self.view.backgroundColor = .black
        
        manageLink(txtMessage: txtMessage)
        
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
    
    /** manage current state for show or hide bottom and top layouts */
    private func manageShowLayouts(){
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
        
        if listCount <= currentIndex || currentIndex < 0 {
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
            let size = CellSizeCalculator.sharedCalculator.mediaPagerCellSize(message: roomMessage, force: isExpand)
            bottomViewHeight.constant = size.messageHeight + extraViewHeight + IGGlobal.fetchBottomSafeArea()
            if !isExpand {
                defaultHeight = bottomViewHeight.constant
                canExpand = size.canExpand
            }
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
        if mediaPagerType == .avatar {
            IGHelperPopular.shareAttachment(url: avatarList![currentIndex].file?.localUrl, viewController: self)
        } else {
            IGHelperPopular.shareAttachment(url: mediaList![currentIndex].getFinalMessage().attachment?.localUrl, viewController: self)
        }
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {
        // don't need to use completion because avatar observed into the class
        IGHelperAvatar.shared.delete(roomId: ownerId, avatarId: avatarList![currentIndex].id, type: avatarType!, completion: {})
    }
    
    @objc func didTapOnBottomView() {
        
        if self.isExpand {
            self.isExpand = false
            self.bottomViewHeight.constant = defaultHeight
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.txtMessageHeight.constant = self.bottomViewHeight.constant - self.extraViewHeight - IGGlobal.fetchBottomSafeArea()
            }
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        } else {
            if !canExpand {
                return
            }
            self.isExpand = true
            let roomMessage = self.mediaList![self.currentIndex]
            let size = CellSizeCalculator.sharedCalculator.mediaPagerCellSize(message: roomMessage, force: true)
            self.bottomViewHeight.constant = size.messageHeight + self.extraViewHeight + IGGlobal.fetchBottomSafeArea()
            self.txtMessageHeight.constant = size.messageHeight
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func didTapOnTopView() {
        manageShowLayouts()
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
        manageShowLayouts()
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        if currentIndex != targetIndex {
            UIApplication.topViewController()?.removeAllZoomBehavior()
            self.isExpand = false
        }
        currentIndex = targetIndex
        manageCurrentMedia()
        txtMessageHeight.constant = bottomViewHeight.constant - extraViewHeight - IGGlobal.fetchBottomSafeArea()
    }
    
    // MARK:- Link Detection
    
    private func manageLink(txtMessage: ActiveLabel?){
        txtMessage!.font = UIFont.igFont(ofSize: fontDefaultSize)
    
        txtMessage!.customize {(lable) in

            if delegate == nil {
                self.delegate = self
            }
            lable.EmailColor = UIColor.iGapLink()
            lable.hashtagColor = UIColor.iGapLink()
            lable.mentionColor = UIColor.iGapLink()
            lable.URLColor = UIColor.iGapLink()
            lable.botColor = UIColor.iGapLink()
            lable.boldColor = .white

            lable.handleURLTap { url in
                self.delegate?.didTapOnURl(url: url)
                return
            }

            lable.handleDeepLinkTap({ (deepLink) in
                self.delegate?.didTapOnDeepLink(url: deepLink)
                return
            })

            lable.handleEmailTap { email in
                self.delegate?.didTapOnEmail(email: email.absoluteString)
                return
            }

            lable.handleBotTap {bot in
                self.delegate?.didTapOnBotAction(action: bot)
                return
            }

            lable.handleMentionTap { mention in
                self.delegate?.didTapOnMention(mentionText: mention )
                return
            }

            lable.handleHashtagTap { hashtag in
                self.delegate?.didTapOnHashtag(hashtagText: hashtag)
                return
            }
            
            lable.handleNoneTap {
                self.didTapOnBottomView()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view!.isDescendant(of: self.bottomView)){
            return false
        }
        return true
    }
    
}
extension IGMediaPager : IGMessageGeneralCollectionViewCellDelegate {
    func didTapAndHoldOnMessage(cellMessage: IGRoomMessage, index: IndexPath) {
        return
    }
    
    func swipToReply(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnAttachment(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnForwardedAttachment(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnSenderAvatar(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnReply(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnForward(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnMultiForward(cellMessage: IGRoomMessage, isFromCloud: Bool) {
        return
    }
    
    func didTapOnFailedStatus(cellMessage: IGRoomMessage) {
        return
    }
    
    func didTapOnReturnToMessage() {
        return
    }
    
    func didTapOnHashtag(hashtagText: String) {
        return
    }
    
    func didTapOnMention(mentionText: String) {
        
        var finalString = mentionText.trimmingCharacters(in: .whitespaces)
        
        if finalString[finalString.startIndex] == "@" {
            finalString.remove(at: finalString.startIndex)
        }
        
        IGHelperChatOpener.checkUsernameAndOpenRoom(username: finalString)
        
    }
    
    func didTapOnEmail(email: String) {
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func didTapOnURl(url: URL) {
        var urlString = url.absoluteString
        let urlStringLower = url.absoluteString.lowercased()
        
        if urlStringLower.contains("https://igap.net/join") || urlStringLower.contains("http://igap.net/join") ||  urlStringLower.contains("igap.net/join") {
            didTapOnRoomLink(link: urlString)
            return
        }
        
        if !(urlStringLower.contains("https://")) && !(urlStringLower.contains("http://")) {
            urlString = "http://" + urlString
        }
        
        IGHelperOpenLink.openLink(urlString: urlString)
    }
    
    func didTapOnDeepLink(url: URL) {
        DeepLinkManager.shared.handleDeeplink(url: url)
        DeepLinkManager.shared.checkDeepLink()
    }
    
    func didTapOnRoomLink(link: String) {
        return
    }
    
    func didTapOnBotAction(action: String) {
        return
    }
    
    func didTapOnContactDetail(contact: IGRoomMessageContact) {
        return
    }
    
    func didTapOnUserName(user: IGRegisteredUser) {
        return
    }
    
    
}
