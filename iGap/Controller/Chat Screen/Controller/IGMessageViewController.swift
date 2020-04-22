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
import IGProtoBuff
import SwiftProtobuf
import pop
import SnapKit
import AVFoundation
import DBAttachmentPickerControllerLibrary
import AVKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa
import MBProgressHUD
import ContactsUI
import MobileCoreServices
import MarkdownKit
import SwiftyJSON
import Alamofire
import KeychainSwift
import webservice
import SwiftyRSA
import AVFoundation
import YPImagePicker
import SwiftEventBus
import Files
import AsyncDisplayKit

public var indexOfVideos = [Int]()
class IGHeader: UICollectionReusableView {
    
    override var reuseIdentifier: String? {
        get {
            return "IGHeader"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        
        let label = UILabel(frame: frame)
        label.text = "sdasdasdasd"
        self.addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class IGMessageViewController: BaseViewController, DidSelectLocationDelegate, UIDocumentInteractionControllerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate, EPPickerDelegate, UIDocumentPickerDelegate, UIWebViewDelegate, UITextFieldDelegate, HandleReciept {
    
    //newUITextMessage
    // MARK: - Outlets
    //MARK: -NODE
//    private let chatNode = ChatControllerNode()
    private(set) var chatsArray: [Chat] = []
    @IBOutlet weak var tableviewMessagesView : UIView!
    @IBOutlet weak var stackAttachment: UIStackView!
    @IBOutlet weak var attachmentBtnWidthConstraint: NSLayoutConstraint!

    private var tableViewNode : ASTableNode!
    var finalRoom: IGRoom!
    var middleIndex : IndexPath = [0,0]
    var newMessageArrivedCount : Int = 0
    @IBOutlet weak var lblUnreadArrieved : UILabel!
    @IBOutlet weak var scrollToBottomBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackTopViews: UIStackView!
    @IBOutlet weak var stackMessageView: UIStackView!
    @IBOutlet weak var mainHolder: UIStackView!
    @IBOutlet weak var holderRecordView: UIView!
    @IBOutlet weak var holderAttachmentBar: UIView!
    @IBOutlet weak var holderReplyBar: UIView!
    @IBOutlet weak var iconReplyBar: UILabel!
    @IBOutlet weak var holderTextBox: UIView!
    @IBOutlet weak var holderMultiSelect: UIView!
    @IBOutlet weak var holderMusicPlayer: UIView!

    @IBOutlet weak var lblFileType: UILabel!
    @IBOutlet weak var lblActionType: UILabel!
    @IBOutlet weak var lblFirstInStack: UILabel!
    @IBOutlet weak var lblSecondInStack: UILabel!
    @IBOutlet weak var lblThirdInStack: UILabel!
    @IBOutlet weak var lblFileSize: UILabel!
    
    @IBOutlet weak var lblReplyName: UILabel!
    @IBOutlet weak var lblReplyBody: UILabel!
    
    @IBOutlet weak var imgAttachmentImage: UIImageView!
    @IBOutlet weak var btnCloseTopBar: UIButton!
    @IBOutlet weak var btnCloseReplyBar: UIButton!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var lblCenterText: UILabel!
    @IBOutlet weak var lblCenterIcon: UILabel!
    @IBOutlet weak var btnSticker: UIButton!
    @IBOutlet weak var btnMicInner: UIButton!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnMoney: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnAttachmentNew: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var holderMessageTextView: UIView!
    @IBOutlet weak var viewTopHolder : UIView!
    @IBOutlet weak var btnStickerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtPinnedMessage: UILabel!
    @IBOutlet weak var txtPinnedMessageTitle: UILabel!
    @IBOutlet weak var collectionView: IGMessageCollectionView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var btnScrollToBottom: UIButton!
    @IBOutlet weak var btnClosePin: UIButton!
    @IBOutlet weak var lblSelectedMessages: UILabel!
    @IBOutlet weak var inputBarRecordTimeLabel: UILabel!
    @IBOutlet weak var inputBarRecodingBlinkingView: UIView!
    @IBOutlet weak var scrollToBottomContainerView: UIView!
    //@IBOutlet weak var scrollToBottomBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatBackground: UIImageView!
    @IBOutlet weak var floatingDateView: UIView!
    @IBOutlet weak var txtFloatingDate: UILabel!
    
    // MARK: - Variables
    private var myNavigationItem: IGNavigationItem!
    var multiShareModalOriginalHeight : CGFloat!
    var alreadyInSendMode : Bool = false
    var musicFile : MusicFile!
    private var beforeMessageLineCount: CGFloat = -1
    private var bConstraint: NSLayoutConstraint!

    //musicplayer variables
    var singerName: String! = ""
    var songName: String! = ""
    var songTimer: Float! = 0.0
    
    var MoneyTransactionModal : SMMoneyTransactionOptions!
    var MoneyInputModal : SMSingleAmountInputView!
    var CardToCardModal : SMTwoInputView!
    var giftStickerModal : SMGiftStickerAlertView!
    var forwardModal : IGMultiForwardModal!
    var MoneyTransactionModalIsActive = false
    var MoneyInputModalIsActive = false
    var MultiShareModalIsActive = false
    var CardToCardModalIsActive = false
    var giftStickerModalIsActive = false
    var isBoth = false
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    var dissmissViewBG = UIView()
    var dismissBtn : UIButton!
    var previousRect = CGRect.zero
    var webView: UIWebView!
    var webViewProgressbar: UIActivityIndicatorView!
    var btnChangeKeyboard : UIButton!
    var doctorBotScrollView : UIScrollView!
    var latestTypeTime : Int64 = IGGlobal.getCurrentMillis()
    var allowForGetHistory: Bool = true
    var recorder: AVAudioRecorder?
    var isRecordingVoice = false
    var voiceRecorderTimer: Timer?
    var recordedTime: Int = 0
    var inputTextViewHeight: CGFloat = 0.0
    var inputBarRecordRightBigViewWidthConstraintInitialValue: CGFloat = 0.0
    var inputBarRecordRightBigViewInitialFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var bouncingViewWhileRecord: UIView?
    var initialLongTapOnRecordButtonPosition: CGPoint?
    var collectionViewTopInsetOffset: CGFloat = 0.0
    var connectionStatus : IGAppManager.ConnectionStatus?
    var reportMessageId: Int64?
    var swipeGesture: UIPanGestureRecognizer!
    var originalPoint: CGPoint!
    var selectedMessages : [IGRoomMessage] = []
    var sendTone: AVAudioPlayer?
    var isFromCloud : Bool = false
    let documentPickerIdentifiers = [String(kUTTypeURL), String(kUTTypeFileURL), String(kUTTypePDF), // file start
        String(kUTTypeGNUZipArchive), String(kUTTypeBzip2Archive), String(kUTTypeZipArchive),
        String(kUTTypeWebArchive), String(kUTTypeTXNTextAndMultimediaData), String(kUTTypeFlatRTFD),
        String(kUTTypeRTFD), // file end
        String(kUTTypeGIF), // gif
        String(kUTTypeText), String(kUTTypePlainText), String(kUTTypeUTF8PlainText), // text start
        String(kUTTypeUTF16ExternalPlainText), String(kUTTypeUTF16PlainText),
        String(kUTTypeDelimitedText), String(kUTTypeRTF), // text end
        String(kUTTypeImage), String(kUTTypeJPEG), String(kUTTypeJPEG2000), // image start
        String(kUTTypeTIFF), String(kUTTypePICT), String(kUTTypePNG), String(kUTTypeQuickTimeImage),
        String(kUTTypeAppleICNS), String(kUTTypeBMP), String(kUTTypeICO), String(kUTTypeRawImage),
        String(kUTTypeScalableVectorGraphics), // image end
        String(kUTTypeMovie), String(kUTTypeVideo), String(kUTTypeQuickTimeMovie), // video start
        String(kUTTypeMPEG), String(kUTTypeMPEG2Video), String(kUTTypeMPEG2TransportStream),
        String(kUTTypeMPEG4), String(kUTTypeAppleProtectedMPEG4Video), String(kUTTypeAVIMovie),
        String(kUTTypeMPEG2Video),// video end
        String(kUTTypeAudiovisualContent), String(kUTTypeAudio), String(kUTTypeMP3), // audio start
        String(kUTTypeMPEG4Audio), String(kUTTypeAppleProtectedMPEG4Audio), String(kUTTypeAudioInterchangeFileFormat),
        String(kUTTypeWaveformAudio), String(kUTTypeMIDIAudio)] // audio end
    
    
    public var deepLinkMessageId: Int64?
    //var messages = [IGRoomMessage]()
    let sortProperties = [SortDescriptor(keyPath: "creationTime", ascending: false),
                          SortDescriptor(keyPath: "id", ascending: false)]
    let sortPropertiesForMedia = [SortDescriptor(keyPath: "creationTime", ascending: true),
                                  SortDescriptor(keyPath: "id", ascending: true)]
    private var messages: [IGRoomMessage]? = []
    static var messageIdsStatic: [Int64:[Int64]] = [:]
    var messagesWithMedia = try! Realm().objects(IGRoomMessage.self)
    
    var messagesWithForwardedMedia = try! Realm().objects(IGRoomMessage.self)
    var avatarObserver: NotificationToken?
    var roomAccessObserver: NotificationToken?
    
    var room : IGRoom?
    var forwardedMessageArray : [IGRoomMessage] = []
    var forwardFromCloud: Bool = false
    var privateRoom : IGRoom?
    var openChatFromLink: Bool = false // set true this param when user not joined to this room
    var customizeBackItem: Bool = false
    //let currentLoggedInUserID = IGAppManager.sharedManager.userID()
    let currentLoggedInUserAuthorHash = IGAppManager.sharedManager.authorHash()
    
    var selectedMessageToEdit: IGRoomMessage?
    var selectedMessageToReply: IGRoomMessage?
    static var selectedMessageToForwardToThisRoom: IGRoomMessage?
    static var selectedMessageToForwardFromThisRoom: IGRoomMessage?
    var currentAttachment: IGFile?
    var selectedUserToSeeTheirInfo: IGRegisteredUser?
    var selectedChannelToSeeTheirInfo: IGChannelRoom?
    var hud = MBProgressHUD()
    let locationManager = CLLocationManager()
    
    let MAX_TEXT_LENGHT = 4096
    let MAX_TEXT_ATTACHMENT_LENGHT = 1024
    
    var botCommandsDictionary : [String:String] = [:]
    var botCommandsArray : [String] = []
    let BUTTON_HEIGHT = 50
    let BUTTON_SPACE = 10
    let BUTTON_ROW_SPACE : CGFloat = 5
    let screenWidth = UIScreen.main.bounds.width
    var isCustomKeyboard = false
    var isKeyboardButtonCreated = false
    let KEYBOARD_CUSTOM_ICON = ""
    let KEYBOARD_MAIN_ICON = ""
    let returnText = "/back"
    
    let ANIMATE_TIME = 0.2
    
    let DOCTOR_BOT_HEIGHT = 50 // height size for main doctor bot view (Hint: size of custom button is lower than this size -> (DOCTOR_BOT_HEIGHT - (2 * DOCTOR_BUTTON_VERTICAL_SPACE)) )
    let DOCTOR_BUTTON_VERTICAL_SPACE = 6 // space between top & bottom of a custom button with doctor bot parent view
    let DOCTOR_BUTTON_SPACE : CGFloat = 10 // space between each button
    let DOCOTR_IN_BUTTON_SPACE : CGFloat = 10 // space between button and image and mainView in a custom button
    let DOCTOR_IMAGE_SIZE : CGFloat = 25 // width and height size for image
    var leftSpace : CGFloat = 0 // space each button from start of scroll view (Hint: this value will be changed programatically)
    var apiStructArray : [IGPFavorite] = []
    
    /* variables for fetch message */
    var allMessages:Results<IGRoomMessage>!
    var getMessageLimit = 25
    var scrollToTopLimit:CGFloat = 20
    var messageSize = 0
    var page = 0
    var firstId: Int64 = 0
    var lastId: Int64 = 0
    
    var isEndOfScroll = false
    var lowerAllow = true
    var allowForGetHistoryLocal = true
    var isFirstHistory = true
    var hasLocal = true
    var isStickerKeyboard = false
    var isSendLocation : Bool!
    var receivedLocation : CLLocation!
    var stickerPageType = StickerPageType.MAIN
    var stickerGroupId: String!
    var latestIndexPath: IndexPath!
    var isCardToCardRequestEnable = false
    var latestKeyboardAdditionalView: UIView!
    private var allowSendGiftCard = true // TODO - Remove this variable and find correct solution
    static var highlightMessageId: Int64 = 0 // highlight message and show fast return to message icon
    static var highlightWithoutFastReturn: Int64 = 0 // highlight message after click on fast return to message icon
    static var returnToMessage: IGRoomMessage? // after click on reply header, save clicked message for fast return to message position again
    static var giftUserId: Int64? // use this variable for detect send message to room
    
    private var cellSizeLimit: CellSizeLimit!
    
    fileprivate var typingStatusExpiryTimer = Timer() //use this to send cancel for typing status
    
    private var saveDate: [String] = []
    private var firstSetDate = true
    private var messageLoader: IGMessageLoader!
    private var currentRoomId: Int64!
    private var allowManageForward = true
    
    private var mainViewTap = UITapGestureRecognizer()
    
    private let deleteThread = DispatchQueue(label: "serial.queue.delete.cell", qos: .userInteractive)
    private var giftStickerInfo: SMCheckGiftSticker!
    private var giftStickerPaymentInfo: SMGiftCardInfo!
    private var giftStickerAlertView: SMGiftStickerAlertView!
    private var giftCardInfo: IGStructGiftCardStatus!
    private var activationGiftStickerId: String?
    private var needToNationalCode : Bool = false // TODO - check and do better structure
    private var waitingCardId: String? // TODO - check and do better structure
    private var roomAccess: IGRealmRoomAccess?
    private var forceHideAttachButton = false
    private var forceHideStickerButton = false
    
    func onMessageViewControllerDetection() -> UIViewController {
        return self
    }
    
    func onNavigationControllerDetection() -> UINavigationController {
        return self.navigationController!
    }
    
    func showMultiSelectUI(state : Bool!,isForward:Bool? = nil,isDelete:Bool?=nil,id: Int64) {
        myNavigationItem?.setNavigationBarForRoom(room!)
        setRightNavViewAction()
        
        if state {
//            mainViewTap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnMainView))
            tableViewNode.view.removeGestureRecognizer(mainViewTap)
            if isForward! {
                UIView.transition(with: self.holderTextBox, duration: ANIMATE_TIME, options: .transitionCrossDissolve, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.holderMultiSelect.isHidden = !isForward!
                    sSelf.holderTextBox.isHidden = isForward!
                    
                    sSelf.btnMoney.isHidden = true
                    sSelf.btnMic.isHidden = true
                    sSelf.btnSend.isHidden = true
                    sSelf.btnShare.isHidden = true

                    //rightbar btns
                    sSelf.btnShare.isHidden = true
                    sSelf.btnTrash.isHidden = true
                    sSelf.btnAttachmentNew.isHidden = true
                    
                    
                    sSelf.btnForward.isHidden = !isForward!
                    
                    IGGlobal.shouldMultiSelect = true
                    
                    let allIndexes = IGGlobal.getAllIndexPathsInSection(section : 0,tblList: sSelf.tableViewNode)
                    
                    for nodeIndex in allIndexes {
                        if let node = sSelf.tableViewNode.nodeForRow(at: nodeIndex) as? ChatControllerNode {
//                            if let nodeAbs = self.tableViewNode.nodeForRow(at: nodeIndex) as? AbstractNode {
//                                nodeAbs.EnableDisableInteractions(mode: true)
//                            }
                            node.EnableDisableInteractions(mode: true)
                            node.makeAccessoryButton(id: id)
                        }
                    }

                    
                }, completion: { (completed) in
                    self.btnShare.isHidden = true
                    self.btnForward.isHidden = !isForward!
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.btnShare.isHidden = true
                    self.btnForward.isHidden = !isForward!
                }
                
            }
            else if isDelete! {
                
                UIView.transition(with: self.holderTextBox, duration: ANIMATE_TIME, options: .transitionCrossDissolve, animations: {[weak self] in
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.holderMultiSelect.isHidden = !isDelete!
                    sSelf.holderTextBox.isHidden = isDelete!
                    
                    sSelf.btnMoney.isHidden = true
                    sSelf.btnMic.isHidden = true
                    sSelf.btnSend.isHidden = true
                    sSelf.btnShare.isHidden = true

                    //rightbar btns
                    sSelf.btnShare.isHidden = true
                    sSelf.btnForward.isHidden = true
                    sSelf.btnAttachmentNew.isHidden = true
                    
                    sSelf.btnTrash.isHidden = !isDelete!
                    IGGlobal.shouldMultiSelect = true
                    
                    let allIndexes = IGGlobal.getAllIndexPathsInSection(section : 0,tblList: sSelf.tableViewNode)
                    
                    for nodeIndex in allIndexes {
                        if let node = sSelf.tableViewNode.nodeForRow(at: nodeIndex) as? ChatControllerNode {
//                            if let nodeAbs = self.tableViewNode.nodeForRow(at: nodeIndex) as? AbstractNode {
//                                nodeAbs.EnableDisableInteractions(mode: true)
//                            }
                            node.EnableDisableInteractions(mode: true)
                            node.makeAccessoryButton(id: id)
                        }
                    }

                    

                    
                }, completion: { (completed) in
                    //                self.view.layoutIfNeeded()
                    self.holderMultiSelect.isHidden = !isDelete!
                    self.holderTextBox.isHidden = isDelete!
                    self.btnTrash.isHidden = !isDelete!

                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.holderMultiSelect.isHidden = !isDelete!
                    self.holderTextBox.isHidden = isDelete!
                    self.btnTrash.isHidden = !isDelete!
                }
            }
        }
        else {
            
            tableViewNode.view.addGestureRecognizer(mainViewTap)
            UIView.transition(with: self.holderTextBox, duration: ANIMATE_TIME, options: .transitionCrossDissolve, animations: {
                self.holderMultiSelect.isHidden = true
                self.holderTextBox.isHidden = false
                
                if !(IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
                    self.btnMoney.isHidden = true
                } else {
                    if self.isBotRoom(){
                        self.btnMoney.isHidden = true
                        
                    }
                    else {
                        self.btnMoney.isHidden = false
                    }
                }
            
                self.btnMic.isHidden = false

                self.btnShare.isHidden = true

                //rightbar btns
                self.btnShare.isHidden = true
                self.btnForward.isHidden = true
                self.btnAttachmentNew.isHidden = false
                
                self.btnTrash.isHidden = true

                let allIndexes = IGGlobal.getAllIndexPathsInSection(section : 0,tblList: self.tableViewNode)
                
                for nodeIndex in allIndexes {
                    if let node = self.tableViewNode.nodeForRow(at: nodeIndex) as? ChatControllerNode {
                        node.EnableDisableInteractions(mode: false)
                        node.removeAccessoryButton()
                    }
                }
                
                
            }, completion: { (completed) in
            })
        }
        
        if self.selectedMessages.count > 0 {
            lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + "  " + IGStringsManager.Selected.rawValue.localized
            btnTrash.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
            btnTrash.isEnabled = true
        } else {
            lblSelectedMessages.text = ""
            btnTrash.setTitleColor(UIColor.iGapGray(), for: .normal)
            btnTrash.isEnabled = false
            
            btnForward.setTitleColor(UIColor.iGapGray(), for: .normal)
            btnForward.isEnabled = false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? true {
                self.initTheme()
            }
        }
    }
    
    private func setRightNavViewAction() {
        
        if let myNav = myNavigationItem {
            weak var weakSelf = self
            myNav.rightViewContainer?.addAction {
                if weakSelf?.room?.type == .chat {
                    if let user = weakSelf?.room?.chatRoom?.peer, user.lastSeenStatus != .serviceNotification, user.lastSeenStatus != .support {
                        weakSelf?.selectedUserToSeeTheirInfo = user
                        weakSelf?.openUserProfile()
                    }
                }
                if weakSelf?.room?.type == .channel {
                    weakSelf?.selectedChannelToSeeTheirInfo = weakSelf?.room?.channelRoom
                    
                    let profile = IGProfileChannelViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                    profile.selectedChannel = weakSelf?.selectedChannelToSeeTheirInfo
                    profile.room = weakSelf?.room
                    profile.myRole = weakSelf?.room?.channelRoom?.role
                    profile.hidesBottomBarWhenPushed = true
                    weakSelf?.navigationController!.pushViewController(profile, animated: true)
                }
                if weakSelf?.room?.type == .group {
                    
                    let profile = IGProfileGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                    profile.selectedGroup = weakSelf?.room?.groupRoom
                    profile.room = weakSelf?.room
                    profile.hidesBottomBarWhenPushed = true
                    weakSelf?.navigationController!.pushViewController(profile, animated: true)
                }
            }

        }
    }
    
    
    //MARK: - Initilizers
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblUnreadArrieved.isHidden = true
        self.lblUnreadArrieved.textColor = .white
        self.lblUnreadArrieved.text = self.lblUnreadArrieved.text?.inLocalizedLanguage()
        self.lblUnreadArrieved.layer.cornerRadius = 7.5
        self.lblUnreadArrieved.layer.masksToBounds = true
        self.lblUnreadArrieved.backgroundColor = ThemeManager.currentTheme.SliderTintColor

        ///newUITextMessage
        initViewNewChatView()
        initFontsNewChatView()
        initAlignmentsNewChatView()
        initChangeLanguegeNewChatView()
        initDelegatesNewChatView()
        initAvatarObserver()
        initRoomAccessObserver()
        eventBusInitialiser()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.TextFieldPlaceHolderColor ,
            NSAttributedString.Key.font: UIFont.igFont(ofSize: 13) // Note the !
        ]
        self.removeHideKeyboardWhenTappedAround()
        self.initChangeLanguegeNewChatView()

        holderMusicPlayer.isHidden = true
        joinButton.isHidden = true
        allowSendGiftCard = true

        if !(IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
            btnMoney.isHidden = true
        } else {
            if isBotRoom() {
                btnMoney.isHidden = true
                showHideStickerButton(shouldShow: false)
                self.btnStickerWidthConstraint.constant = 0.0

            } else {
                btnMoney.isHidden = false
                showHideStickerButton(shouldShow: true)
                self.btnStickerWidthConstraint.constant = 25.0
            }
        }
        tmpUserID = self.room?.chatRoom?.peer?.id
        self.finalRoom = self.room!.detach()

        switch self.room!.type {
        case .chat:
            if !(IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
                self.btnMoney.isHidden = true
            }
            else {
                if !(IGAppManager.sharedManager.mplActive()) && (IGAppManager.sharedManager.walletActive()) {
                    
                }
                else if (IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
                    if isBotRoom() {
                        self.btnMoney.isHidden = true
                        self.isCardToCardRequestEnable = false
                    }
                    else {
                        self.btnMoney.isHidden = false
                        self.isCardToCardRequestEnable = true
                        self.manageCardToCardInputBar()
                    }
                } else {
                    if isBotRoom() {
//                        self.mainHolder.isHidden = false
                        self.btnMoney.isHidden = true
                    } else {
//                        self.mainHolder.isHidden = false
                        self.btnMoney.isHidden = false
                    }
                }
            }
            
        case .channel:
//            self.mainHolder.isHidden = false
            self.btnMoney.isHidden = true

        default:
            self.btnMoney.isHidden = true
            
        }
        IGMessageViewController.messageIdsStatic[(self.room?.id)!] = []
        txtFloatingDate.font = UIFont.igFont(ofSize: 15)
        
        removeButtonsUnderline(buttons: [btnMic, btnScrollToBottom, btnMoney, btnClosePin])
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { [weak self] (connectionStatus) in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(connectionStatus)
            }
        }, onError: { (error) in
            print("onError IGMessageViewController: \(error)")
        }, onCompleted: {
            print("onCompleted IGMessageViewController")
        }, onDisposed: {
            print("onDisposed IGMessageViewController")
        }).disposed(by: disposeBag)
        
        /*
         let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.tapOnMainView))
         mainView.addGestureRecognizer(gesture)
         */
        var canBecomeFirstResponder: Bool { return true }
//        if let navigationController = self.navigationController as? IGNavigationController {
         let navigationController = self.navigationController as? IGNavigationController
            myNavigationItem = self.navigationItem as? IGNavigationItem
            myNavigationItem.navigationController = navigationController
            myNavigationItem.setNavigationBarForRoom(room!)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
            weak var weakSelf = self

            myNavigationItem.backViewContainer?.addAction {
                weakSelf?.deallocate()
                weakSelf?.back()
            }

            
            setRightNavViewAction()
            
            myNavigationItem.centerViewContainer?.addAction ({
                if weakSelf?.room?.type == .chat {
                    if let user = weakSelf?.room?.chatRoom?.peer, user.lastSeenStatus != .serviceNotification, user.lastSeenStatus != .support {
                        weakSelf?.selectedUserToSeeTheirInfo = user
                        weakSelf?.openUserProfile()
                    }
                } else if weakSelf?.room?.type == .channel {
                    weakSelf?.selectedChannelToSeeTheirInfo = weakSelf?.room?.channelRoom
                    let profile = IGProfileChannelViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                    profile.selectedChannel = weakSelf?.selectedChannelToSeeTheirInfo
                    profile.room = weakSelf?.room
                    profile.myRole = weakSelf?.room?.channelRoom?.role
                    profile.hidesBottomBarWhenPushed = true
                    weakSelf?.navigationController!.pushViewController(profile, animated: true)
                } else if weakSelf?.room?.type == .group {
                    let profile = IGProfileGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                    profile.selectedGroup = weakSelf?.room?.groupRoom
                    profile.room = weakSelf?.room
                    profile.hidesBottomBarWhenPushed = true
                    weakSelf?.navigationController!.pushViewController(profile, animated: true)
                }
            })
//        }
        
        
        if room!.isReadOnly {
            if room!.isParticipant == false {
                mainHolder.isHidden = true
                showJoinButton()
            } else {
                mainHolder.isHidden = true
                collectionViewTopInsetOffset = 8.0
            }
        }
        initASCollectionNode()

        if isBotRoom() {
            showHideStickerButton(shouldShow: false)
            if IGHelperDoctoriGap.isDoctoriGapRoom(room: room!) {
                self.getFavoriteMenu()
            } else {
                self.collectionViewTopInsetOffset = 0
                self.tableViewNode.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
            }
            
            let predicate = NSPredicate(format: "roomId = %lld AND (id >= %lld OR statusRaw == %d OR statusRaw == %d) AND isDeleted == false AND id != %lld" , self.room!.id, lastId ,0 ,1 ,0)
            let messagesCount = try! Realm().objects(IGRoomMessage.self).filter(predicate).count
            if messagesCount == 0 {
                mainHolder.isHidden = true
                showJoinButton()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.manageKeyboard(firstEnter: true)
                }
            }
        }
        
        let messagesWithMediaPredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND (typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d OR forwardedFrom.typeRaw = %d)", self.room!.id, IGRoomMessageType.video.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.imageAndText.rawValue, IGRoomMessageType.video.rawValue, IGRoomMessageType.image.rawValue, IGRoomMessageType.videoAndText.rawValue, IGRoomMessageType.imageAndText.rawValue)
        do {
            let realm = try Realm()
            messagesWithMedia = realm.objects(IGRoomMessage.self).filter(messagesWithMediaPredicate).sorted(by: sortPropertiesForMedia)
        } catch _ as NSError {
            print("RLM EXEPTION ERR HAPPENDED IN VIEW DID LOAD FOR MESSAGE WITH MEDIA:",String(describing: self))
        }
        
        let messagesWithForwardedMediaPredicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND (forwardedFrom.typeRaw == 1 OR forwardedFrom.typeRaw == 2 OR forwardedFrom.typeRaw == 3 OR forwardedFrom.typeRaw == 4)", self.room!.id)
        do {
            let realm = try Realm()
            messagesWithForwardedMedia = realm.objects(IGRoomMessage.self).filter(messagesWithForwardedMediaPredicate).sorted(by: sortPropertiesForMedia)
        } catch _ as NSError {
            print("RLM EXEPTION ERR HAPPENDED IN VIEW DID LOAD FOR MESSAGE WITH FORWARD MEDIA:",String(describing: self))
        }
        
        
        let bgColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        
        self.view.backgroundColor = bgColor
        self.view.superview?.backgroundColor = bgColor
        self.view.superview?.superview?.backgroundColor = bgColor
        self.view.superview?.superview?.superview?.backgroundColor = bgColor
        self.view.superview?.superview?.superview?.superview?.backgroundColor = bgColor
        
        
        self.setInputBarHeight()
        self.managePinnedMessage()

        
        initChangeLanguegeNewChatView()
        scrollToBottomContainerView.layer.cornerRadius = 20.0
        scrollToBottomContainerView.layer.masksToBounds = false
        scrollToBottomContainerView.layer.shadowColor = UIColor.black.cgColor
        scrollToBottomContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        scrollToBottomContainerView.layer.shadowRadius = 4.0
        scrollToBottomContainerView.layer.shadowOpacity = 0.15
        scrollToBottomContainerView.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        scrollToBottomContainerView.layer.borderWidth = 0.2
        scrollToBottomContainerView.layer.borderColor = #colorLiteral(red: 0.4477736669, green: 0.4477736669, blue: 0.4477736669, alpha: 1)
        scrollToBottomContainerView.isHidden = true
        
        floatingDateView.layer.cornerRadius = 12.0
        floatingDateView.alpha = 0.0
        txtFloatingDate.alpha = 0.0
        
        txtPinnedMessage.lineBreakMode = .byTruncatingTail
        txtPinnedMessage.numberOfLines = 1
        self.setCollectionViewInset()
        
        let tapOnMessageTextView = UITapGestureRecognizer(target: self, action: #selector(didTapOnInputTextView))
        messageTextView.addGestureRecognizer(tapOnMessageTextView)
        messageTextView.isUserInteractionEnabled = true
        
        if let messageId = self.deepLinkMessageId {
            // need to make 'IGMessageLoader' for first time
            messageLoader = IGMessageLoader.getInstance(room: self.room!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.goToPosition(messageId: messageId)
            }
        } else {
            startLoadMessage()
        }
        holderMusicPlayer.backgroundColor = .clear
        if IGGlobal.shouldShowTopBarPlayer {
            let value : CGFloat = 0
            var defaultValue: CGFloat = 20
            
            defaultValue = 60
            self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)

            self.createTopMusicPlayer()
        }
        initTheme()
        self.view.endEditing(true)
        
        mainViewTap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnMainView))
        tableViewNode.view.addGestureRecognizer(mainViewTap)
        
        detectWriteMessagePermission()
    }
    
    private func detectWriteMessagePermission(){
        if self.room!.type == .chat {return}

        if  !(self.roomAccess?.postMessageRights.sendText ?? true) {
            
            if self.room!.isParticipant {
                if self.room!.type == .group {
                    joinButton.isHidden = false
                    joinButton.setTitle(IGStringsManager.NotAllowSendMessage.rawValue.localized, for: UIControl.State.normal)
                    mainHolder.isHidden = true
                    self.messageTextView.text = ""
                    self.view.endEditing(true)
                    
                } else if self.room!.type == .channel {
                    if self.room!.channelRoom?.role == IGPChannelRoom.IGPRole.admin {
                        joinButton.isHidden = false
                        joinButton.setTitle(IGStringsManager.NotAllowSendMessage.rawValue.localized, for: UIControl.State.normal)
                        mainHolder.isHidden = true
                        self.messageTextView.text = ""
                        self.view.endEditing(true)
                    } else {
                        joinButton.isHidden = true
                        mainHolder.isHidden = true
                        self.messageTextView.text = ""
                        self.view.endEditing(true)
                    }
                }
            }
            
        } else {

            self.forceHideAttachButton = !(self.roomAccess?.postMessageRights.sendMedia ?? false)
            self.forceHideStickerButton = !(self.roomAccess?.postMessageRights.sendSticker ?? false)
            
            if self.forceHideAttachButton {
                attachmentBtnWidthConstraint.constant = 0
            } else {
                attachmentBtnWidthConstraint.constant = 35

            }
            showHideStickerButton(shouldShow: !self.forceHideStickerButton)

            joinButton.isHidden = true
            mainHolder.isHidden = false
            if !(self.roomAccess?.editMessage ?? false) {
                didTapOnCancelReplyOrForwardButton(UIButton())
            }
        }
    }
    
    private func showJoinButton(){
        joinButton.isHidden = false
        joinButton.setTitle(IGStringsManager.Start.rawValue.localized, for: UIControl.State.normal)
        joinButton.layer.cornerRadius = 5
        joinButton.layer.masksToBounds = false
        joinButton.layer.shadowColor = UIColor.black.cgColor
        joinButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        joinButton.layer.shadowRadius = 4.0
        joinButton.layer.shadowOpacity = 0.15
    }
    

    private func initASCollectionNode() {
        //flips the tableview (and all cells) upside down
        let flowlayout = UICollectionViewFlowLayout.init()
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumLineSpacing = 0.0

        self.tableViewNode = ASTableNode.init(style: .plain)
        self.tableViewNode.backgroundColor = .clear
        self.tableviewMessagesView.backgroundColor = .clear
        self.tableViewNode.view.separatorStyle = .none
        self.tableViewNode.allowsMultipleSelection = true
        self.tableViewNode.allowsSelection = true
        tableViewNode.view.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        tableViewNode.view.delaysContentTouches = false
        tableViewNode.view.keyboardDismissMode = .none

        tableViewNode.delegate = self
        tableViewNode.dataSource = self

        self.tableviewMessagesView.addSubnode(tableViewNode)
        tableViewNode.view.translatesAutoresizingMaskIntoConstraints = false
        tableViewNode.view.topAnchor.constraint(equalTo: self.tableviewMessagesView.topAnchor).isActive = true

        tableViewNode.view.leadingAnchor.constraint(equalTo: self.tableviewMessagesView.leadingAnchor).isActive = true
        tableViewNode.view.trailingAnchor.constraint(equalTo: self.tableviewMessagesView.trailingAnchor).isActive = true
        tableViewNode.view.bottomAnchor.constraint(equalTo: self.tableviewMessagesView.bottomAnchor,constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initNotificationsNewChatView()
        self.addNotificationObserverForTapOnStatusBar()
        
        if self.room!.isInvalidated {
            self.navigationController?.popViewController(animated: true)
        }
        
        IGGlobal.isInChatPage = true
        self.currentRoomId = self.room?.id
        CellSizeLimit.updateValues(roomId: (self.room?.id)!)
        
        getUserInfo()
        setBackground()
        
        if let forwardMsg = IGMessageViewController.selectedMessageToForwardToThisRoom {
            self.forwardOrReplyMessage(forwardMsg.detach(), isReply: false)
        }
        
        manageDraft()
        
        notification(register: true)
        if IGGlobal.shouldShowTopBarPlayer {
            let value : CGFloat = 0
            var defaultValue : CGFloat = 20
            
            defaultValue = 60
            self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            
            self.createTopMusicPlayer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.room!.isInvalidated {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        messageTextView.setContentOffset(.zero, animated: true)
        messageTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        
        IGRecentsTableViewController.visibleChat[(room?.id)!] = true
        if let roomVariable = IGRoomManager.shared.varible(for: room!) {
            roomVariable.asObservable().subscribe({ [weak self] (event) in
                if event.element == self?.room {
                    DispatchQueue.main.async {
                        self?.myNavigationItem?.updateNavigationBarForRoom(event.element!)
                    }
                }
            }).disposed(by: disposeBag)
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in }
        
        setMessagesRead()
        manageStickerPosition()
        IGHelperGetMessageState.shared.clearMessageViews()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func deallocate(){
        avatarObserver?.invalidate()
        roomAccessObserver?.invalidate()
        IGMessageLoader.removeInstance(roomId: self.room!.id)
    }
    
    deinit {
        print("Deinit IGMessageViewController")
    }
    
    private func initTheme() {
        lblSelectedMessages.textColor = ThemeManager.currentTheme.LabelColor
        joinButton.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
        self.holderRecordView.backgroundColor = ThemeManager.currentTheme.BackGroundColor

        if currentTheme == "IGAPDay" {
            if currentColorSetLight == "IGAPBlack" {
                joinButton.setTitleColor(.white, for: .normal)
                self.txtPinnedMessage.textColor = .white
                self.txtPinnedMessageTitle.textColor = .white
                self.lblCenterText.textColor = .white
                self.lblCenterIcon.textColor = .white
                self.inputBarRecordTimeLabel.textColor = ThemeManager.currentTheme.LabelColor
            } else {
                joinButton.setTitleColor(.white, for: .normal)
                self.txtPinnedMessage.textColor = .white
                self.txtPinnedMessageTitle.textColor = .white
                self.lblCenterText.textColor = ThemeManager.currentTheme.LabelColor
                self.lblCenterIcon.textColor = ThemeManager.currentTheme.LabelColor
                self.inputBarRecordTimeLabel.textColor = ThemeManager.currentTheme.LabelColor
            }
        } else {
            joinButton.setTitleColor(.white, for: .normal)
            self.txtPinnedMessage.textColor = .white
            self.txtPinnedMessageTitle.textColor = .white
            self.lblCenterText.textColor = ThemeManager.currentTheme.LabelColor
            self.lblCenterIcon.textColor = ThemeManager.currentTheme.LabelColor
            self.inputBarRecordTimeLabel.textColor = ThemeManager.currentTheme.LabelColor
        }

        self.messageTextView.backgroundColor = .clear
        self.btnCloseReplyBar.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnCloseTopBar.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.lblFirstInStack.textColor = ThemeManager.currentTheme.LabelColor
        self.lblSecondInStack.textColor = ThemeManager.currentTheme.LabelColor
        self.lblThirdInStack.textColor = ThemeManager.currentTheme.LabelColor
        self.lblReplyBody.textColor = ThemeManager.currentTheme.LabelColor
        self.lblReplyName.textColor = ThemeManager.currentTheme.LabelColor
        self.lblFileSize.textColor = ThemeManager.currentTheme.LabelColor
        self.iconReplyBar.textColor = ThemeManager.currentTheme.LabelColor
        self.holderReplyBar.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        self.holderAttachmentBar.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        self.viewTopHolder.backgroundColor = ThemeManager.currentTheme.TopViewHolderBGColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IGGlobal.isInChatPage = false
        
        currentRoomId = 0
        currentPageName = ""
        IGGlobal.shouldMultiSelect = false
        saveMessagePosition()
        
        if !holderReplyBar.isHidden { // maybe has forward
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
        }
        self.view.endEditing(true)
        if !room!.isInvalidated {
            IGRecentsTableViewController.visibleChat[(room?.id)!] = false
        }
        
        if let room = self.room, !room.isInvalidated {
            room.saveDraft(messageTextView.text)
            IGFactory.shared.markAllMessagesAsRead(roomId: room.id)
            if openChatFromLink { // TODO - also check if user before joined to this room don't send this request
                sendUnsubscribForRoom(roomId: room.id)
                IGRoom.setParticipant(roomId: room.id, isParticipant: false)
            }
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.tableViewNode.invalidateCalculatedLayout()
    }
    
    private func initAvatarObserver(){
        var ownerId = room!.id
        if room!.type == .chat {
            ownerId = room!.chatRoom!.peer!.id
        }
        
        self.avatarObserver = IGAvatar.getAvatarsLocalList(ownerId: ownerId).observe({ [weak self] (ObjectChange) in
            if self != nil {
                self!.myNavigationItem?.setRoomAvatar(self!.room!)
                self!.setRightNavViewAction()
            }
        })
    }
    
    private func initRoomAccessObserver(){
        if room!.type == .group || room!.type == .channel {
            self.roomAccess = IGRealmRoomAccess.getRoomAccess(roomId: self.room!.id, userId: IGAppManager.sharedManager.userID()!)
            self.roomAccessObserver = self.roomAccess?.observe { [weak self] (ObjectChange) in
                self?.detectWriteMessagePermission()
            }
        }
    }
    
    private func manageDraft(){
        if let draft = self.room!.draft, !draft.message.isEmpty {
            messageTextView.text = draft.message
            self.btnStickerWidthConstraint.constant = 0.0
            initChangeLanguegeNewChatView()
            lblPlaceHolder.isHidden = true
            setSendAndRecordButtonStates()
        }
    }
    
    private func stopButtonPlayForRow() {
        self.tableViewNode.reloadData()
    }
    
    private func eventBusInitialiser() {
        SwiftEventBus.onMainThread(self, name: "initTheme") { [weak self] result in
            self?.initTheme()
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusManager.stopLastButtonState) { [weak self] result in
            self?.stopButtonPlayForRow()
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusManager.sendForwardReq) { [weak self] result in
            self?.sendMultiForwardRequest()
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusManager.hideTopMusicPlayer) { [weak self] result in
            self?.hideMusicTopPlayerWithAnimation()
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusManager.showTopMusicPlayer) { [weak self] result in
            self?.musicFile = (result?.object as! MusicFile)
            IGGlobal.topBarSongTime = self?.musicFile.songTime ?? 0
            IGGlobal.topBarSongName = self?.musicFile.songName ?? ""
            IGGlobal.topBarSongSinger = self?.musicFile.singerName ?? ""
            self?.showMusicTopPlayerWithAnimation()
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusManager.updateLabelsData) { [weak self] result in
            self?.updateLabelsData(singerName: IGGlobal.topBarSongSinger,songName: IGGlobal.topBarSongName)
        }
        
        SwiftEventBus.onMainThread(self, name: EventBusManager.disableMultiSelect) { [weak self] (result) in
            self?.diselect()
        }
        
        SwiftEventBus.onMainThread(self, name: "\(self.room!.id)") { [weak self] (result) in
            
            /** Bot Actions */
            if let botAction = result?.object as? (actionType: Int, structAdditional: IGStructAdditionalButton) {
                self?.onBotClick()
                switch botAction.actionType {
                case IGPDiscoveryField.IGPButtonActionType.botAction.rawValue:
                    self?.onAdditionalSendMessage(structAdditional: botAction.structAdditional)
                    break
                case IGPDiscoveryField.IGPButtonActionType.webViewLink.rawValue:
                    self?.onAdditionalLinkClick(structAdditional: botAction.structAdditional)
                    break
                case IGPDiscoveryField.IGPButtonActionType.requestPhone.rawValue:
                    self?.onAdditionalRequestPhone(structAdditional: botAction.structAdditional)
                    break
                case IGPDiscoveryField.IGPButtonActionType.requestLocation.rawValue:
                    self?.onAdditionalRequestLocation(structAdditional: botAction.structAdditional)
                    break
                    
                default:
                    break
                }
                
            /** Sticker Actions */
            } else if let stickerItem = result?.object as? IGRealmStickerItem {
                if let attachment = IGAttachmentManager.sharedManager.getFileInfo(token: stickerItem.token!) {
                    let message = IGRoomMessage(body: stickerItem.name!)
                    message.type = .sticker
                    message.roomId = self?.room?.id ?? 0
                    message.attachment = attachment
                    message.additional = IGRealmAdditional(additionalData: IGHelperJson.convertRealmToJson(stickerItem: stickerItem)!, additionalType: AdditionalType.STICKER.rawValue)
                    
                    self?.manageSendMessage(message: message, addForwardOrReply: true, isSticker: true)
                    
                    self?.sendMessageState(enable: false)
                    self?.messageTextView.text = ""
                    self?.currentAttachment = nil
                    IGMessageViewController.selectedMessageToForwardToThisRoom = nil
                    self?.selectedMessageToReply = nil
                    self?.setInputBarHeight()
                } else {
                    IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerItem.token!, completion: { (attachment) -> Void in })
                }
            }
        }
        
        /******************** Chat Message Actions ********************/
        SwiftEventBus.onMainThread(self, name: "\(IGGlobal.eventBusChatKey)\(self.room!.id)") { [weak self] (result) in
            
            if let onMessageRecieveInChatPage = result?.object as? (action: ChatMessageAction, roomId: Int64, message: IGPRoomMessage, roomType: IGPRoom.IGPType), onMessageRecieveInChatPage.action == ChatMessageAction.receive {
                // if message is for another room shouldn't be add to current room
                if self?.currentRoomId != onMessageRecieveInChatPage.roomId {return}
                
                /**
                 * set "firstLoadDown" to false value for avoid from scroll to top after receive/send message
                 * from current callback when not loaded before any message from get history callback
                 * Hint-TODO : do better action if is possible instead set false after each message
                 */
                self?.messageLoader.setFirstLoadDown(firstLoadDown : false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let message = IGRoomMessage.getMessageWithId(messageId: onMessageRecieveInChatPage.message.igpMessageID) {
                        self?.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
                    }
                }
                self!.newMessageArrivedCount += 1
                                
                self!.lblUnreadArrieved.text = String(self!.newMessageArrivedCount)
                                
                if self!.newMessageArrivedCount > 0 {
                    self!.lblUnreadArrieved.isHidden = false
                } else {
                    self!.lblUnreadArrieved.isHidden = true
                }
                
            } else if let onMessageUpdate = result?.object as? (action: ChatMessageAction, roomId: Int64, message: IGPRoomMessage, identity: IGRoomMessage), onMessageUpdate.action == ChatMessageAction.update {
                //DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                if self?.room?.detach() == nil || self?.room?.detach().isInvalidated ?? true || self?.room!.id != onMessageUpdate.roomId || onMessageUpdate.identity.isInvalidated {
                    return
                }
                if let roomMessage = self?.messages {
                    var indexOfMessage = 0
                    if let index = roomMessage.firstIndex(of: onMessageUpdate.identity) {
                        indexOfMessage = index
                    }
                    self?.updateMessageArray(cellPosition: indexOfMessage, message: IGRoomMessage(igpMessage: onMessageUpdate.message, roomId: onMessageUpdate.roomId).detach())
                    self?.updateItem(cellPosition: indexOfMessage)
                    print("=-=-=-=- MESSAGE UPDATE GOT CLLLED")
                }
                
                
            } else if let onMessageUpdateStatus = result?.object as? (action: ChatMessageAction, messageId: Int64), onMessageUpdateStatus.action == ChatMessageAction.updateStatus {
                if self?.room == nil || self?.room?.isInvalidated ?? false {
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard let messages = IGMessageViewController.messageIdsStatic[self?.room?.id ?? -1] else {
                        return
                    }
                    if let indexOfMessage = messages.firstIndex(of: onMessageUpdateStatus.messageId) {
                        if let message = IGRoomMessage.getMessageWithId(messageId: onMessageUpdateStatus.messageId) {
                            let indexItem = (self?.middleIndex.item)! - 1
                            self?.middleIndex.item = indexItem
                                self?.updateMessageArray(cellPosition: indexOfMessage, message: message.detach())
                            self?.updateMessageStatus(cellPosition: indexOfMessage, status: message.status)
                            print("=-=-=-=- MESSAGE UPDATE STATUS GOT CLLLED")

                        }
                    }
                }
                
                
            } else if let onChannelGetMessageState = result?.object as? (action: ChatMessageAction, roomId: Int64), onChannelGetMessageState.action == ChatMessageAction.channelGetMessageState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self?.room?.id == onChannelGetMessageState.roomId {
                        
                        let allIndexes = IGGlobal.getAllIndexPathsInSection(section : 0,tblList: self!.tableViewNode)
                        
                        for nodeIndex in allIndexes {
                            if let node = self!.tableViewNode.nodeForRow(at: nodeIndex) as? ChatControllerNode {
                                if let msg = self!.messages?[nodeIndex.row] {
                                    
                                    
                                    
                                    let realm = try! Realm()
                                    
                                    let predicate = NSPredicate(format: "id = %lld", msg.id)
                                    if let updatedMsg = realm.objects(IGRoomMessage.self).filter(predicate).first {
                                        node.updateVoteActions(channelExtra: updatedMsg.channelExtra)
                                    }
                                }
                            }
                        }

                    }
                }
                
                
            } else if let onLocalMessageUpdateStatus = result?.object as? (action: ChatMessageAction, localMessage: IGRoomMessage), onLocalMessageUpdateStatus.action == ChatMessageAction.locallyUpdateStatus {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if self?.room == nil || self?.room?.isInvalidated ?? false || IGMessageViewController.messageIdsStatic[self?.room?.id ?? -1] == nil || onLocalMessageUpdateStatus.localMessage.detach().isInvalidated {
                        return
                    }
                    
                    if let roomMessage = self?.messages, let indexOfMessage = roomMessage.firstIndex(of: onLocalMessageUpdateStatus.localMessage.detach()) {
                        if let newMessage = IGRoomMessage.getMessageWithPrimaryKeyId(primaryKeyId: onLocalMessageUpdateStatus.localMessage.primaryKeyId!) {
                            self?.updateMessageArray(cellPosition: indexOfMessage, message: newMessage.detach())
                            self?.updateItem(cellPosition: indexOfMessage)
                            print("=-=-=-=- LOCAL MESSAGE UPDATE GOT CLLLED")

                            if newMessage.status == IGRoomMessageStatus.sending {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    let message = IGRoomMessage.makeCopyOfMessage(message: newMessage.detach())
                                    if message.type == .sticker {
                                        IGMessageSender.defaultSender.sendSticker(message: newMessage.detach(), to: (self?.room!.detach())!)
                                    } else {
                                        IGMessageSender.defaultSender.send(message: newMessage.detach(), to: (self?.room!.detach())!)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            } else if let onMessageEdit = result?.object as? (action: ChatMessageAction, messageId: Int64, roomId: Int64, message: String, messageType: IGPRoomMessageType, messageVersion: Int64), onMessageEdit.action == ChatMessageAction.edit {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    /* this messageId updated so after get this message from realm it has latest update */
                    if let newMessage = IGRoomMessage.getMessageWithId(messageId: onMessageEdit.messageId) {
                        if let position = IGMessageViewController.messageIdsStatic[self?.room?.id ?? -1]?.firstIndex(of: onMessageEdit.messageId) {
                            self?.updateMessageArray(cellPosition: position, message: newMessage.detach())
                            self?.updateItem(cellPosition: position)
                            print("=-=-=-=- MESSAGE TEXT GOT EDITED")

                        }
                    }
                }
                
                
            } else if let onMessageDelete = result?.object as? (action: ChatMessageAction, roomId: Int64, messageId: Int64), onMessageDelete.action == ChatMessageAction.delete {
                //DispatchQueue.main.async {
                self?.removeItem(cellPosition: IGMessageViewController.messageIdsStatic[onMessageDelete.roomId]?.firstIndex(of: onMessageDelete.messageId))
                                
                
            } else if let onFetchUserInfo = result?.object as? (action: ChatMessageAction, userId: Int64), onFetchUserInfo.action == ChatMessageAction.userInfo {
                /* fetch user info and notify collection item if exist in visible items into the collection */
//                IGUserInfoRequest.sendRequestAvoidDuplicate(userId: onFetchUserInfo.userId) { [weak self] (userInfo) in
//                    DispatchQueue.main.async {
//                        if let visibleItems = self?.tableViewNode.indexPathsForVisibleRows() {
//                            for indexPath in visibleItems {
//                                if let cell = self?.tableViewNode.nodeForRow(at: indexPath) as? ChatControllerNode {
//                                    if let msg = cell.message {
//                                        if !msg.isInvalidated, let authorUser = msg.authorUser, !authorUser.isInvalidated {
//                                            if let peerId = msg.authorUser?.userId, userInfo.igpID == peerId {
//                                                cell.updateAvatar()
////                                                self?.updateItem(cellPosition: indexPath.row)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
                
                
            } else if let onAddWaitingProgress = result?.object as? (action: ChatMessageAction, roomId: Int64, message: IGRoomMessage, direction: IGPClientGetRoomHistory.IGPDirection), onAddWaitingProgress.action == ChatMessageAction.addProgress {
                if onAddWaitingProgress.roomId == self?.room?.id ?? -1 {
                    self?.appendMessageArray([onAddWaitingProgress.message], onAddWaitingProgress.direction)
                    self?.addWaitingProgress(direction: onAddWaitingProgress.direction)
                }
                
                
            } else if let onRemoveWaitingProgress = result?.object as? (action: ChatMessageAction, fakeMessageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection), onRemoveWaitingProgress.action == ChatMessageAction.removeProgress {
                self?.removeProgress(fakeMessageId: onRemoveWaitingProgress.fakeMessageId, direction: onRemoveWaitingProgress.direction)
            }
        }
    }

    @objc func updateLabelsData(singerName: String!,songName: String!) {
        if IGGlobal.shouldShowTopBarPlayer {
            let value : CGFloat = 0
            let defaultValue: CGFloat = 60
            
            self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)

            self.createTopMusicPlayer()
        }
    }
    
    private func hideMusicTopPlayerWithAnimation() {
        IGGlobal.shouldShowTopBarPlayer = false
        holderMusicPlayer.isHidden = true
        IGNodePlayer.shared.stopMedia()
        let value : CGFloat = 0
        let defaultValue: CGFloat = 20
        self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showMusicTopPlayerWithAnimation() {
        IGGlobal.shouldShowTopBarPlayer = true
        holderMusicPlayer.isHidden = false
        let value : CGFloat = 0
        let defaultValue: CGFloat = 60

        self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)

        UIView.animate(withDuration: 0.0) {
            self.view.layoutIfNeeded()
        }
        self.createTopMusicPlayer()
    }
    
    private func createTopMusicPlayer() {
        if IGGlobal.topBarSongTime != 0 { // check if could be able to fetch time of song

            if IGGlobal.isAlreadyOpen == false {

                holderMusicPlayer.isHidden = false
                
                if holderMusicPlayer.subviews.count > 0 {
                    holderMusicPlayer.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                }
                addMusicPlayerToHolder() // add musicPlayer to holder
            }
        }
        if self.holderMusicPlayer.subviews.count == 0 {
            addMusicPlayerToHolder()
        } else {
            addMusicPlayerToHolder()
        }
        IGNodeHelperMusicPlayer.shared.room = self.room // pass room obj to helper music layer in order to be used in showing audio list of room at the bottom music player
    }
    private func addMusicPlayerToHolder() {
        if holderMusicPlayer.subviews.count > 0 {
            holderMusicPlayer.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        }
        
        let view = (IGNodeHelperMusicPlayer.shared.showTopMusicPlayer(view: self, songTime: IGGlobal.topBarSongTime, singerName: IGGlobal.topBarSongSinger, songName: IGGlobal.topBarSongName))
        holderMusicPlayer.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.topAnchor.constraint(equalTo: holderMusicPlayer.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: holderMusicPlayer.bottomAnchor, constant: 0).isActive = true
        view.leftAnchor.constraint(equalTo: holderMusicPlayer.leftAnchor, constant: 0).isActive = true
        view.rightAnchor.constraint(equalTo: holderMusicPlayer.rightAnchor, constant: 0).isActive = true
        IGGlobal.isAlreadyOpen = !IGGlobal.isAlreadyOpen
    }
    
    /* reason of "manageForward" bool
     * sometimes startLoadMessage call from another state so will be send forwarded message twice
     * currentlly for manage this state just should be manage forward from one state
     */
    private func startLoadMessage(fetchDown: Bool = true){
        if messageLoader == nil {
            messageLoader = IGMessageLoader.getInstance(room: self.room!)
        }

        let hasUnread = messageLoader.hasUnread()
        let hasSaveState = messageLoader.hasSavedState()
        if hasUnread || hasSaveState {
            self.tableViewNode.fadeOut(0)
        }
        if hasUnread {
            self.lblUnreadArrieved.isHidden = false
        } else {
            self.lblUnreadArrieved.isHidden = true
        }
        messageLoader.getMessages(fetchDown: fetchDown) { [weak self] (messages, direction) in
            self?.addChatItem(realmRoomMessages: messages, direction: direction, scrollToBottom: false)
            if hasUnread || hasSaveState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self?.tableViewNode.fadeIn(0.1)
                }
            }
            if self?.allowManageForward ?? false {
                self?.allowManageForward = false
                self?.manageForward(isFromCloud: self?.forwardFromCloud ?? false)
            }
        }
    }
    
    private func manageForward(index: Int = 0, isFromCloud: Bool = false){
        if self.forwardedMessageArray.count > 0 && self.forwardedMessageArray.count > index {
            let delay: Double = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                var indexOfMessage = index
                self.makeForward(room: self.room!, message: self.forwardedMessageArray[indexOfMessage], isFromCloud: isFromCloud) { [weak self] (message) in
                    DispatchQueue.main.async {
                        if let finalMessage = IGDatabaseManager.shared.realm.resolve(message), let room = self?.room {
                            IGMessageSender.defaultSender.sendSingleForward(message: finalMessage, to: room, success: { [weak self] in
                                indexOfMessage = indexOfMessage + 1
                                self?.manageForward(index: indexOfMessage, isFromCloud: isFromCloud)
                            }, error: {
                                indexOfMessage = indexOfMessage + 1
                                self?.manageForward(index: indexOfMessage, isFromCloud: isFromCloud)
                            })
                            self?.addChatItem(realmRoomMessages: [finalMessage], direction: IGPClientGetRoomHistory.IGPDirection.down)
                        }
                    }
                }
            }
        }
    }
    
    private func makeForward(room: IGRoom, message: IGRoomMessage, isFromCloud: Bool = false, completion: @escaping (_ message: ThreadSafeReference<IGRoomMessage>) -> Void) {
        IGFactory.shared.saveForwardMessage(roomId: room.id, messageId: message.id, isFromCloud: isFromCloud, completion: { (message) in
            completion(ThreadSafeReference(to: message))
        })
    }
    
    private func sendTracker(){
        if self.room?.type == .chat {
            if isBotRoom() {
                IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_BOT_VIEW)
            } else {
                IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_CHAT_VIEW)
            }
        } else if self.room?.type == .group {
            IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_GROUP_VIEW)
        } else if self.room?.type == .channel {
            IGHelperTracker.shared.sendTracker(trackerTag: IGHelperTracker.shared.TRACKER_CHANNEL_VIEW)
        }
    }
    
    @objc @available(iOS 10.0, *)
    private func openStickerView() {
        let viewController: UIViewController
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: IGStickerViewController.self)) as! IGStickerViewController
        
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        addChild(viewController)
        
        viewController.view.frame = view.bounds
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.messageTextView.inputView = viewController.view
        
        let viewCustom = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        viewCustom.backgroundColor = UIColor.dialogueBoxOutgoing()
        
        let stickerToolbar = IGStickerToolbar()
        let scrollView = stickerToolbar.toolbarMaker()//view
        self.messageTextView.inputAccessoryView = scrollView
        
        self.messageTextView.reloadInputViews()
        if !self.messageTextView.isFirstResponder {
            self.messageTextView.becomeFirstResponder()
        }
        
        viewController.view.snp.makeConstraints { (make) in
            make.left.equalTo((self.messageTextView.inputView?.snp.left)!)
            make.right.equalTo((self.messageTextView.inputView?.snp.right)!)
            make.bottom.equalTo((self.messageTextView.inputView?.snp.bottom)!)
            make.top.equalTo((self.messageTextView.inputView?.snp.top)!)
        }
        viewController.didMove(toParent: self)
        
    }
    
    @objc func tapOnStickerToolbar(sender: UIButton) {
        if #available(iOS 10.0, *) {
            switch sender.tag {
            case IGStickerToolbar.shared.STICKER_ADD:
                SwiftEventBus.postToMainThread(EventBusManager.stickerCurrentGroupId)
                IGTabBarStickerController.openStickerCategories()
                break
                
            case IGStickerToolbar.shared.STICKER_SETTING:
                disableStickerView(delay: 0.0)
                break
                
            default:
                SwiftEventBus.postToMainThread(EventBusManager.stickerToolbarClick, sender: sender.tag)
                break
            }
        }
    }
    
//    func setupNotifications() {
//        unsetNotifications()
//    }
//
//    func unsetNotifications() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        messageTextView.endEditing(true)
        IGGlobal.isKeyboardPresented = false

        if MoneyInputModalIsActive {
            if let MoneyInput = MoneyInputModal {
                self.view.addSubview(MoneyInput)
                UIView.animate(withDuration: 0.3) {
                    if MoneyInput.frame.origin.y < self.view.frame.size.height {
                        MoneyInput.frame = CGRect(x: 0, y: self.view.frame.height - MoneyInput.frame.height - 45, width: self.view.frame.width, height: MoneyInput.frame.height)
                    }
                }
            }
            
            
        }
        else if CardToCardModalIsActive {
            if let CardInput = CardToCardModal {
                self.view.addSubview(CardInput)
                UIView.animate(withDuration: 0.3) {
                    if CardInput.frame.origin.y < self.view.frame.size.height {
                        CardInput.frame = CGRect(x: 0, y: self.view.frame.height - CardInput.frame.height - 45, width: self.view.frame.width, height: CardInput.frame.height)
                    }
                }
            }
            
            
        }
        else if MultiShareModalIsActive {
            if let MultiShare = forwardModal {
                self.view.addSubview(MultiShare)
                UIView.animate(withDuration: 0.3) {
                    if MultiShare.frame.origin.y < self.view.frame.size.height {
                        let tmpY = ((self.view.frame.height) - (MultiShare.frame.height) - (200))
                        MultiShare.frame = CGRect(x: 0, y: tmpY , width: self.view.frame.width, height: MultiShare.frame.height + (200))
                    }
                }
            }
            
        }
        self.messageTextViewBottomConstraint.constant =  0
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
        
        self.view.layoutIfNeeded()
        
        disableStickerView(delay: 0.4)
        if isBotRoom() {
            self.reloadCollection()
        }
    }
    
    
    @objc func tapOnMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func getFavoriteMenu() {
        IGClientGetFavoriteMenuRequest.Generator.generate().success ({ [weak self] (responseProtoMessage) in
            if let favoriteResponse = responseProtoMessage as? IGPClientGetFavoriteMenuResponse {
                DispatchQueue.main.async {
                    let results = favoriteResponse.igpFavorites
                    if results.count == 0 {
                        return
                    }
                    
                    if self?.room?.isReadOnly ?? true {
                        self?.collectionViewTopInsetOffset = 0
                    } else {
                        self?.collectionViewTopInsetOffset = CGFloat(self?.DOCTOR_BOT_HEIGHT ?? 50)
                    }
                    
                    self?.apiStructArray = results
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        self?.doctorBotView(results: results)
                    }
                    
                    self?.setCollectionViewInset(withDuration: 0.9)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.tableViewNode.contentInset = UIEdgeInsets.init(top: 50, left: 0, bottom: 20, right: 0)
                        if self?.isScrollInEnd() ?? false {
                            self?.tableViewNode.setContentOffset(CGPoint(x: 0, y: -self!.tableViewNode.contentInset.top) , animated: true)
                        }
                    }
                }
            }
        }).error({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self?.getFavoriteMenu()
            default:
                break
            }
        }).send()
    }
    
    private func doctorBotView(results: [IGPFavorite]){
        
        doctorBotScrollView = UIScrollView()
        let child = UIView()
        
        doctorBotScrollView.showsHorizontalScrollIndicator = false
        doctorBotScrollView.backgroundColor = UIColor.clear
        doctorBotScrollView.frame = CGRect(x: 0, y: 0, width: Int(screenWidth), height: DOCTOR_BOT_HEIGHT)
        doctorBotScrollView.layer.cornerRadius = 8
        
        self.view.addSubview(doctorBotScrollView)
        doctorBotScrollView.addSubview(child)
        
        doctorBotScrollView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(7)
            make.right.equalTo(self.view.snp.right).offset(-7)
            if (room?.isReadOnly)! {
                make.bottom.equalTo(self.view.snp.bottom).offset(-5)
            } else {
                make.bottom.equalTo(mainHolder.snp.top)
            }
            make.height.equalTo(DOCTOR_BOT_HEIGHT)
        }
        
        leftSpace = DOCTOR_BUTTON_SPACE
        
        for result in results {
            makeDoctorBotButtonView(parent: doctorBotScrollView, result: result)
        }
        
        child.snp.makeConstraints { (make) in
            make.top.equalTo(doctorBotScrollView.snp.top)
            make.left.equalTo(doctorBotScrollView.snp.left)
            make.right.equalTo(doctorBotScrollView.snp.right)
            make.bottom.equalTo(doctorBotScrollView.snp.bottom)
            make.width.equalTo(leftSpace)
        }
        
        scrollToBottomBottomConstraint.constant -= CGFloat(DOCTOR_BOT_HEIGHT)
        view.layoutIfNeeded()
        
    }
    
    private func makeDoctorBotButtonView(parent: UIView, result: IGPFavorite){
        let text: String = result.igpName
        
        let textColor : UIColor = UIColor.hexStringToUIColor(hex: "#\(result.igpTextcolor)")
        let backgroundColor : UIColor = UIColor.hexStringToUIColor(hex: "#\(result.igpBgcolor)")
        let imageData = Data(base64Encoded: result.igpImage)
        var hasImage = true
        
        if result.igpImage.isEmpty {
            hasImage = false
        }
        
        let font = UIFont.igFont(ofSize: 17.0)
        let textWidth = text.width(withConstrainedHeight: CGFloat(DOCTOR_BOT_HEIGHT), font: font)
        var mainViewWith : CGFloat = 0
        
        let mainView = UIView()
        mainView.alpha = 0.0
        parent.addSubview(mainView)
        
        let btn = UIButton()
        mainView.addSubview(btn)
        
        var img : UIImageView!
        if hasImage {
            img = UIImageView()
            mainView.addSubview(img)
            
            mainViewWith = DOCTOR_IMAGE_SIZE + (3 * DOCOTR_IN_BUTTON_SPACE) + textWidth
        } else {
            mainViewWith = (2 * DOCOTR_IN_BUTTON_SPACE) + textWidth
        }
        
        /***** Main View *****/
        mainView.backgroundColor = backgroundColor
        mainView.layer.masksToBounds = false
        mainView.layer.cornerRadius = 20.0
        mainView.layer.shadowOffset = CGSize(width: -2, height: 3)
        mainView.layer.shadowRadius = 3.0
        mainView.layer.shadowOpacity = 0.3
        mainView.snp.makeConstraints { (make) in
            make.top.equalTo(parent.snp.top).offset(DOCTOR_BUTTON_VERTICAL_SPACE)
            make.bottom.equalTo(parent.snp.bottom).offset(DOCTOR_BUTTON_VERTICAL_SPACE)
            make.centerY.equalTo(parent.snp.centerY)
            make.left.equalTo(leftSpace)
            make.width.equalTo(mainViewWith)
        }
        
        
        /***** Button View *****/
        btn.addTarget(self, action: #selector(onDoctorBotClick), for: .touchUpInside)
        btn.titleLabel?.font = font
        btn.setTitle(text, for: UIControl.State.normal)
        btn.setTitleColor(textColor, for: UIControl.State.normal)
        btn.removeUnderline()
        
        btn.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.right.equalTo(mainView.snp.right).offset(-DOCOTR_IN_BUTTON_SPACE)
            make.centerY.equalTo(mainView.snp.centerY)
            if hasImage {
                make.left.equalTo(img.snp.right).offset(DOCOTR_IN_BUTTON_SPACE)
            } else {
                make.left.equalTo(mainView.snp.left).offset(DOCOTR_IN_BUTTON_SPACE)
            }
        }
        
        
        /***** Image View *****/
        if hasImage && imageData != nil {
            if let image = UIImage(data: imageData!) {
                img.image = image
            }
            
            img.snp.makeConstraints { (make) in
                make.left.equalTo(mainView.snp.left).offset(DOCOTR_IN_BUTTON_SPACE)
                make.centerY.equalTo(mainView.snp.centerY)
                make.width.equalTo(DOCTOR_IMAGE_SIZE)
                make.height.equalTo(DOCTOR_IMAGE_SIZE)
            }
        }
        
        mainView.fadeIn(1)
        
        leftSpace += DOCTOR_BUTTON_SPACE + mainViewWith
    }
    
    @objc func onDoctorBotClick(sender: UIButton!) {
        let value: String! = detectBotValue(name: sender.titleLabel?.text!)
        
        if value.starts(with: "$financial") {
            IGHelperFinancial.getInstance(viewController: self).manageFinancialServiceChoose()
        } else if value.starts(with: "@") {
            if let username = IGRoom.fetchUsername(room: room!) { // if username is for current room don't open this room again
                if username == value.dropFirst() {
                    return
                }
            }
            IGHelperChatOpener.checkUsernameAndOpenRoom(username: value)
        } else {
            messageTextView.text = value
            self.didTapOnSendButton(self.btnSend)
        }
    }
    
    func detectBotValue(name: String?) -> String? {
        if name != nil {
            for apiStruct in apiStructArray {
                if apiStruct.igpName == name {
                    return apiStruct.igpValue
                }
            }
        }
        
        return nil
    }
    
    func isBotRoom() -> Bool{
        if !(room?.isInvalidated)!, let chatRoom = room?.chatRoom {
            return (chatRoom.peer?.isBot)!
        }
        return false
    }
    
    private func makeKeyboardButton() {
        
        if btnChangeKeyboard != nil {
            return
        }
        
        btnChangeKeyboard = UIButton()
        btnChangeKeyboard.isHidden = false
        btnChangeKeyboard.addTarget(self, action: #selector(onKeyboardChangeClick), for: .touchUpInside)
        btnChangeKeyboard.titleLabel?.font = UIFont.iGapFonticon(ofSize: 18.0)
        btnChangeKeyboard.setTitleColor(UIColor.iGapColor(), for: UIControl.State.normal)
        btnChangeKeyboard.layer.masksToBounds = false
        btnChangeKeyboard.layer.cornerRadius = 5.0
        self.view.addSubview(btnChangeKeyboard)
        
        btnChangeKeyboard.snp.makeConstraints { (make) in
            make.width.equalTo(33)
            make.height.equalTo(33)
        }
        
        messageTextView.snp.makeConstraints { (make) in
            make.right.equalTo(btnChangeKeyboard.snp.left)
        }
    }
    
    private func removeKeyboardButton() {
        
        if btnChangeKeyboard == nil {
            return
        }
        
        btnChangeKeyboard.removeFromSuperview()
        btnChangeKeyboard.isHidden = true
        btnChangeKeyboard = nil
        messageTextView.snp.makeConstraints { (make) in
            make.right.equalTo(self.view.snp.left)
            make.left.equalTo(self.view.snp.right)
        }
    }
    
    private func manageKeyboard(firstEnter: Bool = false) {
        if !isBotRoom() {return}
        
        if !self.joinButton.isHidden {
            self.joinButton.isHidden = true
            self.mainHolder.isHidden = false
        }
        
        if let chatRoom = self.room?.chatRoom {
            if (chatRoom.peer?.isBot)! {
                let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id != %lld", self.room!.id, 0)
                do {
                    let realm = try Realm()
                    let latestMessage = realm.objects(IGRoomMessage.self).filter(predicate).last
                    let additionalData = getAdditional(roomMessage: latestMessage?.detach())
                    
                    if !self.messageTextView.isFirstResponder {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.reloadCollection()
                        }
                    }
                    
                    if additionalData != nil {
                        self.makeKeyboardButton()
                        isCustomKeyboard = true
                        btnChangeKeyboard.setTitle(KEYBOARD_MAIN_ICON, for: UIControl.State.normal)
                        latestKeyboardAdditionalView = IGHelperBot.shared.makeBotView(roomId: self.room!.id, additionalArrayMain: additionalData!, isKeyboard: true)
                        self.messageTextView.inputView = latestKeyboardAdditionalView
                        self.messageTextView.reloadInputViews()
                        if !self.messageTextView.isFirstResponder {
                            self.messageTextView.becomeFirstResponder()
                        }
                    } else {
                        if additionalData == nil {
                            self.removeKeyboardButton()
                        }
                        isCustomKeyboard = false
                        if btnChangeKeyboard != nil {
                            btnChangeKeyboard.setTitle(KEYBOARD_CUSTOM_ICON, for: UIControl.State.normal)
                        }
                        messageTextView.inputView = nil
                        messageTextView.reloadInputViews()
                    }
                    
                } catch _ as NSError {
                    print("RLM EXEPTION ERR HAPPENDED IN MANAGE KEYBOARD:",String(describing: self))
                }
            }
        }
    }
    
    private func getAdditional(roomMessage: IGRoomMessage?) -> [[IGStructAdditionalButton]]? {
        if roomMessage != nil && roomMessage!.authorUser?.userId != IGAppManager.sharedManager.userID(),
            let data = roomMessage?.additional?.data,
            roomMessage?.additional?.dataType == AdditionalType.UNDER_KEYBOARD_BUTTON.rawValue,
            let additionalData = IGHelperJson.parseAdditionalButton(data: data) {
            return additionalData
        }
        if roomMessage != nil && roomMessage!.authorUser?.userId != IGAppManager.sharedManager.userID(),
            let data = roomMessage?.additional?.data,
            roomMessage?.additional?.dataType == AdditionalType.CARD_TO_CARD_PAY.rawValue,
            let additionalData = IGHelperJson.parseAdditionalButton(data: data) {
            return additionalData
        }
        return nil
    }
    
    // MARK: - Bot Actions
    private func onAdditionalSendMessage(structAdditional: IGStructAdditionalButton) {
        let message = IGRoomMessage(body: structAdditional.label)
        message.type = .text
        message.additional = IGRealmAdditional(additionalData: structAdditional.json, additionalType: 3)
        manageSendMessage(message: message.detach(), addForwardOrReply: false)
    }
    
    private func onAdditionalLinkClick(structAdditional: IGStructAdditionalButton) {
        openWebView(url: structAdditional.value)
    }
    
    private func onAdditionalRequestPhone(structAdditional :IGStructAdditionalButton){
        manageRequestPhone()
    }
    
    private func onAdditionalRequestLocation(structAdditional :IGStructAdditionalButton){
        openLocation()
    }
    
    private func onBotClick(){
        self.tableViewNode.setContentOffset(CGPoint(x: 0, y: -self.tableViewNode.contentInset.top) , animated: false)
    }
    
    func onAdditionalRequestPayDirect(structAdditional :IGStructAdditionalButton){
        tmpUserID = self.room?.chatRoom?.peer?.id
        IGHelperAlert.shared.showAlert(data: structAdditional)
    }
    
    
    private func manageRequestPhone(){
        self.view.endEditing(true)
        if (self.room?.title) != nil {
            if let userId = IGAppManager.sharedManager.userID(), let userInfo = IGRegisteredUser.getUserInfo(id: userId) {
                self.messageTextView.text = String(describing: userInfo.phone)
                self.didTapOnSendButton(self.btnSend)
            }
        }
    }
    
    @objc func onKeyboardChangeClick(){
        guard let additionalView = latestKeyboardAdditionalView else {
            return
        }
        
        if !isCustomKeyboard {
            isCustomKeyboard = true
            btnChangeKeyboard.setTitle(KEYBOARD_MAIN_ICON, for: UIControl.State.normal)
            self.messageTextView.inputView = additionalView
        } else {
            isCustomKeyboard = false
            btnChangeKeyboard.setTitle(KEYBOARD_CUSTOM_ICON, for: UIControl.State.normal)
            messageTextView.inputView = nil
        }
        
        self.messageTextView.reloadInputViews()
        if !self.messageTextView.isFirstResponder {
            self.messageTextView.becomeFirstResponder()
        }
    }
    
    private func myLastMessage() -> IGRoomMessage? {
        if let authorHash = IGAppManager.sharedManager.authorHash() {
            let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND authorHash CONTAINS[cd] %@ AND id != %lld", self.room!.id, authorHash,0)
            do {
                let realm = try Realm()
                return realm.objects(IGRoomMessage.self).filter(predicate).last
                
            } catch _ as NSError {
                print("RLM EXEPTION ERR HAPPENDED IN MY LAST MESSAGE:",String(describing: self))
            }
        }
        return nil
    }
    
    private func setBackground() {
        
        if let color = IGWallpaperPreview.chatSolidColor {
            chatBackground.image = nil
            chatBackground.backgroundColor = UIColor.hexStringToUIColor(hex: color)
        } else if let wallpaper = IGWallpaperPreview.chatWallpaper {
            chatBackground.image = UIImage(data: wallpaper as Data)
        } else {
            if IGGlobal.hasBigScreen() {
                chatBackground.image = UIImage(named: "iGap-Chat-BG-H")
            } else {
                chatBackground.image = ThemeManager.currentTheme.ChatBG
            }
        }
    }
    
    private func removeButtonsUnderline(buttons: [UIButton]){
        for btn in buttons {
            btn.removeUnderline()
        }
    }
    
    func openUserProfile(){
        let profile = IGProfileUserViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
        profile.user = self.selectedUserToSeeTheirInfo
        profile.previousRoomId = self.room?.id
        profile.room = self.room
        profile.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(profile, animated: true)
    }
    
    private func getUserInfo(){
        guard !(room?.isInvalidated)!, let userId = self.room?.chatRoom?.peer?.id else {
            return
        }
        
        IGUserInfoRequest.Generator.generate(userID: userId).success({ (protoResponse) in
            if let userInfoResponse = protoResponse as? IGPUserInfoResponse {
                IGUserInfoRequest.Handler.interpret(response: userInfoResponse)
            }
        }).error({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                // call "getUserInfo" in main thread for avoid from "Realm Accessed from incorrect thread"
                DispatchQueue.main.async {
                    if self != nil {
                        self?.getUserInfo()
                    }
                }
            default:
                break
            }
        }).send()
    }
    
    
    // MARK: - view initialisers
    ///Delegates
    private func initDelegatesNewChatView() {
        messageTextView.delegate = self
    }
    ///view initialisers
    private func initViewNewChatView() {
        addLongPressGestureToMicButton()///handle long press on mic button
        
        ///rounding corner of mic and send button
        self.btnSend.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 20.0)
        self.btnMic.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 20.0)
        self.btnMicInner.roundCorners(corners: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 30.0)
        creatRedDotBlinkingView()
        initColorSetNewChatView()
        self.btnMic.isHidden = false
        self.btnMoney.isHidden = false
        
        self.btnSend.isHidden = true
        self.btnShare.isHidden = true
        self.btnTrash.isHidden = true
        self.btnForward.isHidden = true
        ///topbar on message view initialisers
        self.imgAttachmentImage.layer.cornerRadius = 6.0
        self.imgAttachmentImage.layer.masksToBounds = true
    }
    ///create red dot blinking for recording
    private func creatRedDotBlinkingView() {
        inputBarRecodingBlinkingView.layer.cornerRadius = 8.0
        inputBarRecodingBlinkingView.layer.masksToBounds = false
    }
    private func setupMessageTextHeightChnage() {
        lblPlaceHolder.isHidden = false
        showHideStickerButton(shouldShow: true)
        ///hides send button and show Mic and Money button if textview is empty
        handleShowHideMicButton(shouldShow: true)
        handleShowHideShareButton(shouldShow: false)
        handleShowHideSendButton(shouldShow: false)
        handleShowHideMoneyButton(shouldShow: true)
        self.messageTextViewHeightConstraint.constant = 50
    }
    
    private func initColorSetNewChatView() {
        self.holderMessageTextView.backgroundColor = ThemeManager.currentTheme.ModalViewBackgroundColor
        self.btnAttachmentNew.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)

                let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
                let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark") ?? "IGAPBlue"
                let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight") ?? "IGAPBlue"
                self.holderRecordView.backgroundColor = ThemeManager.currentTheme.BackGroundColor

                if currentTheme == "IGAPDay" {
                    
                    if currentColorSetLight == "IGAPBlack" {
                        self.btnSend.setTitleColor(.white, for: .normal)


                    } else {
                        self.btnSend.setTitleColor(ThemeManager.currentTheme.BackGroundColor, for: .normal)

                    }

                } else if currentTheme == "IGAPNight" {
                    
                    if currentColorSetDark == "IGAPBlack" {
                        self.btnSend.setTitleColor(.white, for: .normal)


                    } else {
                        self.btnSend.setTitleColor(ThemeManager.currentTheme.BackGroundColor, for: .normal)

                    }
                } else {
                    self.btnSend.setTitleColor(ThemeManager.currentTheme.BackGroundColor, for: .normal)
                    
        }

        self.btnSend.backgroundColor = ThemeManager.currentTheme.SliderTintColor
        self.btnMoney.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnTrash.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnAttachmentNew.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnShare.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnMic.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
        self.btnSticker.setTitleColor(ThemeManager.currentTheme.LabelGrayColor, for: .normal)
        self.lblPlaceHolder.textColor = ThemeManager.currentTheme.TextFieldPlaceHolderColor
        self.messageTextView.textColor = ThemeManager.currentTheme.LabelColor
        
    }
    ///setting fonts in here
    private func initFontsNewChatView() {
        lblCenterText.font = UIFont.igFont(ofSize: 10,weight: .light)
        lblCenterIcon.font = UIFont.iGapFonticon(ofSize: 15)
        messageTextView.font = UIFont.igFont(ofSize: 15)
        lblPlaceHolder.font = UIFont.igFont(ofSize: 13,weight: .light)
        btnMicInner.titleLabel!.font = UIFont.iGapFonticon(ofSize: 30)
        
    }
    ///setting alignments based on language of app
    private func initAlignmentsNewChatView() {
        lblPlaceHolder.textAlignment = self.TextAlignment
//        messageTextView.textAlignment = messageTextView.localizedDirection
    }
    ///setting Strings based on language of App
    private func initChangeLanguegeNewChatView() {
        lblPlaceHolder.isHidden = false
        lblPlaceHolder.text = IGStringsManager.GlobalMessage.rawValue.localized
        lblCenterText.text = IGStringsManager.SlideToCancel.rawValue.localized
        lblCenterIcon.text = ""
        self.btnCloseTopBar.titleLabel!.font = UIFont.iGapFonticon(ofSize: 25)
        self.btnCloseTopBar.setTitle("", for: .normal)
        
        self.btnCloseReplyBar.titleLabel!.font = UIFont.iGapFonticon(ofSize: 25)
        self.btnCloseReplyBar.setTitle("", for: .normal)
        self.btnClosePin.titleLabel?.font = UIFont.iGapFonticon(ofSize: 20)
        self.btnClosePin.setTitle("", for: .normal)
    }
    ///Notifications initialisers
    private func initNotificationsNewChatView() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(IGMessageViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(IGMessageViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func didTapOnCloseTopBar(_ sender: UIButton) {
        self.holderAttachmentBar.isHidden = true
        ///Handle Show hide of send button with animation and prevent animation to be played if already the button is visible
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        let window = UIApplication.shared.keyWindow!
        IGGlobal.isKeyboardPresented = true
//        if #available(iOS 11.0, *){
//            self.messageTextViewBottomConstraint.constant = keyboardHeight!
//        }
//        else {
//            self.messageTextViewBottomConstraint.constant = view.safeAreaInsets.bottom
//        }
//        UIView.animate(withDuration: 0.5){
//
//            self.view.layoutIfNeeded()
//
//        }
        
        if MoneyInputModalIsActive {
            if let MoneyInput = MoneyInputModal {
                window.addSubview(MoneyInput)
                UIView.animate(withDuration: 0.3) {
                    
                    var frame = MoneyInput.frame
                    frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                    MoneyInput.frame = frame
                    
                }
            }
        }
        else if CardToCardModalIsActive {
            if let CardInput = CardToCardModal {
                window.addSubview(CardInput)
                UIView.animate(withDuration: 0.3) {
                    var frame = CardInput.frame
                    frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                    CardInput.frame = frame
                }
            }
        } else if giftStickerModalIsActive {
            if let giftSticker = giftStickerModal {
                window.addSubview(giftSticker)
                UIView.animate(withDuration: 0.3) {
                    var frame = giftSticker.frame
                    frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                    giftSticker.frame = frame
                }
            }
        }
        else if MultiShareModalIsActive {
            if let MultiShare = forwardModal {
                window.addSubview(MultiShare)
                UIView.animate(withDuration: 0.3) {
                    
                    var frame = MultiShare.frame
                    frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height  + (200))
                    MultiShare.frame = frame
                    MultiShare.frame.size.height =  MultiShare.frame.size.height - (200)
                    
                }
            }
        }
       
        else {
            if MoneyInputModal != nil {
                self.hideMoneyInputModal()
            }
            
            if CardToCardModal != nil {
                self.hideCardToCardModal()
            }
            
            if giftStickerModal != nil {
                self.hideGiftStickerModal()
            }
            
            if giftStickerPaymentInfo != nil {
                self.hideGiftStickerCardInfoModal()
            }
            
            if giftStickerAlertView != nil {
                self.hideGiftStickerAlertModal()
            }
            
            if giftStickerInfo != nil {
                self.hideGiftStickerInfoModal()
            }
            
            if forwardModal != nil {
                self.hideMultiShareModal()
            }
        }
        self.view.layoutIfNeeded()
    }
    private func showHideStickerButton(shouldShow : Bool!) {
        if shouldShow {
            if forceHideStickerButton {
                return
            }
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                if !self.isBotRoom() {
                    self.btnSticker.isHidden = false
                    self.btnStickerWidthConstraint.constant = 25.0
                }
                
            }, completion: {
                (value: Bool) in
                self.view.layoutIfNeeded()
            })
            
        } else {
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.btnSticker.isHidden = true
                self.btnStickerWidthConstraint.constant = 0.0
                
            }, completion: {
                (value: Bool) in
                self.view.layoutIfNeeded()
            })
        }
    }
    ///Handle Show hide of trash button
    func handleShowHideTrashButton(shouldShow : Bool!) {
        
        if shouldShow {
            if !isBotRoom() {
                btnTrash.isHidden = false
            }
        } else {
            btnTrash.isHidden = true
            
        }
    }
    ///Handle Show hide of forward button
    func handleShowHideForwardButton(shouldShow : Bool!) {
        if shouldShow {
            if !isBotRoom() {
                btnForward.isHidden = false
            }
        } else {
            btnForward.isHidden = true
        }
    }

    ///Handle Show hide of Send button
    func handleShowHideSendButton(shouldShow : Bool!) {
        
        if shouldShow {
            btnSend.isHidden = false
            
            if !alreadyInSendMode {
                ///Handle Show hide of send button with animation
                btnSend.isHidden = false
                btnSend.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                    self.btnSend.transform = CGAffineTransform.identity
                    self.btnSend.layoutIfNeeded()
                }, completion: nil)
                ///Handle Show hide of send button with animation and prevent animation to be played if already the button is visible
                if !alreadyInSendMode {
                    self.alreadyInSendMode = true
                }
            }
        } else {
            btnSend.isHidden = true
        }
    }
    ///Handle Show hide of Money button
    func handleShowHideMoneyButton(shouldShow : Bool!) {
        if shouldShow {
            if room?.type == .chat && !isBotRoom() {
                btnMoney.isHidden = false
            }
        } else {
            btnMoney.isHidden = true
        }
    }
    ///Handle Show hide of Mic button
    func handleShowHideMicButton(shouldShow : Bool!) {
        if shouldShow {
            btnMic.isHidden = false
            
        } else {
            btnMic.isHidden = true
            
        }
    }
    ///Handle Show hide of share button
    func handleShowHideShareButton(shouldShow : Bool!) {
        if shouldShow {
            if !isBotRoom() {
                btnShare.isHidden = false
            }
           } else {
            btnShare.isHidden = true
        }
    }
    ///Handle single tap on Long tap on record Button to show an alert(pop alert) above message text view and inform the user to long press on record button in order to record a voice
    @IBAction func didTapOnMicButton(_ sender: UIButton) {
        sender.backgroundColor = ThemeManager.currentTheme.LabelColor
        sender.titleLabel!.textColor = UIColor.red
        
        sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        IGHelperShowToastAlertView.shared.showPopAlert(view: self, innerView: holderMessageTextView, message: IGStringsManager.LongPressToRecord.rawValue.localized, time: 2.0, type: .alert)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            sender.transform = CGAffineTransform.identity
            sender.backgroundColor = UIColor.clear
            sender.titleLabel!.textColor = UIColor.red
            sender.layoutIfNeeded()
        }, completion: { (completed) in
            sender.titleLabel!.textColor = UIColor.red
            sender.titleLabel!.textColor = ThemeManager.currentTheme.LabelColor
            
            sender.setTitleColor(ThemeManager.currentTheme.LabelColor, for: .normal)
            
        })
        
    }
    
    @objc func didLongTapOnMicButton(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
            
        case .began :
            startRecording()
            initialLongTapOnRecordButtonPosition = gesture.location(in: self.view)
            break
        case .cancelled :
            break
        case .changed :
            let point = gesture.location(in: self.view)
            let difX = (initialLongTapOnRecordButtonPosition?.x)! - point.x
            
            var newConstant:CGFloat = 0.0
            
            if difX > 10 {
                newConstant = 74 - difX
            } else {
                newConstant = 74
            }
            
            if newConstant > 0{
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                cancelRecording()
            }
            break
        case .ended :
            finishRecording()
            break
        case .possible:
            break
        case .failed:
            break
        default:
            break
        }
    }
    
    func addLongPressGestureToMicButton(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapOnMicButton(gesture:)))
        longPress.minimumPressDuration = 0.5
        self.btnMic.addGestureRecognizer(longPress)
    }
    
    // MARK: - TextView Development Delegate funcs
    
    func textViewDidChange(_ textView: UITextView) {
        
        if room!.isInvalidated {
            return
        }
        
        if allowSendTyping() {
            self.sendTyping()
            typingStatusExpiryTimer.invalidate()
            typingStatusExpiryTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                           target:   self,
                                                           selector: #selector(sendCancelTyping),
                                                           userInfo: nil,
                                                           repeats:  false)
        }
        
        if (textView.text == "" || textView.text.isEmpty) {
            alreadyInSendMode = false
            lblPlaceHolder.isHidden = false///handle send button animation
            
            if self.currentAttachment == nil {
                showHideStickerButton(shouldShow: true)
                handleShowHideMicButton(shouldShow: true)
                handleShowHideShareButton(shouldShow: false)
                handleShowHideSendButton(shouldShow: false)
                handleShowHideMoneyButton(shouldShow: true)
            }
            self.messageTextViewHeightConstraint.constant = 50
            
        } else if btnSend.isHidden {
            lblPlaceHolder.isHidden = true
            showHideStickerButton(shouldShow: false)
            handleShowHideMicButton(shouldShow: false)
            handleShowHideShareButton(shouldShow: false)
            handleShowHideSendButton(shouldShow: true)
            handleShowHideMoneyButton(shouldShow: false)
        }
        if (!(textView.text == "" || textView.text.isEmpty) && !lblPlaceHolder.isHidden) {
            lblPlaceHolder.isHidden = true
        }
        manageTextViewHeight(textView: textView)
    }
    
    private func manageTextViewHeight(textView: UITextView){
        let LINE_HEIGHT: CGFloat = 25
        var numLines = (textView.contentSize.height / textView.font!.lineHeight).rounded(.down)
        
        if beforeMessageLineCount != numLines {
            beforeMessageLineCount = numLines
            textView.scrollRangeToVisible(textView.selectedRange)
            var textViewHeigt = LINE_HEIGHT
            if numLines != 0 {
                if numLines > 8 {
                    numLines = 8
                }
                textViewHeigt = numLines * LINE_HEIGHT
            }
            self.messageTextViewHeightConstraint.constant = textViewHeigt + LINE_HEIGHT // add an extra 'LINE_HEIGHT'
            
            self.view.layoutIfNeeded()
            self.messageTextView.isScrollEnabled = false
            self.messageTextView.isScrollEnabled = true
        }
    }
    
    func diselect() {
        IGGlobal.shouldMultiSelect = false
        self.showMultiSelectUI(state: false, id: 0)
    }
    
    func close() {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.tabBarController?.tabBar.isUserInteractionEnabled = true
            self?.callCallBackApi(token: SMUserManager.payToken!)
        })
    }
    
    func callCallBackApi(token : String) {
        let url: String! = SMUserManager.callBackUrl
        guard let serviceUrl = URL(string: url) else { return }
        let parameters: Parameters = ["token" : token]
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
        }}.resume()
    }
    
    func screenView() {
        close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            SMReciept.getInstance().screenReciept(viewcontroller: self)
        }
    }
    
    private func sendUnsubscribForRoom(roomId: Int64){
        IGClientUnsubscribeFromRoomRequest.Generator.generate(roomId: roomId).success { (responseProtoMessage) in
        }.error({ [weak self] (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self?.sendUnsubscribForRoom(roomId: roomId)
            default:
                break
            }
        }).send()
    }
    
    private func saveMessagePosition() {
        if self.room!.isInvalidated {
            return
        }
        
        let visibleCells = self.tableViewNode.indexPathsForVisibleRows().sorted(by: {
//        let visibleCells = self.tableViewNode.indexPathsForVisibleRows().sorted(by:{
            $0.section < $1.section || $0.row < $1.row
        }).compactMap({
            self.tableViewNode.nodeForRow(at: $0)
        })
        
        guard let firstVisibleItem = fetchVisibleMessage(visibleCells: visibleCells, index: 0) else {
            return
        }
        guard let lastVisibleItem = fetchVisibleMessage(visibleCells: visibleCells, index: visibleCells.count-1) else {
            return
        }
        
        var saveState = true
        let numberOfItems = tableViewNode.numberOfRows(inSection: 0)
        
        if self.tableViewNode.indexPath(for: visibleCells[0])!.row > IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT {
            var finalMessage: IGRoomMessage!
            if let collectionCell = self.tableViewNode.nodeForRow(at: IndexPath(row: numberOfItems - IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT, section: 0)) as? ChatControllerNode {
                finalMessage = collectionCell.message?.detach()
            }
            if finalMessage != nil && (finalMessage.isInvalidated || finalMessage.id == firstVisibleItem.id) {// if last message is visible don't need to save message position
                saveState = false
            }
            if saveState {
                IGRoom.saveMessagePosition(roomId: self.room!.id, saveScrollMessageId: lastVisibleItem.id)
            }
        } else { // clear save message position
            IGRoom.saveMessagePosition(roomId: self.room!.id, saveScrollMessageId: 0)
        }
    }
    
    /** fetch scroll state is at the end of list or not */
    private func isScrollInEnd() -> Bool {
        
        let visibleCells = self.tableViewNode.indexPathsForVisibleRows().sorted(by:{ $0.section < $1.section || $0.row < $1.row }).compactMap({ self.tableViewNode.nodeForRow(at: $0) })
        if let indexPath = self.tableViewNode.indexPath(for: visibleCells[0]) {
            return indexPath.row == 0
        }else {
            return true
        }
//        return self.tableViewNode.indexPath(for: visibleCells[0])!.row == 0
    }
    
    /* fetch visible message from collection view according to entered index */
    private func fetchVisibleMessage(visibleCells: [ASCellNode], index: Int, repeatCount: Int = 0) -> IGRoomMessage? {
        if index < 0 || repeatCount == 3 {return nil}
        if visibleCells.count > 0 {
            if let visibleMessage = visibleCells[index] as? ChatControllerNode, let type = visibleMessage.message?.type, type != .progress, type != .unread, type != .time {
                return visibleMessage.message?.detach()
            }
        }
        return fetchVisibleMessage(visibleCells: visibleCells, index: index - 1, repeatCount: repeatCount + 1)
    }
    
    var finalRoomType: IGRoom.IGType!
    var finalRoomId: Int64!
    
    //MARK: - Send Seen Status
    private func setMessagesRead() {
        //don't need send status for channel
        if self.room?.type == .channel {return}
        
        if let roomId = self.room?.id {
            finalRoomId = roomId
            finalRoomType = self.room?.type
            DispatchQueue.global(qos: .background).async {
                IGFactory.shared.markAllMessagesAsRead(roomId: roomId)
                
                let predicate = NSPredicate(format: "roomId == %lld AND statusRaw != %d AND statusRaw != %d", self.finalRoomId, IGRoomMessageStatus.seen.rawValue, IGRoomMessageStatus.listened.rawValue)
                let sortProperties = [SortDescriptor(keyPath: "id", ascending: false)]
                let realmRoomMessages = IGDatabaseManager.shared.realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                let finalMessages = realmRoomMessages.toArray()
                IGHelperMessageStatus.shared.sendStatus(roomId: roomId, status: .seen, realmRoomMessages: finalMessages)
            }
        }
    }
    
    /* if send message state is enable show send button and hide sticker & record button */
    private func sendMessageState(enable: Bool){
        switch self.room!.type {
        case .chat:
            
            self.btnMoney.isHidden = true
            self.view.layoutIfNeeded()
            
            break
        default :
            self.btnMoney.isHidden = true
            self.view.layoutIfNeeded()
            
        }
        if enable {
            self.hideMoneyTransactionModal()
            self.hideMoneyInputModal()
            self.hideCardToCardModal()
            self.hideGiftStickerModal()
            self.hideGiftStickerAlertModal()
            self.hideGiftStickerInfoModal()
            self.hideGiftStickerCardInfoModal()
            if btnMic.isHidden {
                return
            }
            
            self.btnMic.isHidden = true
            
            switch self.room!.type {
            case .chat:
                if self.isBotRoom() {
                    self.btnMoney.isHidden = true
                }
                else {
                    self.btnMoney.isHidden = true
                }
                self.view.layoutIfNeeded()
                
                break
            default:
                self.btnMoney.isHidden = true
                self.view.layoutIfNeeded()
            }
            
            self.view.layoutIfNeeded()
            self.btnSend.isHidden = false
            self.btnMoney.isHidden = true
            
            switch self.room!.type {
            case .chat:
                self.btnMoney.isHidden = true
                self.view.layoutIfNeeded()
                
                break
            default:
                self.btnMoney.isHidden = true
                self.view.layoutIfNeeded()
            }
            
            
            
           showHideStickerButton(shouldShow: false)
            
        } else {
            self.hideMoneyTransactionModal()
            self.hideMoneyInputModal()
            self.hideCardToCardModal()
            self.hideGiftStickerModal()
            self.hideGiftStickerAlertModal()
            self.hideGiftStickerInfoModal()
            self.hideGiftStickerCardInfoModal()
            
            self.btnSend.isHidden = true
            self.btnMoney.isHidden = true
            switch self.room!.type {
            case .chat:
                self.btnMoney.isHidden = true
                self.view.layoutIfNeeded()
                
                break
            default :
                self.btnMoney.isHidden = true
                self.view.layoutIfNeeded()
            }
            self.view.layoutIfNeeded()
            
            
            self.btnMic.isHidden = false
            self.btnMoney.isHidden = false
            switch self.room!.type {
            case .chat:
                if self.isBotRoom() {
                    self.btnMoney.isHidden = true
                }
                else {
                    self.btnMoney.isHidden = false
                }
                self.view.layoutIfNeeded()
                
                break
            default :
                self.btnMoney.isHidden = true
                self.view.layoutIfNeeded()
            }
            
            self.view.layoutIfNeeded()
            
            showHideStickerButton(shouldShow: !self.isBotRoom())
        }
    }
    
    /* if sticker view is enable show keyboard button otherwise show sticker button */
    private func stickerViewState(enable: Bool) {
        
        isStickerKeyboard = enable
        //        txtSticker.font = UIFont.iGapFonticon(ofSize: 19)
        UIView.transition(with: self.btnSticker, duration: ANIMATE_TIME, options: .transitionFlipFromBottom, animations: {
            
            //            self.showHideStickerButton(shouldShow: false)
            if self.isStickerKeyboard {
                self.btnSticker.setTitle("", for: .normal)
                if #available(iOS 10.0, *) {
                    DispatchQueue.main.async {
                        self.openStickerView()
                    }
                }
            } else {
                self.btnSticker.setTitle("", for: .normal)
                if self.messageTextView.inputAccessoryView != nil {
                    UIView.transition(with: self.messageTextView.inputAccessoryView!, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                        self.messageTextView.inputAccessoryView!.isHidden = true
                        self.messageTextView.inputAccessoryView = nil
                    }, completion: nil)
                }
                self.messageTextView.inputView = nil
                self.messageTextView.reloadInputViews()
            }
            
        }, completion: { (completed) in
            
            UIView.transition(with: self.btnSticker, duration: self.ANIMATE_TIME, options: .transitionFlipFromTop, animations: {
                //                self.showHideStickerButton(shouldShow: true)
            }, completion: nil)
        })
    }
    /// this manager is responsible for managing top bottom  offset of  collection ( becoz the collection is fliped verticall ( top is bottom and bottom is Top :D )
    ///default mode is .none which means nore pin view and top player for music are not visible
    ///case withPin means only the pin view is visible
    //case withBoth means both Pin View and topMusic player are visible to the user
    //case withTopPlayer means only topMusic player is visible to the user
    ///the top offset is managed based on height of pin and topPlayer

    private func collectionViewOffsetManager(mode : messageMainTopViewState!) {
        let value : CGFloat = 0
        var defaultValue : CGFloat = 20
        switch mode {
        case .withBoth :
            defaultValue = 112
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        case .withTopPlayer :
            defaultValue = 60
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        case .withPin :
            defaultValue = 70
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        case .none :
            defaultValue = 20
            UIView.animate(withDuration: 0.3, animations: {
                self.tableViewNode.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        default:
            break
        }
    }
    
    /* open sticker view in chat and go to saved position */
    private func manageStickerPosition() {
        if #available(iOS 10.0, *) {
            if IGGlobal.stickerCurrentGroupId != nil {
                self.stickerViewState(enable: true)
            }
        }
    }
    
    private func disableStickerView(delay: Double, openKeyboard: Bool = false){
        isStickerKeyboard = false
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            self.btnSticker.setTitle("", for: .normal)
            self.messageTextView.inputAccessoryView = nil
            self.messageTextView.inputView = nil
            self.messageTextView.reloadInputViews()
            if openKeyboard && !self.messageTextView.isFirstResponder {
                self.messageTextView.becomeFirstResponder()
            }
        }
    }
    
    /***** user send location callback *****/
    func userWasSelectedLocation(location: CLLocation) {
        
        let message = IGRoomMessage(body: "")
        let locationMessage = IGRoomMessageLocation(location: location, for: message)
        message.location = locationMessage.detach()
        message.roomId = self.room!.id
        message.type = .location
        
        self.manageSendMessage(message: message.detach())
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sendMessageState(enable: false)
            self.messageTextView.text = ""
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = nil
            self.currentAttachment = nil
            self.setInputBarHeight()
        }
    }
    
    private func keepScrollPosition(didMessagesAddedToBottom: Bool, initialContentOffset: CGPoint, initialContentSize: CGSize, animated: Bool) {
        if didMessagesAddedToBottom {
            self.tableViewNode.contentOffset = initialContentOffset
        } else {
            let contentOffsetY = self.tableViewNode.view.contentSize.height - (initialContentSize.height - initialContentOffset.y)
            // + self.collectionView.contentOffset.y - initialContentSize.height
            self.tableViewNode.contentOffset = CGPoint(x: self.tableViewNode.contentOffset.x, y: contentOffsetY)
        }
    }
    
    
    //MARK: -
    private func notification(register: Bool) {
        let center = NotificationCenter.default
        if register {
            center.addObserver(self,
                               selector: #selector(didReceiveKeyboardWillChangeFrameNotification(_:)),
                               name: UIResponder.keyboardWillHideNotification,
                               object: nil)
            center.addObserver(self,
                               selector: #selector(didReceiveKeyboardWillChangeFrameNotification(_:)),
                               name: UIResponder.keyboardWillChangeFrameNotification,
                               object: nil)
            
            center.addObserver(self,
                               selector: #selector(dodd),
                               name: UIMenuController.willShowMenuNotification,
                               object: nil)
            center.addObserver(self,
                               selector: #selector(dodd),
                               name: UIMenuController.willHideMenuNotification,
                               object: nil)
            center.addObserver(self,
                               selector: #selector(dodd),
                               name: UIContentSizeCategory.didChangeNotification,
                               object: nil)
        } else {
            center.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            center.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            center.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
            center.removeObserver(self, name: UIMenuController.willHideMenuNotification, object: nil)
            center.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
        }
    }
    
    @objc func dodd() {
        
    }
    
    @objc func didReceiveKeyboardWillChangeFrameNotification(_ notification:Notification) {
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        let window = UIApplication.shared.keyWindow!
        let userInfo = (notification.userInfo)!
        if let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
            let animationCurveOption = (animationCurve << 16)
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let keyboardBeginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
            
            var bottomConstraint: CGFloat
            if keyboardEndFrame.origin.y == keyboardBeginFrame.origin.y {
                return
            } else if notification.name == UIResponder.keyboardWillHideNotification  {
                //hidding keyboard
                bottomConstraint = 0.0
                if MoneyInputModalIsActive {
                    if let MoneyInput = MoneyInputModal {
                        self.view.addSubview(MoneyInput)
                        UIView.animate(withDuration: 0.3) {
                            if MoneyInput.frame.origin.y < self.view.frame.size.height {
                                MoneyInput.frame = CGRect(x: 0, y: self.view.frame.height - MoneyInput.frame.height - 45, width: self.view.frame.width, height: MoneyInput.frame.height)
                            }
                        }
                    }
                } else if CardToCardModalIsActive {
                    if let CardInput = CardToCardModal {
                        self.view.addSubview(CardInput)
                        UIView.animate(withDuration: 0.3) {
                            if CardInput.frame.origin.y < self.view.frame.size.height {
                                CardInput.frame = CGRect(x: 0, y: self.view.frame.height - CardInput.frame.height - 45, width: self.view.frame.width, height: CardInput.frame.height)
                            }
                        }
                    }
                } else if MoneyTransactionModalIsActive {
                    if let moneyTransactionModal = MoneyTransactionModal {
                        self.view.addSubview(moneyTransactionModal)
                        UIView.animate(withDuration: 0.3) {
                            if moneyTransactionModal.frame.origin.y < self.view.frame.size.height {
                                moneyTransactionModal.frame = CGRect(x: 0, y: self.view.frame.height - moneyTransactionModal.frame.height - 45, width: self.view.frame.width, height: moneyTransactionModal.frame.height)
                            }
                        }
                    }
                }
                self.messageTextViewBottomConstraint.constant =  0
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
                
            } else {
                //showing keyboard
                if UIDevice.current.hasNotch {
                    bottomConstraint = keyboardEndFrame.size.height - 34
                } else {
                    bottomConstraint = keyboardEndFrame.size.height
                }
                if MoneyInputModalIsActive {
                    if let MoneyInput = MoneyInputModal {
                        window.addSubview(MoneyInput)
                        UIView.animate(withDuration: 0.3) {
                            
                            var frame = MoneyInput.frame
                            frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                            MoneyInput.frame = frame
                            
                        }
                    }
                }
                else if CardToCardModalIsActive {
                        if let CardInput = CardToCardModal {
                            window.addSubview(CardInput)
                            UIView.animate(withDuration: 0.3) {
                                
                                var frame = CardInput.frame
                                frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                                CardInput.frame = frame
                                
                            }
                        }
                }
                else if MoneyTransactionModalIsActive {
                        if let moneyTransactionModal = MoneyTransactionModal {
                            window.addSubview(moneyTransactionModal)
                            UIView.animate(withDuration: 0.3) {
                                
                                var frame = moneyTransactionModal.frame
                                frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                                moneyTransactionModal.frame = frame
                                
                            }
                        }
                } else if giftStickerModalIsActive {
                    if let giftStickerModal = self.giftStickerModal {
                        window.addSubview(giftStickerModal)
                        UIView.animate(withDuration: 0.3) {
                            var frame = giftStickerModal.frame
                            frame.origin = CGPoint(x: frame.origin.x, y: window.frame.size.height - keyboardHeight! - frame.size.height)
                            giftStickerModal.frame = frame
                        }
                    }
                }else {
                    if MoneyInputModal != nil {
                        self.hideMoneyInputModal()
                    }
                    if CardToCardModal != nil {
                        self.hideCardToCardModal()
                    }
                    if forwardModal != nil {
                        self.hideMultiShareModal()
                    }
                    if MoneyTransactionModal != nil {
                        self.hideMoneyTransactionModal()
                    }
                    
                    if giftStickerModal != nil {
                        self.hideGiftStickerModal()
                    }

                    if giftStickerPaymentInfo != nil {
                        self.hideGiftStickerCardInfoModal()
                    }
                    
                    if giftStickerAlertView != nil {
                        self.hideGiftStickerAlertModal()
                    }
                    
                    if giftStickerInfo != nil {
                        self.hideGiftStickerInfoModal()
                    }
                }
                self.view.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(animationCurveOption)), animations: {
                self.messageTextViewBottomConstraint.constant = bottomConstraint
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
    }
    
    func setCollectionViewInset(withDuration: TimeInterval = 0.2) {
        let value : CGFloat = 0
        manageCollectionViewBottom(value: value)
    }
    private func manageCollectionViewBottom(withDuration: TimeInterval = 0.2,value: CGFloat? = 0) {
        UIView.animate(withDuration: withDuration, animations: {
            if self.isBotRoom() {
                self.tableViewNode.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
            } else {
                if self.room?.type == .chat {
                    self.tableViewNode.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
                } else if self.room?.type == .group {
                    self.tableViewNode.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
                } else {
                    if self.room?.channelRoom?.role == .admin || self.room?.channelRoom?.role == .owner || self.room?.channelRoom?.role == .moderator {
                        self.tableViewNode.contentInset = UIEdgeInsets.init(top: value!, left: 0, bottom: 20, right: 0)
                    } else {
                        self.tableViewNode.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
                    }
                }
           }
        }, completion: { (completed) in
            
        })
    }
    
    func updateConnectionStatus(_ status: IGAppManager.ConnectionStatus) {
        
        switch status {
        case .connected:
            connectionStatus = .connected
            break
        case .connecting:
            connectionStatus = .connecting
            break
        case .waitingForNetwork:
            connectionStatus = .waitingForNetwork
            break
        case .iGap:
            connectionStatus = .iGap
            break
        }
    }
    
    func groupPin(messageId: Int64 = 0){
        
        var message = IGStringsManager.SureToUnpin.rawValue.localized
        var title = IGStringsManager.UnpinForAll.rawValue.localized
        let titleMe = IGStringsManager.UnpinForMe.rawValue.localized
        if messageId != 0 {
            message = IGStringsManager.SureToPin.rawValue.localized
            title = IGStringsManager.Pin.rawValue.localized
        }
        
        let alertC = UIAlertController(title: nil, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        let unpin = UIAlertAction(title: title, style: .default, handler: { (action) in
            IGGroupPinMessageRequest.Generator.generate(roomId: (self.room?.id)!, messageId: messageId).success({ [weak self] (protoResponse) in
                DispatchQueue.main.async {
                    if let groupPinMessage = protoResponse as? IGPGroupPinMessageResponse {
                        if groupPinMessage.hasIgpPinnedMessage {
                            self?.txtPinnedMessage.text = IGRoomMessage.detectPinMessageProto(message: groupPinMessage.igpPinnedMessage)
                            self?.stackTopViews.isHidden = false
                        } else {
                            self?.stackTopViews.isHidden = true
                        }
                        IGGroupPinMessageRequest.Handler.interpret(response: groupPinMessage)
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                
            }).send()
        })
        
        let unpinJustForMe = UIAlertAction(title: titleMe, style: .default, handler: { (action) in
//            self.pinnedMessageView.isHidden = true
            self.stackTopViews.isHidden = true
            IGFactory.shared.roomPinMessage(roomId: (self.room?.id)!)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertC.addAction(unpin)
        if messageId == 0 {
            alertC.addAction(unpinJustForMe)
        }
        alertC.addAction(cancel)
        self.present(alertC, animated: true, completion: nil)
    }
    
    func channelPin(messageId: Int64 = 0){
        
        var message = IGStringsManager.SureToUnpin.rawValue.localized
        var title = IGStringsManager.UnpinForAll.rawValue.localized
        let titleMe = IGStringsManager.UnpinForMe.rawValue.localized
        if messageId != 0 {
            message = IGStringsManager.SureToPin.rawValue.localized
            title = IGStringsManager.Pin.rawValue.localized
        }
        
        let alertC = UIAlertController(title: nil, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        let unpin = UIAlertAction(title: title, style: .default, handler: { (action) in
            IGChannelPinMessageRequest.Generator.generate(roomId: (self.room?.id)!, messageId: messageId).success({ [weak self] (protoResponse) in
                DispatchQueue.main.async {
                    if let channelPinMessage = protoResponse as? IGPChannelPinMessageResponse {
                        if channelPinMessage.hasIgpPinnedMessage {
                            self?.txtPinnedMessage.text = IGRoomMessage.detectPinMessageProto(message: channelPinMessage.igpPinnedMessage)
                            self?.stackTopViews.isHidden = false
                        } else {
                            self?.stackTopViews.isHidden = true
                        }
                        IGChannelPinMessageRequest.Handler.interpret(response: channelPinMessage)
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    break
                default:
                    break
                }
                
            }).send()
        })
        
        let unpinJustForMe = UIAlertAction(title: titleMe, style: .default, handler: { (action) in
            self.stackTopViews.isHidden = true
            IGFactory.shared.roomPinMessage(roomId: (self.room?.id)!)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertC.addAction(unpin)
        if messageId == 0 {
            alertC.addAction(unpinJustForMe)
        }
        alertC.addAction(cancel)
        self.present(alertC, animated: true, completion: nil)
    }
    
    func groupPinGranted() -> Bool{
        if room?.type == .group && (self.roomAccess?.pinMessage ?? false) {
            return true
        }
        return false
    }
    
    func channelPinGranted() -> Bool{
        if room?.type == .channel && (self.roomAccess?.pinMessage ?? false) {
            return true
        }
        return false
    }
    
    /************************** Alert Action Permissions **************************/
    func allowCopy(_ message: IGRoomMessage) -> Bool{
        var finalMessage = message
        if let forward = message.forwardedFrom {
            finalMessage = forward
        }
        if (finalMessage.type == .text) ||
            finalMessage.type == .gifAndText ||
            finalMessage.type == .fileAndText ||
            finalMessage.type == .audioAndText ||
            finalMessage.type == .videoAndText ||
            finalMessage.type == .imageAndText {
            return true
        }
        return false
    }
    
    func allowPin() -> Bool{
        return groupPinGranted() || channelPinGranted()
    }
    
    func allowReply() -> Bool{
        if !(room!.isReadOnly){
            return true
        }
        return false
    }
    
    func allowForward(_ message: IGRoomMessage) -> Bool{
        if let additionalType = message.additional?.dataType, additionalType == AdditionalType.GIFT_STICKER.rawValue {
            return false
        }
        if room?.type == .channel {
            return false
        }
        return true
    }
    
    func allowEdit(_ message: IGRoomMessage) -> Bool {
        if message.forwardedFrom == nil &&
            message.type != .sticker &&
            message.type != .contact &&
            message.type != .location &&
            ((self.room?.type == .chat && message.authorHash == currentLoggedInUserAuthorHash) || (self.room!.type == .channel && self.roomAccess?.editMessage ?? false) || (self.room!.type == .group && message.authorHash == currentLoggedInUserAuthorHash)) {
            return true
        }
        return false
    }
    
    func allowDelete(_ message: IGRoomMessage) -> (singleDelete: Bool, bothDelete: Bool){
        var singleDelete = false
        var bothDelete = false
        
        if ((message.authorHash == currentLoggedInUserAuthorHash) || (self.room!.type == .chat) || ((self.room!.type == .channel) && (self.roomAccess?.deleteMessage ?? false)) || ((self.room!.type == .group) && (message.authorHash == currentLoggedInUserAuthorHash || self.roomAccess?.deleteMessage ?? false)) ) {
            
            if (self.room!.type == .chat && !(self.room?.isCloud() ?? false)) && (message.authorHash == currentLoggedInUserAuthorHash) && (message.creationTime != nil) && (Date().timeIntervalSince1970 - message.creationTime!.timeIntervalSince1970 < 2 * 3600) {
                bothDelete = true
            }
            
            singleDelete = true
        }
        return (singleDelete,bothDelete)
    }
    
    func allowShare(_ cellMessage: IGRoomMessage) -> Bool {
        
        var message = cellMessage
        if let forward = cellMessage.forwardedFrom {
            message = forward
        }
        
        if (message.type == .file || message.type == .fileAndText ||
            message.type == .image || message.type == .imageAndText ||
            message.type == .video || message.type == .videoAndText ||
            message.type == .gif) && IGGlobal.isFileExist(path: message.attachment!.localPath, fileSize: message.attachment!.size) {
            return true
        }
        return false
    }
    
    @objc func didTapOnInputTextView() {
        disableStickerView(delay: 0.0, openKeyboard: true)
    }
    
    @objc func didTapOnDissmissView() {
        if forwardModal != nil {
            
            hideMultiShareModal()
            self.view.endEditing(true)
        }
    }
    
    @IBAction func didTapOnPickSticker(_ sender: UIButton) {
        if self.isStickerKeyboard {
            self.isStickerKeyboard = false
        } else {
            self.isStickerKeyboard = true
        }
        
        self.stickerViewState(enable: self.isStickerKeyboard)
        
    }
    
    @IBAction func didTapOnPinClose(_ sender: UIButton) {
        if groupPinGranted() {
            self.groupPin()
            return
        } else if channelPinGranted() {
            self.channelPin()
            return
        } else {
            self.stackTopViews.isHidden = true
            IGFactory.shared.roomPinMessage(roomId: (self.room?.id)!)
        }
    }
    
    @IBAction func didTapOnPinView(_ sender: UIButton) {
        if let pinMessage = room?.pinMessage {
            goToPosition(messageId: pinMessage.id)
        }
    }
    
    //MARK: IBActions
    @IBAction func didTapOnSendButton(_ sender: UIButton) {
        
        if IGGlobal.isFromSearchPage {
            IGGlobal.hasTexted = true
        }
        if currentAttachment == nil && messageTextView.text == "" && IGMessageViewController.selectedMessageToForwardToThisRoom == nil && !isCardToCardRequestEnable {
            return
        }
        
        messageTextView.text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedMessageToEdit != nil {
            switch room!.type {
            case .chat:
                IGChatEditMessageRequest.Generator.generate(message: selectedMessageToEdit!, newText: messageTextView.text,  room: room!).success({ (protoResponse) in
                    IGChatEditMessageRequest.Handler.interpret(response: protoResponse)
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            case .group:
                IGGroupEditMessageRequest.Generator.generate(message: selectedMessageToEdit!, newText: messageTextView.text, room: room!).success({ (protoResponse) in
                    switch protoResponse {
                    case let response as IGPGroupEditMessageResponse:
                        IGGroupEditMessageRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            case .channel:
                IGChannelEditMessageRequest.Generator.generate(message: selectedMessageToEdit!, newText: messageTextView.text, room: room!).success({ (protoResponse) in
                    switch protoResponse {
                    case let response as IGPChannelEditMessageResponse:
                        IGChannelEditMessageRequest.Handler.interpret(response: response)
                    default:
                        break
                    }
                }).error({ (errorCode, waitTime) in
                    
                }).send()
            }
            
            selectedMessageToEdit = nil
            self.messageTextView.text = ""
            self.setInputBarHeight()
            self.setupMessageTextHeightChnage()
            self.sendCancelTyping()
            return
        }
        
        if currentAttachment != nil {
            ///play send sound
            
            let messageText = messageTextView.text.substring(offset: MAX_TEXT_ATTACHMENT_LENGHT)
            
            let message = IGRoomMessage(body: messageText)
            currentAttachment?.status = .uploading
            message.attachment = currentAttachment?.detach()
            IGAttachmentManager.sharedManager.add(attachment: currentAttachment!)
            switch currentAttachment!.type {
            case .image:
                if messageText == "" {
                    message.type = .image
                } else {
                    message.type = .imageAndText
                }
            case .video:
                if messageText == "" {
                    message.type = .video
                } else {
                    message.type = .videoAndText
                }
            case .audio:
                if messageText == "" {
                    message.type = .audio
                } else {
                    message.type = .audioAndText
                }
            case .voice:
                message.type = .voice
            case .file:
                if messageText == "" {
                    message.type = .file
                } else {
                    message.type = .fileAndText
                }
            default:
                break
            }
            
            message.roomId = self.room!.id
            
            manageSendMessage(message: message.detach())
            
            self.sendMessageState(enable: false)
            self.messageTextView.text = ""
            self.currentAttachment = nil
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = nil
            self.setInputBarHeight()
            self.setupMessageTextHeightChnage()
            
        } else {
            let messages = messageTextView.text.split(limit: MAX_TEXT_LENGHT)
            for i in 0..<messages.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 0.5)) {
                    let message = IGRoomMessage(body: messages[i])
                    if (self.selectedMessageToReply == nil && IGMessageViewController.selectedMessageToForwardToThisRoom == nil && messages[i].isEmpty) {
                        self.messageTextView.text = ""
                        return
                    }
                    
                    message.type = .text
                    message.roomId = self.room!.id
                    
                    self.manageSendMessage(message: message.detach())
                    self.sendMessageState(enable: false)
                    self.messageTextView.text = ""
                    self.currentAttachment = nil
                    IGMessageViewController.selectedMessageToForwardToThisRoom = nil
                    self.selectedMessageToReply = nil
                    self.setInputBarHeight()
                    self.setupMessageTextHeightChnage()
                    
                }
            }
        }
    }
    
    /************************************************************************/
    /*********************** MONEY TRANSACTIONS ***********************/
    /************************************************************************/
    @IBAction func didTapOnMoneyTransactionsButton(_ sender: UIButton) {
        self.messageTextView.resignFirstResponder()
        self.hideMoneyInputModal()
        self.hideCardToCardModal()
        self.hideGiftStickerModal()
        self.hideGiftStickerAlertModal()
        self.hideGiftStickerCardInfoModal()
        self.hideGiftStickerInfoModal()
        
        if !(IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
            
        }
        else {
            if !(IGAppManager.sharedManager.mplActive()) && (IGAppManager.sharedManager.walletActive()) {
                
            }
            else if (IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
                self.isCardToCardRequestEnable = true
                self.manageCardToCardInputBar()
                
            }
            else {
                
                self.MoneyTransactionModalIsActive = true
                self.MoneyInputModalIsActive = false
                
                if MoneyTransactionModal == nil {
                    dismissBtn = UIButton()
                    
                    dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
                    self.view.insertSubview(dismissBtn, at: 2)
                    dismissBtn.addTarget(self, action: #selector(didtapOutSide), for: .touchUpInside)
                    
                    dismissBtn.snp.makeConstraints { (make) in
                        make.top.equalTo(self.view.snp.top)
                        make.bottom.equalTo(self.view.snp.bottom)
                        make.right.equalTo(self.view.snp.right)
                        make.left.equalTo(self.view.snp.left)
                    }
                    
                    MoneyTransactionModal = SMMoneyTransactionOptions.loadFromNib()
                    MoneyTransactionModal.btnCard.addTarget(self, action: #selector(cardToCardTapped), for: .touchUpInside)
                    MoneyTransactionModal.btnCardToCardTransfer.addTarget(self, action: #selector(cardToCardTapped), for: .touchUpInside)
                    MoneyTransactionModal.btnWallet.addTarget(self, action: #selector(walletTransferTapped), for: .touchUpInside)
                    MoneyTransactionModal.btnWalletTransfer.addTarget(self, action: #selector(walletTransferTapped), for: .touchUpInside)
                    MoneyTransactionModal.btnGiftStickerIcon.addTarget(self, action: #selector(giftStickerTapped), for: .touchUpInside)
                    MoneyTransactionModal.btnGiftStickerTitle.addTarget(self, action: #selector(giftStickerTapped), for: .touchUpInside)
                    MoneyTransactionModal!.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: MoneyTransactionModal.frame.height)
                    
                    MoneyTransactionModal.btnWalletTransfer.setTitle(IGStringsManager.Cashout.rawValue.localized, for: .normal)
                    MoneyTransactionModal.btnCardToCardTransfer.setTitle(IGStringsManager.CardToCard.rawValue.localized, for: .normal)
                    MoneyTransactionModal.btnGiftStickerTitle.setTitle(IGStringsManager.GiftCard.rawValue.localized, for: .normal)
                    
                    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
                    swipeDown.direction = .down
                    
                    MoneyTransactionModal.addGestureRecognizer(swipeDown)
                    self.view.addSubview(MoneyTransactionModal!)
                    
                }
                else {
                    MoneyTransactionModal.btnWalletTransfer.setTitle(IGStringsManager.Cashout.rawValue.localized, for: .normal)
                    MoneyTransactionModal.btnCardToCardTransfer.setTitle(IGStringsManager.CardToCard.rawValue.localized, for: .normal)
                    MoneyTransactionModal.btnGiftStickerTitle.setTitle(IGStringsManager.GiftCard.rawValue.localized, for: .normal)
                }
                
                if #available(iOS 11.0, *) {
                    let window = UIApplication.shared.keyWindow
                    let bottomPadding = window?.safeAreaInsets.bottom
                    
                    UIView.animate(withDuration: 0.3) {
                        self.MoneyTransactionModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.MoneyTransactionModal.frame.height - 45 -  bottomPadding!, width: self.view.frame.width, height: self.MoneyTransactionModal.frame.height)
                        
                    }
                }
                else {
                    UIView.animate(withDuration: 0.3) {
                        self.MoneyTransactionModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.MoneyTransactionModal.frame.height - 45, width: self.view.frame.width, height: self.MoneyTransactionModal.frame.height)
                    }
                }
                
            }
            
        }
    }
    var hasValue = false
    var userCards: [SMCard]?
    var sourceCard: SMCard!
    
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
        SMLoading.showLoadingPage(viewcontroller: self)
        SMCard.getAllCardsFromServer({ cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0 {
                        //                        self.walletView.dismissPresentedCardView(animated: true)
                        //                        self.walletHeaderView.alpha = 1.0
                        self.userCards = SMCard.getAllCardsFromDB()
                        self.hasValue = true
                        
                        if self.hasValue  {
                        }
                        if isPaygear!{
                            self.preparePayGearCard()
                        }
                    }
                }
            }
            needToUpdate = true
        }, onFailed: {err in
            //            SMLoading.showToast(viewcontroller: self, text: IGStringsManager.ServerDown.rawValue.localized)
        })
    }
    func transferToWallet(pbKey: String!,token: String)  {
        
        SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: IGStringsManager.EnterWalletPin.rawValue.localized, yesPressed: { pin in
            self.payFromSingleCard(card: self.sourceCard , pin : (pin as! String))
        }, forgotPin: {
            
            let storyboard : UIStoryboard = UIStoryboard(name: "wallet", bundle: nil)
            
            let walletSettingPage = (storyboard.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController)
            walletSettingPage.hidesBottomBarWhenPushed = true
            self.navigationController!.pushViewController(walletSettingPage, animated: true)
        })
        
    }
    func preparePayGearCard(){
        
        if let cards = userCards {
            for card in cards {
                
                if card.type == 1 && card.pan!.contains("پیگیر"){
                    self.sourceCard = card
                    SMUserManager.payGearToken = card.token
                    SMUserManager.isProtected = card.protected
                    SMUserManager.userBalance = card.balance
                }
            }
        }
    }
    
    private func payFromSingleCard(card: SMCard,pin: String) {
        
        
        let para  = NSMutableDictionary()
        para.setValue(card.token, forKey: "c")
        para.setValue((pin).onlyDigitChars().inEnglishNumbersNew(), forKey: "p2")
        para.setValue(card.type, forKey: "type")
        para.setValue(Int64(NSDate().timeIntervalSince1970 * 1000), forKey: "t")
        para.setValue(card.bankCode, forKey: "bc")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: para, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        if let enc = RSA.encryptString(jsonString, publicKey: SMUserManager.publicKey) {
            SMCard.payPayment(enc: enc, enc2: nil, onSuccess: { resp in
                if let result = resp as? NSDictionary{
                    SMUserManager.callBackUrl = (result.allValues[1]) as! String
                    SMReciept.getInstance().showReciept(viewcontroller: self, response: result)
                }
            }, onFailed: {err in
                if (err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"] != nil {
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: IGStringsManager.GlobalWarning.rawValue.localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
                }
            })
        }
    }
    @objc func walletTransferTapped() {
        
        self.hideMoneyTransactionModal()
        self.hideMoneyInputModal()
        self.hideCardToCardModal()
        
        self.MoneyInputModalIsActive = true
        self.finishDefault(isPaygear: true, isCard: false)
        
        if MoneyInputModal == nil {
            MoneyInputModal = SMSingleAmountInputView.loadFromNib()
            MoneyInputModal.confirmBtn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
            
            MoneyInputModal!.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: MoneyInputModal.frame.height)
            
            
            
            MoneyInputModal.confirmBtn.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
            //                    MoneyTransactionModal.infoLbl.text = IGStringsManager.EnterRecieverCode.rawValue.localized
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            MoneyInputModal.addGestureRecognizer(swipeDown)
            self.view.addSubview(MoneyInputModal!)
            
        }
        else {
            MoneyInputModal.confirmBtn.setTitle(IGStringsManager.GlobalOK.rawValue.localized, for: .normal)
        }
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.MoneyInputModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.MoneyInputModal.frame.height - 45 -  bottomPadding!, width: self.view.frame.width, height: self.MoneyInputModal.frame.height)
                
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.MoneyInputModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.MoneyInputModal.frame.height - 45, width: self.view.frame.width, height: self.MoneyInputModal.frame.height)
            }
        }
        
    }
    
    @objc func cardToCardTapped() {
        
        self.hideMoneyTransactionModal()
        self.hideMoneyInputModal()
        
        self.CardToCardModalIsActive = true
        
        if CardToCardModal == nil {
            CardToCardModal = SMTwoInputView.loadFromNib()
            CardToCardModal.confirmBtn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
            
            CardToCardModal!.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: CardToCardModal.frame.height)
            
            
            
            CardToCardModal.confirmBtn.setTitle(IGStringsManager.CardToCardRequest.rawValue.localized, for: .normal)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            CardToCardModal.addGestureRecognizer(swipeDown)
            self.view.addSubview(CardToCardModal!)
            
        }
        else {
            CardToCardModal.confirmBtn.setTitle(IGStringsManager.CardToCardRequest.rawValue.localized, for: .normal)
        }
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.CardToCardModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.CardToCardModal.frame.height - 5 -  bottomPadding!, width: self.view.frame.width, height: self.CardToCardModal.frame.height)
                
            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.CardToCardModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.CardToCardModal.frame.height - 5, width: self.view.frame.width, height: self.CardToCardModal.frame.height)
            }
        }
        
    }
    
    @objc func giftStickerTapped() {
        self.hideMoneyTransactionModal()
        self.hideMoneyInputModal()
        
        self.giftStickerModalIsActive = true
        
        if giftStickerModal == nil {
            giftStickerModal = SMGiftStickerAlertView.loadFromNib()
            giftStickerModal.btnOne.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
            giftStickerModal!.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: giftStickerModal.frame.height)
            giftStickerModal.btnTwo.isHidden = true
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            giftStickerModal.addGestureRecognizer(swipeDown)
            self.view.addSubview(giftStickerModal!)
            
        } else {
            giftStickerModal.btnOne.setTitle(IGStringsManager.GiftCard.rawValue.localized, for: .normal)
        }
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.giftStickerModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerModal.frame.height - 5 -  bottomPadding!, width: self.view.frame.width, height: self.giftStickerModal.frame.height)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.giftStickerModal!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerModal.frame.height - 5, width: self.view.frame.width, height: self.giftStickerModal.frame.height)
            }
        }
    }
    
    
    private func showGiftStickerPaymentInfo(cardInfo: IGStructGiftCardInfo){
        self.dismissBtn = UIButton()
        self.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        self.view.insertSubview(self.dismissBtn, at: 2)
        self.dismissBtn.addTarget(self, action: #selector(self.didtapOutSide), for: .touchUpInside)
        
        self.dismissBtn?.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
        
        self.giftStickerPaymentInfo = SMGiftCardInfo.loadFromNib()
        self.giftStickerPaymentInfo.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.giftStickerPaymentInfo.frame.height)
        self.giftStickerPaymentInfo.setInfo(giftCardInfo: cardInfo)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
        swipeDown.direction = .down
        
        self.giftStickerPaymentInfo.addGestureRecognizer(swipeDown)
        self.view.addSubview(self.giftStickerPaymentInfo)
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.giftStickerPaymentInfo!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerPaymentInfo.frame.height - 5 -  bottomPadding!, width: self.view.frame.width, height: self.giftStickerPaymentInfo.frame.height)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.giftStickerPaymentInfo!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerPaymentInfo.frame.height - 5, width: self.view.frame.width, height: self.giftStickerPaymentInfo.frame.height)
            }
        }
    }
    
    private func showCardInfo(stickerInfo: IGStructGiftCardStatus){
        self.dismissBtn = UIButton()
        self.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        self.view.insertSubview(self.dismissBtn, at: 2)
        self.dismissBtn.addTarget(self, action: #selector(self.didtapOutSide), for: .touchUpInside)
        
        self.dismissBtn?.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
            make.right.equalTo(self.view.snp.right)
            make.left.equalTo(self.view.snp.left)
        }
        
        self.giftCardInfo = stickerInfo
        self.giftStickerInfo = SMCheckGiftSticker.loadFromNib()
        self.giftStickerInfo.confirmBtn.addTarget(self, action: #selector(self.confirmTapped), for: .touchUpInside)
        self.giftStickerInfo.setInfo(giftSticker: stickerInfo)
        self.giftStickerInfo.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.giftStickerInfo.frame.height)
        self.giftStickerInfo.infoLblOne.text = IGStringsManager.GiftCard.rawValue.localized
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
        swipeDown.direction = .down
        
        self.giftStickerInfo.addGestureRecognizer(swipeDown)
        self.view.addSubview(self.giftStickerInfo)
        
       if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.giftStickerInfo!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerInfo.frame.height - 5 -  bottomPadding!, width: self.view.frame.width, height: self.giftStickerInfo.frame.height)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.giftStickerInfo!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerInfo.frame.height - 5, width: self.view.frame.width, height: self.giftStickerInfo.frame.height)
            }
        }
    }
    
    private func showActiveOrForward(fetchNationalCode: Bool = false){
        self.needToNationalCode = fetchNationalCode
        self.giftStickerAlertView = SMGiftStickerAlertView.loadFromNib()
        self.giftStickerAlertView.btnOne.addTarget(self, action: #selector(self.confirmTapped), for: .touchUpInside)
        self.giftStickerAlertView.btnTwo.addTarget(self, action: #selector(self.sendToAnother), for: .touchUpInside)
        self.giftStickerAlertView.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: self.giftStickerAlertView.frame.height)
        manageButtonsView(buttons: [giftStickerAlertView.btnOne, giftStickerAlertView.btnTwo])
        giftStickerAlertView.btnOne.setTitle(IGStringsManager.Activation.rawValue.localized, for: UIControl.State.normal)
        giftStickerAlertView.btnTwo.setTitle(IGStringsManager.GiftStickerSendToOther.rawValue.localized, for: UIControl.State.normal)
        giftStickerAlertView.infoLblOne.text = IGStringsManager.ActivateOrSendAsMessage.rawValue.localized
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
        swipeDown.direction = .down
        
        if fetchNationalCode {
            self.dismissBtn = UIButton()
            self.dismissBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
            self.view.insertSubview(self.dismissBtn, at: 2)
            self.dismissBtn.addTarget(self, action: #selector(self.didtapOutSide), for: .touchUpInside)
            
            self.dismissBtn?.snp.makeConstraints { (make) in
                make.top.equalTo(self.view.snp.top)
                make.bottom.equalTo(self.view.snp.bottom)
                make.right.equalTo(self.view.snp.right)
                make.left.equalTo(self.view.snp.left)
            }
            
            giftStickerAlertView.btnOne.setTitle(IGStringsManager.NationalCodeInquiry.rawValue.localized, for: UIControl.State.normal)
            giftStickerAlertView.btnTwo.isHidden = true
        }
        
        self.giftStickerAlertView.addGestureRecognizer(swipeDown)
        self.view.addSubview(self.giftStickerAlertView)
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.giftStickerAlertView!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerAlertView.frame.height - 5 -  bottomPadding!, width: self.view.frame.width, height: self.giftStickerAlertView.frame.height)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.giftStickerAlertView!.frame = CGRect(x: 0, y: self.view.frame.height - self.giftStickerAlertView.frame.height - 5, width: self.view.frame.width, height: self.giftStickerAlertView.frame.height)
            }
        }
    }
    
    private func manageButtonsView(buttons: [UIButton]){
          for button in buttons {
              button.layer.cornerRadius = button.bounds.height / 2
              button.layer.borderColor = ThemeManager.currentTheme.LabelColor.cgColor
              button.layer.borderWidth = 1.0
          }
      }
    
    @objc func confirmTapped() {
        
        if giftStickerInfo != nil {
            didtapOutSide(keepBackground: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showActiveOrForward()
            }
            return
        } else if giftStickerAlertView != nil {
            guard let nationalCode = giftStickerAlertView.edtInternationalCode.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
            
            didtapOutSide(keepBackground : false)
            
            IGGlobal.prgShow()
            IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] success in
                if !success {
                    IGGlobal.prgHide()
                    return
                }
                
                if self?.needToNationalCode ?? false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        IGGlobal.prgHide()
                        self?.getCardPaymentInfo(stickerId: self?.waitingCardId ?? "")
                    }
                    return
                }
                
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: true, showCancelButton: true, message: IGStringsManager.GiftCardActivationNote.rawValue.localized, doneText: IGStringsManager.GlobalDone.rawValue.localized ,cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {
                    IGGlobal.prgHide()
                }, done: {
                    IGApiSticker.shared.giftCardActivate(stickerId: self?.activationGiftStickerId ?? "", nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0(), completion: { data in
                        IGGlobal.prgHide()
                        if success {
                            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: IGStringsManager.GlobalSuccess.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.ActivationSuccessful.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                        }
                    }, error: {
                        IGGlobal.prgHide()
                    })
                })
            }
            return
        }
        
        if MoneyInputModal != nil {
            if MoneyInputModal.inputTF.text == "" ||  MoneyInputModal.inputTF.text == nil {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AmountNotValid.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)

            }
            else {
                self.hideMoneyTransactionModal()
                self.hideMoneyInputModal()
                self.hideCardToCardModal()
                self.hideGiftStickerModal()
                self.hideGiftStickerCardInfoModal()
                
                let tmpJWT : String! =  KeychainSwift().get("accesstoken")!
                SMLoading.showLoadingPage(viewcontroller: self)
                IGRequestWalletPaymentInit.Generator.generate(jwt: tmpJWT, amount: (Int64((MoneyInputModal.inputTF.text!).inEnglishNumbersNew().onlyDigitChars())!), userID: tmpUserID, description: "", language: IGPLanguage(rawValue: IGPLanguage.faIr.rawValue)!).success ({ [weak self] (protoResponse) in
                    SMLoading.hideLoadingPage()
                    if let response = protoResponse as? IGPWalletPaymentInitResponse {
                        SMUserManager.publicKey = response.igpPublicKey
                        SMUserManager.payToken = response.igpToken
                        self?.transferToWallet(pbKey: SMUserManager.publicKey, token: SMUserManager.payToken!)
                    }
                }).error ({ [weak self] (errorCode, waitTime) in
                    switch errorCode {
                        
                    case .timeout:
                        SMLoading.hideLoadingPage()
                        self?.walletTransferTapped()
                    default:
                        break
                    }
                }).send()
            }
        } else if CardToCardModal != nil {
            if CardToCardModal.inputTFOne.text == "" ||  CardToCardModal.inputTFOne.text == nil || CardToCardModal.inputTFTwo.text == "" ||  CardToCardModal.inputTFTwo.text == nil || CardToCardModal.inputTFThree.text == "" ||  CardToCardModal.inputTFThree.text == nil {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.AmountNotValid.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            } else {
                
                let messageText = CardToCardModal.inputTFOne.text!.substring(offset: MAX_TEXT_LENGHT)
                let message = IGRoomMessage.makeCardToCardRequestWithAmount(messageText: messageText, amount: ((CardToCardModal.inputTFTwo.text!).inEnglishNumbersNew().onlyDigitChars()), cardNumber: ((CardToCardModal.inputTFThree.text!).inEnglishNumbersNew().onlyDigitChars()))
                
                manageSendMessage(message: message, addForwardOrReply: false)
                
                IGMessageViewController.selectedMessageToForwardToThisRoom = nil
                self.sendMessageState(enable: false)
                self.isCardToCardRequestEnable = false
                self.messageTextView.text = ""
                self.currentAttachment = nil
                self.selectedMessageToReply = nil
                self.setInputBarHeight()
                self.hideCardToCardModal()
            }
        } else if giftStickerModal != nil {
            
            guard let nationalCode = giftStickerModal.edtInternationalCode.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
            
            self.messageTextView.text = ""
            self.currentAttachment = nil
            self.selectedMessageToReply = nil
            
            IGGlobal.prgShow()
            IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] (success) in
                self?.didtapOutSide()
                IGGlobal.prgHide()
                if !success {return}
                IGMessageViewController.giftUserId = self?.room?.chatRoom?.peer?.id
                let stickerController = IGStickerViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                stickerController.stickerPageType = .CATEGORY
                stickerController.isGift = true
                self?.navigationController!.pushViewController(stickerController, animated: true)
            }
        }
    }
    
    @objc func sendToAnother(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let nationalCode = giftStickerAlertView.edtInternationalCode.text?.inEnglishNumbersNew(), let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        IGGlobal.prgShow()
        IGApiSticker.shared.checkNationalCode(nationalCode: nationalCode, mobileNumber: phone.phoneConvert98to0()) { [weak self] success in
            IGGlobal.prgHide()
            if !success {
                return
            }
            if let attachment = IGAttachmentManager.sharedManager.getFileInfo(token: (self?.giftCardInfo.sticker.token)!) {
                let message = IGRoomMessage(body: (self?.giftCardInfo.sticker.name)!)
                message.type = .sticker
                message.attachment = attachment
                let stickerItem = IGRealmStickerItem(sticker: (self?.giftCardInfo.sticker)!, giftId: (self?.giftCardInfo.id)!)
                message.additional = IGRealmAdditional(additionalData: IGHelperJson.convertRealmToJson(stickerItem: stickerItem)!, additionalType: AdditionalType.GIFT_STICKER.rawValue)
                IGAttachmentManager.sharedManager.add(attachment: attachment)
                
                IGRoomMessage.saveFakeGiftStickerMessage(message: message.detach()) { [weak self] in
                    DispatchQueue.main.async {
                        IGHelperBottomModals.shared.showMultiForwardModal(view: self, messages: [message], isFromCloud: true, isGiftSticker: true, giftId: self?.giftCardInfo.id ?? "")
                    }
                }
            }
        }
    }
    
    @objc func didtapOutSide(keepBackground: Bool = false) {
        if dismissBtn != nil {
            if MoneyTransactionModal != nil {
                hideMoneyTransactionModal()
            }
            
            if MoneyInputModal != nil {
                self.hideMoneyInputModal()
            }
            
            if CardToCardModal != nil {
                self.hideCardToCardModal()
            }
            
            if giftStickerModal != nil {
                self.hideGiftStickerModal()
            }
            
            if giftStickerPaymentInfo != nil {
                self.hideGiftStickerCardInfoModal()
            }
            
            if giftStickerAlertView != nil {
                self.hideGiftStickerAlertModal()
            }
            
            if giftStickerInfo != nil {
                hideGiftStickerInfoModal(keepBackground: keepBackground)
            }
            
            if !keepBackground {
                dismissBtn.removeFromSuperview()
                dismissBtn = nil
            }
        }
    }
    
    @objc func cardToCardTaped() {
        if MoneyTransactionModal != nil {
            hideMoneyTransactionModal()
            self.hideMoneyInputModal()
            self.hideCardToCardModal()
            self.hideGiftStickerModal()
            self.hideGiftStickerAlertModal()
            self.hideGiftStickerCardInfoModal()
            self.hideGiftStickerInfoModal()
            self.isCardToCardRequestEnable = true
            self.manageCardToCardInputBar()
        }
    }
    
    private func sendMultiForwardRequest() {
        diselect()
    }
    
    func hideMoneyTransactionModal() {
        
        self.MoneyTransactionModalIsActive = false
        if MoneyTransactionModal != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.MoneyTransactionModal.frame.origin.y = self.view.frame.height + 100
                
            }) { (true) in
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                self.MoneyTransactionModal = nil
            }
        }
    }
    
    func hideMoneyInputModal() {
        self.MoneyInputModalIsActive = false
        if MoneyInputModal != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.MoneyInputModal.frame.origin.y = self.view.frame.height
                
            }) { (true) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                if self.MoneyInputModal != nil {
                    self.MoneyInputModal.removeFromSuperview()
                    self.MoneyInputModal = nil
                }
                if self.dismissBtn != nil {
                    self.dismissBtn.removeFromSuperview()
                }
            }
            MoneyInputModal.inputTF.endEditing(true)
        }
        
        
    }
    func hideCardToCardModal() {
        self.CardToCardModalIsActive = false
        if CardToCardModal != nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.CardToCardModal.frame.origin.y = self.view.frame.height
                
            }) { (true) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                if self.CardToCardModal != nil {
                    self.CardToCardModal.removeFromSuperview()
                    self.CardToCardModal.inputTFOne.endEditing(true)
                    self.CardToCardModal.inputTFTwo.endEditing(true)
                    self.CardToCardModal = nil
                    
                    if self.dismissBtn != nil {
                        self.dismissBtn.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    
    
    func hideGiftStickerModal() {
        self.giftStickerModalIsActive = false
        if giftStickerModal != nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.giftStickerModal.frame.origin.y = self.view.frame.height
            }) { (true) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                if self.giftStickerModal != nil {
                    self.giftStickerModal.removeFromSuperview()
                    self.giftStickerModal.edtInternationalCode.endEditing(true)
                    self.giftStickerModal = nil
                    
                    if self.dismissBtn != nil {
                        self.dismissBtn.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func hideGiftStickerAlertModal() {
        if giftStickerAlertView != nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.giftStickerAlertView.frame.origin.y = self.view.frame.height
            }) { (true) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                if self.giftStickerAlertView != nil {
                    self.giftStickerAlertView.removeFromSuperview()
                    self.giftStickerAlertView.edtInternationalCode.endEditing(true)
                    self.giftStickerAlertView = nil
                    
                    if self.dismissBtn != nil {
                        self.dismissBtn.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    func hideGiftStickerInfoModal(keepBackground: Bool = false) {
        if giftStickerInfo != nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.giftStickerInfo.frame.origin.y = self.view.frame.height
            }) { (true) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                if self.giftStickerInfo != nil {
                    self.giftStickerInfo.removeFromSuperview()
                    self.giftStickerInfo = nil
                    
                    if !keepBackground {
                        if self.dismissBtn != nil {
                            self.dismissBtn.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    
    func hideGiftStickerCardInfoModal() {
        self.giftStickerModalIsActive = false
        if giftStickerPaymentInfo != nil {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.giftStickerPaymentInfo.frame.origin.y = self.view.frame.height
            }) { (true) in
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                if self.giftStickerPaymentInfo != nil {
                    self.giftStickerPaymentInfo.removeFromSuperview()
                    self.giftStickerPaymentInfo = nil
                    
                    if self.dismissBtn != nil {
                        self.dismissBtn.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    func hideMultiShareModal() {
    }
    
    @objc func handleGesture(gesture: UITapGestureRecognizer) {
        // handling code
        if MoneyTransactionModal != nil {
            
            hideMoneyTransactionModal()
        }
        if MoneyInputModal != nil {
            
            hideMoneyInputModal()
            self.view.endEditing(true)
            
        }
        if CardToCardModal != nil {
            
            hideCardToCardModal()
            self.view.endEditing(true)
            
        }
        
        if giftStickerModal != nil {
            hideGiftStickerModal()
            self.view.endEditing(true)
        }
        
        if giftStickerPaymentInfo != nil {
            self.hideGiftStickerCardInfoModal()
        }
        
        if giftStickerAlertView != nil {
            self.hideGiftStickerAlertModal()
            self.view.endEditing(true)
        }
        
        if giftStickerInfo != nil {
            hideGiftStickerInfoModal()
        }
        
        if dismissBtn != nil {
            dismissBtn.removeFromSuperview()
        }
    }
    /************************************************************************/
    /*********************** Delete Start ***********************/
    /************************************************************************/
    @IBAction func didTapOnDeleteButton(_ sender: UIButton) {
        for message in self.selectedMessages {
            self.deleteMessage(message.detach() , both:self.isBoth)
        }
    }
    
    /************************************************************************/
    /*********************** Forward/MultiForward Start ***********************/
    /************************************************************************/
    @IBAction func didTapOnForwardButton(_ sender: UIButton) {
        self.showMultiShareModal()
        
    }
    /************************************************************************/
    /*********************** Share Start ***********************/
    /************************************************************************/
    @IBAction func didTapOnShareButton(_ sender: UIButton) {
        
    }
    
    /************************************************************************/
    /*********************** Attachment Manager Start ***********************/
    /************************************************************************/
    @IBAction func didTapOnAddAttachmentButton(_ sender: UIButton) {
        self.messageTextView.resignFirstResponder()
        
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let camera = UIAlertAction(title: IGStringsManager.Camera.rawValue.localized, style: .default, handler: { (action) in
            self.attachmentPicker(screens: [.photo, .video])
        })
        
        let galley = UIAlertAction(title: IGStringsManager.Gallery.rawValue.localized, style: .default, handler: { (action) in
            self.attachmentPicker(screens: [.library])
        })
        
        let document = UIAlertAction(title: IGStringsManager.File.rawValue.localized, style: .default, handler: { (action) in
            self.sendAsFileAlert()
        })
        
        let contact = UIAlertAction(title: IGStringsManager.ContactPermission.rawValue.localized, style: .default, handler: { (action) in
            self.openContact()
        })
        
        let location = UIAlertAction(title: IGStringsManager.Location.rawValue.localized, style: .default, handler: { (action) in
            self.openLocation()
        })
        //location.setValue(UIImage(named: "Location_Marker"), forKey: "image")
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertC.addAction(camera)
        alertC.addAction(galley)
        alertC.addAction(document)
        alertC.addAction(contact)
        alertC.addAction(location)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    private func allowCardToCard() -> Bool {
        if self.room?.type == .chat && !isBotRoom() {
            return true
        }
        return false
    }
    
    private func sendAsFileAlert(){
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let photoOrVideo = UIAlertAction(title: IGStringsManager.PhotoOrVideo.rawValue.localized, style: .default, handler: { (action) in
            self.attachmentPicker(screens: [.library], sendAsFile: true)
        })
        let document = UIAlertAction(title: IGStringsManager.Document.rawValue.localized, style: .default, handler: { (action) in
            self.documentPicker()
        })
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertC.addAction(photoOrVideo)
        alertC.addAction(document)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    /**********************************************************************************/
    /*********************************** pick media ***********************************/
    
    func attachmentPicker(screens: [YPPickerScreen] = [.library, .photo, .video], sendAsFile: Bool = false) {
        
        if screens == [.photo, .video] {
            let mediaPicker = UIImagePickerController()
            mediaPicker.delegate = self
            mediaPicker.sourceType = .camera
            mediaPicker.mediaTypes = ["public.image", "public.movie"]
            self.present(mediaPicker, animated: true, completion: nil)
            return
        }
        
        IGHelperMediaPicker.shared.setScreens(screens).setSendAsFile(sendAsFile).pick { mediaItems in
            if let videoInfo = mediaItems.singleVideo, mediaItems.count == 1 {
                self.manageVideo(videoInfo: videoInfo, sendAsFile: sendAsFile)
            } else if let imageInfo = mediaItems.singlePhoto, mediaItems.count == 1 {
                self.manageImage(imageInfo: imageInfo, sendAsFile: sendAsFile)
            } else {
                self.manageSendMultiMedia(mediaItems: mediaItems, sendAsFile: sendAsFile)
            }
        }
    }
    
    //DEPRECATED
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        self.dismiss(animated: true, completion: nil);
        
        var mediaType : String! = ""
        if let type = info["UIImagePickerControllerMediaType"] {
            mediaType = String(describing: type)
        }
        switch mediaType! {
        case "public.image": // image
            manageImage(imageInfo: info)
            break
            
        case "public.movie" : // video
            manageVideo(mediaInfo: info)
            break
            
        default: // manage file?
            break
        }
    }
    
    //DEPRECATED
    func manageVideo(mediaInfo: [String : Any]){
        guard let mediaUrl = mediaInfo["UIImagePickerControllerMediaURL"] as? URL else {
            return
        }
        
        /*** get thumbnail from video ***/
        let asset = AVURLAsset(url: mediaUrl)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = try!imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)
        
        let attachment = IGFile.makeFileInfo(name: mediaUrl.lastPathComponent,
                                                 size: IGGlobal.getFileSize(path: mediaUrl),
                                                 type: .video,
                                                 width: Double(cgImage.width),
                                                 height: Double(cgImage.height),
                                                 duration: asset.duration.seconds)
        
        if let path = attachment.localPath {
            try! FileManager.default.copyItem(atPath: mediaUrl.path, toPath: path)
            
            self.imgAttachmentImage.image = uiImage
            self.imgAttachmentImage.layer.cornerRadius = 6.0
            self.imgAttachmentImage.layer.masksToBounds = true
            
            self.didSelectAttachment(attachment)
        }
    }
    
    //DEPRECATED
    func manageImage(imageInfo: [String : Any]){
        let imageUrl = imageInfo["UIImagePickerControllerImageURL"] as? URL
        let originalImage = imageInfo["UIImagePickerControllerOriginalImage"] as! UIImage
        
        var filename : String!
        
        if imageUrl != nil {
            filename = imageUrl?.lastPathComponent
        } else {
            filename = "IMAGE_" + IGGlobal.randomString(length: 16)
        }
        var scaledImage = originalImage
        
        if (originalImage.size.width) > CGFloat(2000.0) || (originalImage.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: originalImage)
        }
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        
        let attachment = IGFile.makeFileInfo(name: filename,
                                             size: Int64(imgData?.count ?? 0),
                                             type: .image,
                                             width: Double(scaledImage.size.width),
                                             height: Double(scaledImage.size.height))
        
        DispatchQueue.main.async {
            self.saveAttachmentToLocalStorage(data: imgData!, localPath: attachment.localPath ?? "")
        }
        
        self.imgAttachmentImage.image = scaledImage
        self.imgAttachmentImage.layer.cornerRadius = 6.0
        self.imgAttachmentImage.layer.masksToBounds = true
                
        self.didSelectAttachment(attachment)
    }
    
    private func manageSendMultiMedia(mediaItems: [YPMediaItem], index: Int = 0, sendAsFile: Bool = false){
        if mediaItems.count <= index {
            return
        }
        let media = mediaItems[index]
        switch media {
        case .photo(let photo):
            self.manageImage(imageInfo: photo, single: false, sendAsFile: sendAsFile)
            break
            
        case .video(let video):
            self.manageVideo(videoInfo: video, single: false, sendAsFile: sendAsFile)
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.manageSendMultiMedia(mediaItems: mediaItems, index: index + 1, sendAsFile: sendAsFile)
        }
    }
    
    func documentPicker(){
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: documentPickerIdentifiers, in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = ThemeManager.currentTheme.LabelColor
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        if let data = try? Data(contentsOf: myURL) {
            let filename = myURL.lastPathComponent
            manageFile(fileData: data, filename: filename)
        }
    }
    
    func manageVideo(videoInfo: YPMediaVideo, single: Bool = true, sendAsFile: Bool = false){
        
        if sendAsFile {
            if let data = try? Data(contentsOf: videoInfo.url) {
                self.manageFile(fileData: data, filename: videoInfo.url.lastPathComponent, single: single)
            }
            return
        }
        
        let mediaUrl = videoInfo.url
        let attachment = IGFile.makeFileInfo(name: mediaUrl.lastPathComponent,
                                             size: IGGlobal.getFileSize(path: mediaUrl),
                                             type: .video, width: Double(videoInfo.asset!.pixelWidth),
                                             height: Double(videoInfo.asset!.pixelHeight),
                                             duration: videoInfo.asset!.duration)
        
        /***** TODO - Write File Background *****/
        if let path = attachment.localPath {
            try! FileManager.default.copyItem(atPath: mediaUrl.path, toPath: path)
            
            if single {
                self.imgAttachmentImage.image = videoInfo.thumbnail
                self.imgAttachmentImage.layer.cornerRadius = 6.0
                self.imgAttachmentImage.layer.masksToBounds = true
                self.didSelectAttachment(attachment)
            } else {
                self.currentAttachment = attachment
                self.didTapOnSendButton(self.btnSend)
            }
        }
    }
    
    func manageImage(imageInfo: YPMediaPhoto, single: Bool = true, sendAsFile: Bool = false){
        
        var image = imageInfo.modifiedImage
        if image == nil {
            image = imageInfo.originalImage
        }
        
        var filename = imageInfo.asset?.originalFilename
        if filename == nil {
           filename = "IMAGE_" + IGGlobal.randomString(length: 5) + ".png"
        }
        if sendAsFile {
            if let data = image!.pngData() {
                self.manageFile(fileData: data, filename: filename!, single: single)
            }
            return
        }
        
        var scaledImage: UIImage! = image
        if (image!.size.width) > CGFloat(2000.0) || (image!.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: image!)
        }
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        
        let attachment = IGFile.makeFileInfo(name: filename!,
                                             size: Int64(imgData?.count ?? 0),
                                             type: .image,
                                             width: Double((scaledImage.size.width)),
                                             height: Double((scaledImage.size.height)))
        
        //TODO - don't use 'DispatchQueue.main.async' like this, use closure
        //DispatchQueue.main.async {
        /***** TODO - Write File Background *****/
        self.saveAttachmentToLocalStorage(data: imgData!, localPath: attachment.localPath ?? "")
        //}
        
        if single {
            self.imgAttachmentImage.image = scaledImage
            self.imgAttachmentImage.layer.cornerRadius = 6.0
            self.imgAttachmentImage.layer.masksToBounds = true
            self.didSelectAttachment(attachment)
        } else {
            self.currentAttachment = attachment
            self.didTapOnSendButton(self.btnSend)
        }
    }
    
    func manageFile(fileData: Data, filename: String, single: Bool = true) {
        
        let attachment = IGFile.makeFileInfo(name: filename, size: Int64(fileData.count), type: .file)
        
        guard let localUrl = attachment.localUrl else {
            return
        }
        
        writeFileToUrl(data: fileData, url: localUrl) {
            DispatchQueue.main.async {
                if single {
                    self.imgAttachmentImage.image = UIImage(named: "IG_Message_Cell_File_Generic")
                    self.imgAttachmentImage.layer.cornerRadius = 6.0
                    self.imgAttachmentImage.layer.masksToBounds = true
                    self.didSelectAttachment(attachment)
                } else {
                    self.currentAttachment = attachment
                    self.didTapOnSendButton(self.btnSend)
                }
            }
        }
    }
    
    private func writeFileToUrl(data: Data, url: URL, success: @escaping ()->()){
        IGWriteFileManager.shared.perfrmOnWriteFileThread {
            // write data to my fileUrl
            try! data.write(to: url)
            success()
        }
    }
    
    private func openLocation(){
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            isSendLocation = true
            self.performSegue(withIdentifier: "showLocationViewController", sender: self)
        }
    }
    
    /*************** web view manager ***************/
    private func openWebView(url:String)  {
        
        makeWebView()
        
        if doctorBotScrollView != nil {
            doctorBotScrollView.isHidden = true
        }
        if btnChangeKeyboard != nil {
            btnChangeKeyboard.isHidden = true
        }
        
        scrollToBottomContainerView.isHidden = true
        tableViewNode.isHidden = true
        chatBackground.isHidden = true
        self.mainHolder.isHidden = true
        self.webView.isHidden = false
        self.view.endEditing(true)
        
        let url = URL(string: url)
        if let unwrappedURL = url {
            
            let request = URLRequest(url: unwrappedURL)
            let session = URLSession.shared
            
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.webView?.loadRequest(request)
                    }
                } else {
                    print("ERROR: \(String(describing: error))")
                }
            }
            task.resume()
        }
    }
    
    func closeWebView()  {
        tableViewNode.isHidden = false
        chatBackground.isHidden = false
        self.mainHolder.isHidden = false
        self.webView.stopLoading()
        self.webView.isHidden = true
        
        if doctorBotScrollView != nil {
            doctorBotScrollView.isHidden = false
        }
        if btnChangeKeyboard != nil {
            btnChangeKeyboard.isHidden = false
        }
        removeWebView()
    }
    
    private func makeWebView(){
        if self.webView == nil {
            self.webView = UIWebView()
        }
        mainView.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.equalTo(mainView.snp.top)
            make.bottom.equalTo(mainView.snp.bottom)
            make.right.equalTo(mainView.snp.right)
            make.left.equalTo(mainView.snp.left)
        }
        self.webView.delegate = self
    }
    
    private func removeWebView(){
        if self.webView != nil {
            self.webView.removeFromSuperview()
            self.webView = nil
        }
    }
    
    private func makeWebViewProgress(){
        if webViewProgressbar == nil {
            webViewProgressbar = UIActivityIndicatorView()
            webViewProgressbar.hidesWhenStopped = true
            webViewProgressbar.color = ThemeManager.currentTheme.LabelGrayColor
        }
        webView.addSubview(webViewProgressbar)
        
        webViewProgressbar.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.centerX.equalTo(webView.snp.centerX)
            make.centerY.equalTo(webView.snp.centerY)
        }
    }
    
    private func removeWebViewProgress(){
        if self.webViewProgressbar != nil {
            self.webViewProgressbar.removeFromSuperview()
            self.webViewProgressbar = nil
        }
    }
    
    
    func back() { // this back  when work that webview is working
        if webView == nil || webView.isHidden {
            myNavigationItem.backViewContainer?.isUserInteractionEnabled = false
            
            _ = self.navigationController?.popViewController(animated: true)
        } else if webView.canGoBack {
            webView.goBack()
        } else {
            closeWebView()
        }
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        removeWebViewProgress()
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        removeWebViewProgress()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if request.url?.description == "igap://close" {
            closeWebView()
        } else {
            makeWebViewProgress()
            webViewProgressbar.startAnimating()
        }
        return true
    }
    
    /***** overrided method for location manager *****/
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            openLocation()
        }
    }
    
    private func openContact(){
        IGClientActionManager.shared.sendChoosingContact(for: self.room!)
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:false, subtitleCellType: SubtitleCellValue.email)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error: NSError) {
        IGClientActionManager.shared.cancelChoosingContact(for: self.room!)
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact){
        DispatchQueue.main.async {
            IGClientActionManager.shared.cancelChoosingContact(for: self.room!)
            var phones : [String] = []
            var emails : [String] = []
            for phone in contact.phoneNumbers {
                phones.append(phone.phoneNumber)
            }
            for email in contact.emails {
                emails.append(email.email)
            }
            
            let message = IGRoomMessage(body: "")
            let contact = IGRoomMessageContact(message:message, firstName:contact.firstName, lastName:contact.lastName, phones:phones, emails:emails)
            message.contact = contact.detach()
            message.type = .contact
            message.roomId = self.room!.id
            self.manageSendMessage(message: message)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.sendMessageState(enable: false)
            self.messageTextView.text = ""
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = nil
            self.currentAttachment = nil
            self.setInputBarHeight()
        }
    }
    /**********************************************************************/
    /*********************** Attachment Manager End ***********************/
    /**********************************************************************/
    
    
    @IBAction func didTapOnDeleteSelectedAttachment(_ sender: UIButton) {
        self.currentAttachment = nil
        self.setInputBarHeight()
        let text = messageTextView.text as NSString
        if text.length > 0 {
            self.sendMessageState(enable: true)
        } else {
            self.sendMessageState(enable: false)
            self.setupMessageTextHeightChnage()
        }
    }
    
    @IBAction func didTapOnCancelReplyOrForwardButton(_ sender: UIButton) {
        IGMessageViewController.selectedMessageToForwardToThisRoom = nil
        self.isCardToCardRequestEnable = false
        self.selectedMessageToReply = nil
        if self.selectedMessageToEdit != nil {
            self.selectedMessageToEdit = nil
            self.messageTextView.text = ""
            self.lblPlaceHolder.isHidden = false
            self.showHideStickerButton(shouldShow: true)
            self.messageTextViewHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        self.setInputBarHeight()
        self.setSendAndRecordButtonStates()
    }
    
    @IBAction func didTapOnScrollToBottomButton(_ sender: UIButton) {
        if self.messageLoader.allowAddToView() {
            scrollToBottom()
        } else {
            resetAndGetFromEnd()
        }
        newMessageArrivedCount = 0
        self.lblUnreadArrieved.isHidden = true
        self.lblUnreadArrieved.text = "0".inLocalizedLanguage()

    }
    
    private func scrollToBottom(){
        self.tableViewNode.setContentOffset(CGPoint(x: 0, y: -self.tableViewNode.contentInset.top) , animated: false)
    }
    
    @IBAction func didTapOnJoinButton(_ sender: UIButton) {
        
        if isBotRoom() {
            messageTextView.text = "/Start"
            self.didTapOnSendButton(self.btnSend)
            
            self.joinButton.isHidden = true
            
            self.mainHolder.isHidden = false
            return
        }
        
        if self.room?.isParticipant ?? false {
            return // user is joined now but don't have permission to send message
        }
        
        var username: String?
        if room?.channelRoom != nil {
            if let channelRoom = room?.channelRoom {
                if channelRoom.type == .publicRoom {
                    username = channelRoom.publicExtra?.username
                }
            }
        }
        if room?.groupRoom != nil {
            if let groupRoom = room?.groupRoom {
                if groupRoom.type == .publicRoom {
                    username = groupRoom.publicExtra?.username
                }
            }
        }
        if let publicRoomUserName = username {
            IGHelperJoin.getInstance().joinByUsername(username: publicRoomUserName, roomId: room!.id) { [weak self] in
                DispatchQueue.main.async {
                    self?.joinButton.isHidden = true
                    self?.collectionViewTopInsetOffset = 8.0
                }
            }
        }
    }
    
    
    //MARK: AudioRecorder
    @objc func didTapAndHoldOnRecord(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            startRecording()
            initialLongTapOnRecordButtonPosition = gestureRecognizer.location(in: self.view)
        case .cancelled:
            break
        case .changed:
            let point = gestureRecognizer.location(in: self.view)
            let difX = (initialLongTapOnRecordButtonPosition?.x)! - point.x
            
            var newConstant:CGFloat = 0.0
            if difX > 10 {
                newConstant = 74 - difX
            } else {
                newConstant = 74
            }
            
            if newConstant > 0{
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                cancelRecording()
            }
            
        case .ended:
            finishRecording()
        case .failed:
            break
        case .possible:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func startRecording() {
        prepareViewForRecord()
        recordVoice()
    }
    
    func cancelRecording() {
        cleanViewAfterRecord()
        recorder?.stop()
        isRecordingVoice = false
        voiceRecorderTimer?.invalidate()
        recordedTime = 0
    }
    
    func finishRecording() {
        cleanViewAfterRecord()
        recorder?.stop()
        voiceRecorderTimer?.invalidate()
        recordedTime = 0
    }
    
    func prepareViewForRecord() {
        //disable rotation
        self.isRecordingVoice = true
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionFlipFromBottom, animations: {
            self.holderRecordView.isHidden = false
            self.holderRecordView.layoutIfNeeded()
        },completion: nil)
        
        
        if bouncingViewWhileRecord != nil {
            bouncingViewWhileRecord?.removeFromSuperview()
        }
        creatBounceViewForRecord()///create bounce view that represent record effect
        
        voiceRecorderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
        voiceRecorderTimer?.fire()
    }
    func creatBounceViewForRecord() {
        //let bouncingViewFrame = CGRect(x: frame.origin.x - 2*width, y: frame.origin.y - 2*width, width: 3*width, height: 3*width)
        let bouncingViewFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        bouncingViewWhileRecord = UIView(frame: bouncingViewFrame)
        bouncingViewWhileRecord?.layer.cornerRadius = CGFloat(50)
        bouncingViewWhileRecord?.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        bouncingViewWhileRecord?.alpha = 0.2
        self.view.addSubview(bouncingViewWhileRecord!)
        bouncingViewWhileRecord?.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(100)
            make.center.equalTo(self.btnMicInner)
        }
        
        
        let alpha = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alpha?.toValue = 0.0
        alpha?.repeatForever = true
        alpha?.autoreverses = true
        alpha?.duration = 1.0
        inputBarRecodingBlinkingView.pop_add(alpha, forKey: "alphaBlinking")
        
        let size = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
        size?.toValue = NSValue(cgPoint: CGPoint(x: 0.8, y: 0.8))
        size?.velocity = NSValue(cgPoint: CGPoint(x: 2, y: 2))
        size?.springBounciness = 20.0
        size?.repeatForever = true
        size?.autoreverses = true
        bouncingViewWhileRecord?.pop_add(size, forKey: "size")
        
    }
    
    func cleanViewAfterRecord() {
        //        inputBarRecordViewLeftConstraint.constant = 200
        UIView.animate(withDuration: 0.5) {
            self.inputBarRecordTimeLabel.text = "00:00"
            self.view.layoutIfNeeded()
        }
        
        
        UIView.animate(withDuration: 0.3, animations: {
        }, completion: { (success) -> Void in
            //TODO: enable rotation
            UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .transitionFlipFromBottom, animations: {
                self.holderRecordView.isHidden = true
                self.holderRecordView.layoutIfNeeded()
            },completion: nil)
                        
            //animation
            self.inputBarRecodingBlinkingView.pop_removeAllAnimations()
            self.bouncingViewWhileRecord?.removeFromSuperview()
            self.bouncingViewWhileRecord = nil
        })
        
        
    }
    
    @objc func updateTimerLabel() {
        recordedTime += 1
        let minute = String(format: "%02d", Int(recordedTime/60))
        let seconds = String(format: "%02d", Int(recordedTime%60))
        inputBarRecordTimeLabel.text = minute + ":" + seconds
    }
    
    func recordVoice() {
        do {
            self.sendRecordingVoice()
            let fileName = "Recording-\(NSDate.timeIntervalSinceReferenceDate)"
            
            let writePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)?.appendingPathExtension("m4a")
            
            var audioRecorderSetting = Dictionary<String, Any>()
            audioRecorderSetting[AVFormatIDKey] = NSNumber(value: kAudioFormatMPEG4AAC)
            audioRecorderSetting[AVSampleRateKey] = NSNumber(value: 44100.0)
            audioRecorderSetting[AVNumberOfChannelsKey] = NSNumber(value: 2)
            
            let session = AVAudioSession.sharedInstance()
            if #available(iOS 10.0, *) {
                try session.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)), mode: AVAudioSession.Mode.default)
            } else {
                // Fallback on earlier versions
            }
            
            recorder = try AVAudioRecorder(url: writePath!, settings: audioRecorderSetting)
            if recorder == nil {
                didFinishRecording(success: false)
                return
            }
            recorder?.isMeteringEnabled = true
            recorder?.delegate = self
            recorder?.prepareToRecord()
            recorder?.record()
        } catch {
            didFinishRecording(success: false)
        }
    }
    
    func didFinishRecording(success: Bool) {
        recorder = nil
    }
    
    //MARK: Attachment Handlers
    func didSelectAttachment(_ attachment: IGFile) {
        self.currentAttachment = attachment
        self.setInputBarHeight()
        self.sendMessageState(enable: true)
        lblFirstInStack.isHidden = false
        lblFileSize.isHidden = false
        self.lblFirstInStack.text  = currentAttachment?.name
        self.lblFirstInStack.lineBreakMode = .byTruncatingMiddle
        self.lblFileSize.text = IGAttachmentManager.sharedManager.convertFileSize(sizeInByte: currentAttachment!.size)
    }
    
    func saveAttachmentToLocalStorage(data: Data, localPath: String) {
        do {
            let nsurl = NSURL(fileURLWithPath: localPath)
            if let url = nsurl as URL? {
                let folder = try Folder(path: url.deletingLastPathComponent().path)
                try folder.createFileIfNeeded(at: url.lastPathComponent, contents: data)
            }
        } catch let error {
            print(error)
        }
    }
    
    //MARK: Actions for tap and hold on messages
    fileprivate func copyMessage(_ message: IGRoomMessage) {
        if let text = message.getFinalMessage().message {
            UIPasteboard.general.string = text
        }
    }
    
    fileprivate func editMessage(_ message: IGRoomMessage) {
        self.selectedMessageToEdit = message
        self.selectedMessageToReply = nil
        IGMessageViewController.selectedMessageToForwardToThisRoom = nil
        
        self.messageTextView.text = message.message

        let numLines = (messageTextView.contentSize.height / messageTextView.font!.lineHeight).rounded(.down)
        messageTextView.scrollRangeToVisible(messageTextView.selectedRange)
        switch numLines {
        case 0 :
            self.messageTextViewHeightConstraint.constant = 50
            break
        case 1 :
            self.messageTextViewHeightConstraint.constant = 50
            break
        case 2 :
            self.messageTextViewHeightConstraint.constant = 100
            break
        case 3 :
            self.messageTextViewHeightConstraint.constant = 100
            break
        case 4 :
            self.messageTextViewHeightConstraint.constant = 125
            break
        case 5 :
            self.messageTextViewHeightConstraint.constant = 150
            break
        case 6 :
            self.messageTextViewHeightConstraint.constant = 175
            break
        case 7 :
            self.messageTextViewHeightConstraint.constant = 200
            break
        case 8 :
            self.messageTextViewHeightConstraint.constant = 225
            break
        default :
            self.messageTextViewHeightConstraint.constant = 225
            
            break
            
            
        }
        self.view.layoutIfNeeded()
        self.messageTextView.isScrollEnabled = false
        self.messageTextView.isScrollEnabled = true
        
        
        
        
        
        
        
        initChangeLanguegeNewChatView()
        self.messageTextView.becomeFirstResponder()
        self.lblPlaceHolder.isHidden = true

        self.lblReplyName.text = IGStringsManager.dialogEdit.rawValue.localized
        self.lblReplyBody.text = message.message
        self.setInputBarHeight()
    }
    
    fileprivate func forwardOrReplyMessage(_ message: IGRoomMessage, isReply: Bool = true) {
        
        var finalMessage = message
        if let forwardMessage = message.forwardedFrom {
            finalMessage = forwardMessage
        }
        
        var prefix = ""
        
        self.selectedMessageToEdit = nil
        if isReply {
            prefix = IGStringsManager.Reply.rawValue.localized
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = message
        } else {
            prefix = IGStringsManager.Forward.rawValue.localized
            self.selectedMessageToReply = nil
            IGMessageViewController.selectedMessageToForwardFromThisRoom = message
            self.setSendAndRecordButtonStates()
        }
        
        if let user = finalMessage.authorUser?.user {
            self.lblReplyName.text = user.displayName
        } else if let room = finalMessage.authorRoom {
            self.lblReplyName.text = room.title
        }
        
        let textMessage = finalMessage.message
        if textMessage != nil && !(textMessage?.isEmpty)! {
            
            if message.type == .sticker {
                self.lblReplyBody.text = textMessage! + IGStringsManager.Sticker.rawValue.localized
            } else {
                self.lblReplyBody.text = textMessage
                
                let markdown = MarkdownParser()
                markdown.enabledElements = MarkdownParser.EnabledElements.bold
                self.lblReplyBody.attributedText = markdown.parse(textMessage!)
                self.lblReplyBody.textColor = ThemeManager.currentTheme.LabelGrayColor
                self.lblReplyBody.font = UIFont.igFont(ofSize: 11.0)
            }
            
        } else if finalMessage.contact != nil {
            self.lblReplyBody.text = "\(prefix)" + IGStringsManager.ContactMessage.rawValue.localized
        } else if finalMessage.location != nil {
            self.lblReplyBody.text = "\(prefix)" + IGStringsManager.LocationMessage.rawValue.localized
        } else if let file = finalMessage.attachment {
            self.lblReplyBody.text = "\(prefix) '\(IGFile.convertFileTypeToString(fileType: file.type))'" + IGStringsManager.GlobalMessage.rawValue.localized
        }
        
        self.setInputBarHeight()
    }
    
    private func manageCardToCardInputBar(){
        self.lblReplyName.text = IGStringsManager.CardToCard.rawValue.localized
        self.lblReplyBody.text = IGStringsManager.CardToCardRequest.rawValue.localized
        self.setInputBarHeight()
    }
    
    func reportRoom(roomId: Int64, messageId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, messageId: messageId, reason: reason).success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .success, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: "Your report has been successfully submitted", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).error({ [weak self] (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                        break
                case .clientRoomReportReportedBefore:
                    
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: "This Room Reported Before", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    break
                    
                case .clientRoomReportForbidden:
                    IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: "Room Report Fobidden", cancelText: IGStringsManager.GlobalClose.rawValue.localized)

                    break
                    
                default:
                    break
                }
                self?.hud.hide(animated: true)
            }
        }).send()
    }
    
    func report(room: IGRoom, message: IGRoomMessage){
        let roomId = room.id
        let messageId = message.id
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let abuse = UIAlertAction(title: IGStringsManager.Abuse.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.abuse)
        })
        
        let spam = UIAlertAction(title: IGStringsManager.Spam.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.spam)
        })
        
        let violence = UIAlertAction(title: IGStringsManager.Violence.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: IGStringsManager.Pornography.rawValue.localized, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let other = UIAlertAction(title: IGStringsManager.Other.rawValue.localized, style: .default, handler: { (action) in
            self.reportMessageId = messageId
            self.performSegue(withIdentifier: "showReportPage", sender: self)
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: { (action) in
            
        })
        
        alertC.addAction(abuse)
        alertC.addAction(spam)
        alertC.addAction(violence)
        alertC.addAction(pornography)
        alertC.addAction(other)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: {
            
        })
    }
    
    
    fileprivate func deleteMessage(_ message: IGRoomMessage, both: Bool = false) {
        
        if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
            let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        switch room!.type {
        case .chat:
            IGChatDeleteMessageRequest.Generator.generate(message: message, room: self.room!, both: both).success { (responseProto) in
                switch responseProto {
                case let response as IGPChatDeleteMessageResponse:
                    IGChatDeleteMessageRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }.error({ (errorCode, waitTime) in
                
            }).send()
        case .group:
            IGGroupDeleteMessageRequest.Generator.generate(message: message, room: room!).success({ (responseProto) in
                switch responseProto {
                case let response as IGPGroupDeleteMessageResponse:
                    IGGroupDeleteMessageRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        case .channel:
            IGChannelDeleteMessageRequest.Generator.generate(message: message, room: room!).success({ (responseProto) in
                switch responseProto {
                case let response as IGPChannelDeleteMessageResponse:
                    IGChannelDeleteMessageRequest.Handler.interpret(response: response)
                default:
                    break
                }
            }).error({ (errorCode, waitTime) in
                
            }).send()
        }
        
        if let attachment = message.attachment {
            IGDownloadManager.sharedManager.pauseDownload(attachment: attachment)
        }
        
        diselect()
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) { // TODO - when isWaiting for get from server return this method and don't do any action
        if self.tableViewNode.numberOfRows(inSection: 0) == 0 {
            return
        }
        
        setFloatingDate()
        
        //currently use inverse
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) { //reach top
            if (!self.messageLoader.isFirstLoadUp() || self.messageLoader.isForceFirstLoadUp()) && !self.messageLoader.isWaitingHistoryUpLocal() {
                self.messageLoader.loadMessage(direction: .up, onMessageReceive: { [weak self] (messages, direction) in
                    self?.addChatItem(realmRoomMessages: messages, direction: direction, scrollToBottom: false)
                })
            }
            
            /** if totalItemCount is lower than scrollEnd so (firstVisiblePosition < scrollEnd) is always true and we can't load DOWN,
             * finally for solve this problem also check following state and load DOWN even totalItemCount is lower than scrollEnd count
             */
            //if (totalItemCount <= scrollEnd) {
            //    loadMessage(DOWN);
            //}
        }
        
        if (scrollView.contentOffset.y < 0) { //reach bottom
            self.newMessageArrivedCount = 0
            
            self.lblUnreadArrieved.text = "0".inLocalizedLanguage()
            self.lblUnreadArrieved.isHidden = true
            if !(self.messageLoader?.isFirstLoadDown() ?? false) && !(self.messageLoader?.isWaitingHistoryDownLocal() ?? false) {
                self.messageLoader.loadMessage(direction: .down, onMessageReceive: { [weak self] (messages, direction) in
                    self?.addChatItem(realmRoomMessages: messages, direction: direction, scrollToBottom: false)
                })
            }
        }
        
        //100 is an arbitrary number. can be anything
        if scrollView.contentOffset.y > 100 {
            self.scrollToBottomContainerView.isHidden = false
        } else {
            self.scrollToBottomContainerView.isHidden = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            guard let sSelf = self else {
                return
            }
            sSelf.floatingDateView.alpha = 0.0
        })
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            guard let sSelf = self else {
                return
            }
            sSelf.txtFloatingDate.alpha = 0.0
        })
    }
    
    private func setFloatingDate(){
        if messages == nil {return}
        let arrayOfVisibleItems = tableViewNode.indexPathsForVisibleRows().sorted()
        if let lastIndexPath = arrayOfVisibleItems.last {
            if latestIndexPath != lastIndexPath {
                if let cell = self.tableViewNode.nodeForRow(at: IndexPath(row: lastIndexPath.row, section: 0)) as? IGLogNode, cell.message?.type != .log {
                    return
                }
                latestIndexPath = lastIndexPath
            } else {
                return
            }
            if latestIndexPath.row < messages!.count {
                
                var previousMessage: IGRoomMessage!
                if  messages!.count > latestIndexPath.row + 1 {
                    previousMessage = (messages?[latestIndexPath.row + 1].detach())!
                }
                
                if let message = messages?[latestIndexPath.row].detach(), !message.isInvalidated , message.type != .time , message.type != .progress , message.type != .unread {
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "MMMM dd"
                    dayTimePeriodFormatter.calendar = Calendar.current
                    let dateString = (message.creationTime!).localizedDate()
                    
                    var previousDateString = ""
                    if previousMessage != nil {
                        let dayTimePeriodFormatter1 = DateFormatter()
                        dayTimePeriodFormatter1.dateFormat = "MMMM dd"
                        dayTimePeriodFormatter1.calendar = Calendar.current
                        previousDateString = (previousMessage.creationTime!).localizedDate()
                    }
                    
                    if !previousDateString.isEmpty && previousDateString != dateString {
                        if !saveDate.contains(dateString) {
                            saveDate.append(dateString)
                            if firstSetDate {
                                firstSetDate = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    if let messageTime = message.creationTime {
                                        self.appendAtSpecificPosition(self.makeTimeItem(date: messageTime), cellPosition: lastIndexPath.row + 1)
                                    }
                                }
                            } else {
                                if let messageTime = message.creationTime {
                                    self.appendAtSpecificPosition(self.makeTimeItem(date: messageTime), cellPosition: lastIndexPath.row + 1)
                                }
                            }
                        }
                    }
                    
                    txtFloatingDate.text = dateString.inLocalizedLanguage()
                    UIView.animate(withDuration: 0.5, animations: {
                        self.floatingDateView.alpha = 1.0
                    })
                    UIView.animate(withDuration: 0.5, animations: {
                        self.txtFloatingDate.alpha = 1.0
                    })
                }
            }
        }
    }
    
    
    //MARK: UI states
    func setSendAndRecordButtonStates() {
        if IGMessageViewController.selectedMessageToForwardToThisRoom != nil {
            self.sendMessageState(enable: true)
        } else {
            let text = self.messageTextView.text as NSString
            if text.length == 0 && currentAttachment == nil {
                //empty -> show recored
                self.sendMessageState(enable: false)
            } else {
                //show send
                self.sendMessageState(enable: true)
            }
        }
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        segue.destination.hidesBottomBarWhenPushed = true
        
        if segue.identifier == "showSticker" {
            if #available(iOS 10.0, *) {
                let stickerViewController = segue.destination as! IGStickerViewController
                stickerViewController.stickerPageType = self.stickerPageType
                stickerViewController.stickerGroupId = self.stickerGroupId
            }
        } else if segue.identifier == "showReportPage" {
            let destinationTv = segue.destination as! IGReport
            destinationTv.room = self.room
            destinationTv.messageId = self.reportMessageId!
        } else if segue.identifier == "showLocationViewController" {
            let destinationTv = segue.destination as! IGMessageAttachmentLocation
            let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.coverVertical
            destinationTv.modalTransitionStyle = modalStyle
            destinationTv.isSendLocation = isSendLocation
            if !isSendLocation {
                destinationTv.currentLocation = receivedLocation
            } else {
                IGClientActionManager.shared.sendSendingLocation(for: self.room!)
            }
            destinationTv.room = self.room!
            destinationTv.locationDelegate = self
        }
    }
    ////MARK: - UITextfield Delegate
    func textFieldDidChange(_ textField: UITextField) {
    }
    
}


//MARK: - IGMessageCollectionViewDataSource
//extension IGMessageViewController: IGMessageCollectionViewDataSource {
//
//    private func getMessageType(message: IGRoomMessage) -> IGRoomMessageType {
//        if message.isInvalidated {
//            return IGRoomMessageType.unknown
//        }
//
//        var finalMessage = message
//        if let forward = message.forwardedFrom {
//            finalMessage = forward
//        }
//        return finalMessage.type
//    }
//
//    func collectionView(_ collectionView: IGMessageCollectionView, messageAt indexpath: IndexPath) -> IGRoomMessage {
//        return messages![indexpath.row]
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if messages != nil {
//            return messages!.count
//        }
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        self.collectionView = collectionView as? IGMessageCollectionView
//
//        if messages!.count <= indexPath.row {
//            print("VVV || popViewController index out of bound")
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnknownMessage()
//            return cell
//        }
//
//        let message = messages![indexPath.row]
//        /* if room was deleted close chat room */
//        if message.isInvalidated || (self.room?.isInvalidated)! {
//            print("VVV || popViewController load chat item")
//            self.navigationController?.popViewController(animated: true)
//
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnknownMessage()
//            return cell
//        }
//
//        var isIncommingMessage = true
//        var shouldShowAvatar = false
//        var isPreviousMessageFromSameSender = false
//        let isNextMessageFromSameSender = false
//
//        let messageType = getMessageType(message: message)
//
//
//        if self.room?.type == .channel { // isIncommingMessage means that show message left side
//            isIncommingMessage = true
//        } else if let senderHash = message.authorHash, senderHash == IGAppManager.sharedManager.authorHash() {
//            isIncommingMessage = false
//        }
//
//        if room?.groupRoom != nil {
//            shouldShowAvatar = true
//
//            if isIncommingMessage {
//                if message.type != .log {
//                    if messages!.indices.contains(indexPath.row + 1){
//                        let previousMessage = messages![(indexPath.row + 1)]
//                        if previousMessage.type != .log && message.authorHash == previousMessage.authorHash {
//                            isPreviousMessageFromSameSender = true
//                        }
//                    }
//
//                    //Hint: comment following code because corrently we don't use from 'isNextMessageFromSameSender' variable
//                    /*
//                     if messages!.indices.contains(indexPath.row - 1){
//                     let nextMessage = messages![(indexPath.row - 1)]
//                     if message.authorHash == nextMessage.authorHash {
//                     isNextMessageFromSameSender = true
//                     }
//                     }
//                     */
//                }
//            } else {
//                shouldShowAvatar = false
//            }
//        }
//
//
//        if messageType == .text {
//            let cell: TextCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCell.cellReuseIdentifier(), for: indexPath) as! TextCell
//
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .image ||  messageType == .imageAndText {
//            let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellReuseIdentifier(), for: indexPath) as! ImageCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .video || messageType == .videoAndText {
//            let cell: VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.cellReuseIdentifier(), for: indexPath) as! VideoCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .gif || messageType == .gifAndText {
//            let cell: GifCell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.cellReuseIdentifier(), for: indexPath) as! GifCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .contact {
//            let cell: ContactCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.cellReuseIdentifier(), for: indexPath) as! ContactCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .file || messageType == .fileAndText {
//            let cell: FileCell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCell.cellReuseIdentifier(), for: indexPath) as! FileCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .voice  {
//            let cell: VoiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: VoiceCell.cellReuseIdentifier(), for: indexPath) as! VoiceCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .audio || messageType == .audioAndText {
//            let cell: AudioCell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCell.cellReuseIdentifier(), for: indexPath) as! AudioCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.clickedAudioCellIndexPath = indexPath
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .sticker {
//            let cell: StickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCell.cellReuseIdentifier(), for: indexPath) as! StickerCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .location {
//            let cell: LocationCell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCell.cellReuseIdentifier(), for: indexPath) as! LocationCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .wallet {
//
//            if message.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue {
//                let cell: CardToCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardToCardCell.cellReuseIdentifier(), for: indexPath) as! CardToCardCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.payment.rawValue {
//                let cell: PaymentCell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.cellReuseIdentifier(), for: indexPath) as! PaymentCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue {
//                let cell: MoneyTransferCell = collectionView.dequeueReusableCell(withReuseIdentifier: MoneyTransferCell.cellReuseIdentifier(), for: indexPath) as! MoneyTransferCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.bill.rawValue {
//                let cell: BillCell = collectionView.dequeueReusableCell(withReuseIdentifier: BillCell.cellReuseIdentifier(), for: indexPath) as! BillCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.topup.rawValue {
//                let cell: TopupCell = collectionView.dequeueReusableCell(withReuseIdentifier: TopupCell.cellReuseIdentifier(), for: indexPath) as! TopupCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            }
//
//        } else if message.type == .log {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setLogMessage(message)
//            return cell
//        } else if message.type == .time {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setTime(message.message!)
//            return cell
//        } else if message.type == .unread {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnreadMessage(message)
//            return cell
//        } else if message.type == .progress {
//            let cell: ProgressCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressCell.cellReuseIdentifier(), for: indexPath) as! ProgressCell
//            cell.showProgress()
//            return cell
//        } else {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnknownMessage()
//            return cell
//        }
//
//
//        let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//        cell.setUnknownMessage()
//        return cell
//
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: 0.001, height: 0.001)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        var reusableview = UICollectionReusableView()
//        if kind == UICollectionView.elementKindSectionFooter {
//
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//
//            if indexPath.row < messages!.count {
//                if let message = messages?[indexPath.row] {
//                    if message.shouldFetchBefore {
//                        header.setText(IGStringsManager.GlobalLoading.rawValue.localized)
//                    } else {
//
//                        let dayTimePeriodFormatter = DateFormatter()
//                        dayTimePeriodFormatter.dateFormat = "MMMM dd"
//                        dayTimePeriodFormatter.calendar = Calendar.current
//                        let dateString = (message.creationTime!).localizedDate()
//
//                        header.setText(dateString.inLocalizedLanguage())
//                    }
//                }
//            }
//            reusableview = header
//        }
//        return reusableview
//    }
//
//    private func manageHighlightMode(cell: UICollectionViewCell, messageId: Int64) {
//        if messageId == IGMessageViewController.highlightMessageId || messageId == IGMessageViewController.highlightWithoutFastReturn {
//            IGMessageViewController.highlightMessageId = 0
//            IGMessageViewController.highlightWithoutFastReturn = 0
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                UIView.transition(with: cell, duration: 0.5, animations: {
//                    cell.backgroundColor = UIColor.iGapGreen().withAlphaComponent(0.5)
//                }, completion: { (completed) in
//                    UIView.animate(withDuration: 0.5, animations: {
//                        cell.backgroundColor = UIColor.clear
//                    }, completion: nil)
//                })
//            }
//        }
//    }
//}
//
////MARK: - UICollectionViewDelegateFlowLayout
//extension IGMessageViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        if messages!.count <= indexPath.row { return CGSize(width: 0, height: 0) }
//
//        let message = messages![indexPath.row]
//        let size = self.collectionView.layout.sizeCell(room: self.room!, for: message)
//        let frame = size.bubbleSize
//
//        return CGSize(width: self.collectionView.frame.width, height: frame.height + size.additionalHeight + 2)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let message = messages![indexPath.row]
//        let additionalType = message.additional?.dataType ?? -1
//        if (IGGlobal.shouldMultiSelect && additionalType != AdditionalType.GIFT_STICKER.rawValue) {
//            if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
//                self.selectedMessages.remove(at: index)
//            } else {
//                self.selectedMessages.append(message)
//            }
//
//            if self.selectedMessages.count > 0 {
//                lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + " " + IGStringsManager.Selected.rawValue.localized
//            } else {
//                lblSelectedMessages.text = ""
//            }
//            self.collectionView.reloadItems(at: [indexPath])
//
//        } else {
//            self.messageTextView.resignFirstResponder()
//            if message.type == .sticker {
//
//            }
//
//        }
//    }
//}


//MARK: - IGMessageCollectionViewDataSource
//extension IGMessageViewController: IGMessageCollectionViewDataSource {
//
//
//    func collectionView(_ collectionView: IGMessageCollectionView, messageAt indexpath: IndexPath) -> IGRoomMessage {
//        return messages![indexpath.row]
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if messages != nil {
//            return messages!.count
//        }
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        self.collectionView = collectionView as? IGMessageCollectionView
//
//        if messages!.count <= indexPath.row {
//            print("VVV || popViewController index out of bound")
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnknownMessage()
//            return cell
//        }
//
//        let message = messages![indexPath.row]
//        /* if room was deleted close chat room */
//        if message.isInvalidated || (self.room?.isInvalidated)! {
//            print("VVV || popViewController load chat item")
//            self.navigationController?.popViewController(animated: true)
//
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnknownMessage()
//            return cell
//        }
//
//        var isIncommingMessage = true
//        var shouldShowAvatar = false
//        var isPreviousMessageFromSameSender = false
//        let isNextMessageFromSameSender = false
//
//        let messageType = getMessageType(message: message)
//
//
//        if self.room?.type == .channel { // isIncommingMessage means that show message left side
//            isIncommingMessage = true
//        } else if let senderHash = message.authorHash, senderHash == IGAppManager.sharedManager.authorHash() {
//            isIncommingMessage = false
//        }
//
//        if room?.groupRoom != nil {
//            shouldShowAvatar = true
//
//            if isIncommingMessage {
//                if message.type != .log {
//                    if messages!.indices.contains(indexPath.row + 1){
//                        let previousMessage = messages![(indexPath.row + 1)]
//                        if previousMessage.type != .log && message.authorHash == previousMessage.authorHash {
//                            isPreviousMessageFromSameSender = true
//                        }
//                    }
//
//                    //Hint: comment following code because corrently we don't use from 'isNextMessageFromSameSender' variable
//                    /*
//                     if messages!.indices.contains(indexPath.row - 1){
//                     let nextMessage = messages![(indexPath.row - 1)]
//                     if message.authorHash == nextMessage.authorHash {
//                     isNextMessageFromSameSender = true
//                     }
//                     }
//                     */
//                }
//            } else {
//                shouldShowAvatar = false
//            }
//        }
//
//
//        if messageType == .text {
//            let cell: TextCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCell.cellReuseIdentifier(), for: indexPath) as! TextCell
//
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .image ||  messageType == .imageAndText {
//            let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellReuseIdentifier(), for: indexPath) as! ImageCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .video || messageType == .videoAndText {
//            let cell: VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.cellReuseIdentifier(), for: indexPath) as! VideoCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .gif || messageType == .gifAndText {
//            let cell: GifCell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.cellReuseIdentifier(), for: indexPath) as! GifCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .contact {
//            let cell: ContactCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.cellReuseIdentifier(), for: indexPath) as! ContactCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .file || messageType == .fileAndText {
//            let cell: FileCell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCell.cellReuseIdentifier(), for: indexPath) as! FileCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .voice  {
//            let cell: VoiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: VoiceCell.cellReuseIdentifier(), for: indexPath) as! VoiceCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .audio || messageType == .audioAndText {
//            let cell: AudioCell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCell.cellReuseIdentifier(), for: indexPath) as! AudioCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.clickedAudioCellIndexPath = indexPath
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .sticker {
//            let cell: StickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCell.cellReuseIdentifier(), for: indexPath) as! StickerCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .location {
//            let cell: LocationCell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCell.cellReuseIdentifier(), for: indexPath) as! LocationCell
//            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//
//            if IGGlobal.shouldMultiSelect {
//                if selectedMessages.count > 0 {
//                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
//                    if selectedBefore {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    } else {
//                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
//                            cell.btnCheckMark.setTitle("", for: .normal)
//                        }, completion: nil)
//                    }
//                } else {
//                    if cell.btnCheckMark != nil {
//                        cell.btnCheckMark.setTitle("", for: .normal)
//                    }
//                }
//            }
//
//            manageHighlightMode(cell: cell, messageId: message.id)
//
//            cell.delegate = self
//            return cell
//
//        } else if messageType == .wallet {
//
//            if message.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue {
//                let cell: CardToCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardToCardCell.cellReuseIdentifier(), for: indexPath) as! CardToCardCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.payment.rawValue {
//                let cell: PaymentCell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.cellReuseIdentifier(), for: indexPath) as! PaymentCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue {
//                let cell: MoneyTransferCell = collectionView.dequeueReusableCell(withReuseIdentifier: MoneyTransferCell.cellReuseIdentifier(), for: indexPath) as! MoneyTransferCell
//                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
//                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
//                cell.delegate = self
//                return cell
//            }
//
//        } else if message.type == .log {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setLogMessage(message)
//            return cell
//        } else if message.type == .time {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setTime(message.message!)
//            return cell
//        } else if message.type == .unread {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnreadMessage(message)
//            return cell
//        } else if message.type == .progress {
//            let cell: ProgressCell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressCell.cellReuseIdentifier(), for: indexPath) as! ProgressCell
//            cell.showProgress()
//            return cell
//        } else {
//            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//            cell.setUnknownMessage()
//            return cell
//        }
//
//
//        let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//        cell.setUnknownMessage()
//        return cell
//
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: 0.001, height: 0.001)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        var reusableview = UICollectionReusableView()
//        if kind == UICollectionView.elementKindSectionFooter {
//
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
//
//            if indexPath.row < messages!.count {
//                if let message = messages?[indexPath.row] {
//                    if message.shouldFetchBefore {
//                        header.setText(IGStringsManager.GlobalLoading.rawValue.localized)
//                    } else {
//
//                        let dayTimePeriodFormatter = DateFormatter()
//                        dayTimePeriodFormatter.dateFormat = "MMMM dd"
//                        dayTimePeriodFormatter.calendar = Calendar.current
//                        let dateString = (message.creationTime!).localizedDate()
//
//                        header.setText(dateString.inLocalizedLanguage())
//                    }
//                }
//            }
//            reusableview = header
//        }
//        return reusableview
//    }
//
//    private func manageHighlightMode(cell: UICollectionViewCell, messageId: Int64) {
//        if messageId == IGMessageViewController.highlightMessageId || messageId == IGMessageViewController.highlightWithoutFastReturn {
//            IGMessageViewController.highlightMessageId = 0
//            IGMessageViewController.highlightWithoutFastReturn = 0
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                UIView.transition(with: cell, duration: 0.5, animations: {
//                    cell.backgroundColor = UIColor.iGapGreen().withAlphaComponent(0.5)
//                }, completion: { (completed) in
//                    UIView.animate(withDuration: 0.5, animations: {
//                        cell.backgroundColor = UIColor.clear
//                    }, completion: nil)
//                })
//            }
//        }
//    }
//}

//MARK: - UICollectionViewDelegateFlowLayout
//extension IGMessageViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        if messages!.count <= indexPath.row { return CGSize(width: 0, height: 0) }
//
//        let message = messages![indexPath.row]
//        let size = self.collectionView.layout.sizeCell(room: self.room!, for: message)
//        let frame = size.bubbleSize
//
//        return CGSize(width: self.collectionView.frame.width, height: frame.height + size.additionalHeight + 2)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        let message = messages![indexPath.row]
//        if (IGGlobal.shouldMultiSelect) {
//            if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
//                self.selectedMessages.remove(at: index)
//            } else {
//                self.selectedMessages.append(message)
//            }
//
//            if self.selectedMessages.count > 0 {
//                lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + " " + IGStringsManager.Selected.rawValue.localized
//            } else {
//                lblSelectedMessages.text = ""
//            }
//            self.collectionView.reloadItems(at: [indexPath])
//
//        } else {
//            self.messageTextView.resignFirstResponder()
//            if message.type == .sticker {
//
//            }
//
//        }
//    }
//
//}


//MARK: - GrowingTextViewDelegate
extension IGMessageViewController: UITextViewDelegate {
    
    func allowSendTyping() -> Bool {
        let currentTime = IGGlobal.getCurrentMillis()
        let difference = currentTime - self.latestTypeTime
        if difference < 1000 {
            self.latestTypeTime = currentTime
            return false
        }
        self.latestTypeTime = currentTime
        return true
    }
    
    func textViewDidChangeHeight(_ height: CGFloat) {
        inputTextViewHeight = height
        setInputBarHeight()
    }
    
    func setInputBarHeight() {
        if currentAttachment != nil {
            holderAttachmentBar.isHidden = false
        } else {
            holderAttachmentBar.isHidden = true
        }

        if selectedMessageToEdit != nil {
            holderReplyBar.isHidden = false
            lblPlaceHolder.isHidden = true
        } else if selectedMessageToReply != nil {
            holderReplyBar.isHidden = false
            lblPlaceHolder.isHidden = true
        } else if IGMessageViewController.selectedMessageToForwardToThisRoom != nil {
            holderReplyBar.isHidden = false
        } else {
            holderReplyBar.isHidden = true
        }
    }
    
    func managePinnedMessage(){
        if room?.pinMessage != nil && room?.pinMessage?.id != room?.deletedPinMessageId {
            txtPinnedMessage.text = IGRoomMessage.detectPinMessage(message: (room?.pinMessage)!)
            self.stackTopViews.isHidden = false
        } else {
            self.stackTopViews.isHidden = true
        }
    }
}

//MARK: - AVAudioRecorderDelegate
extension IGMessageViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        sendCancelRecoringVoice()
        if self.isRecordingVoice {
            self.didFinishRecording(success: flag)
            let filePath = recorder.url
            let asset = AVURLAsset(url: filePath)
            let time = CMTimeGetSeconds(asset.duration)
            if time < 1.0 {
                return
            }
            do {
                let data = try Data(contentsOf: filePath)
                let attachment = IGFile.makeFileInfo(name: filePath.lastPathComponent, size: Int64(data.count), type: .voice, filePathType: .voice)
                /***** TODO - Write File Background *****/
                self.saveAttachmentToLocalStorage(data: data, localPath: (attachment.localPath ?? ""))
                self.currentAttachment = attachment
                self.didTapOnSendButton(self.btnSend)
            } catch let error {
                print(error)
            }
        }
        self.isRecordingVoice = false
    }
}

//MARK: - IGMessageGeneralCollectionViewCellDelegate
extension IGMessageViewController: IGMessageGeneralCollectionViewCellDelegate {
    
    func didTapOnContactDetail(contact: IGRoomMessageContact) {
        let contactInfoVC = IGContactDetailController(contact: contact)
        presentPanModal(contactInfoVC)
    }
    
    
    func didTapAndHoldOnMessage(cellMessage: IGRoomMessage,index: IndexPath) {
        
        if cellMessage.isInvalidated {return}
        
        if cellMessage.status == IGRoomMessageStatus.sending {
            return
        }
        
        self.view.endEditing(true)
        
        if cellMessage.status == IGRoomMessageStatus.failed {
            if !(IGGlobal.shouldMultiSelect) {
                manageFailedMessage(cellMessage: cellMessage.detach())
            }
        } else {
            if !(IGGlobal.shouldMultiSelect) {
                manageSendedMessage(cellMessage: cellMessage.detach(),id: cellMessage.id)
                
            }
        }
    }
    
    func didTapOnFailedStatus(cellMessage: IGRoomMessage) {
        DispatchQueue.main.async {
            IGMessageSender.defaultSender.resend(message: cellMessage, to: self.room!)
        }
    }
    
    func swipToReply(cellMessage: IGRoomMessage) {
        if !(IGGlobal.shouldMultiSelect) {
            
            if cellMessage.status == IGRoomMessageStatus.sending {
                return
            }
            
            self.view.endEditing(true)
            
            if cellMessage.status == IGRoomMessageStatus.failed {
            } else {
                self.forwardOrReplyMessage(cellMessage.detach())
            }
            if !IGGlobal.isKeyboardPresented {
                messageTextView.becomeFirstResponder()
            }
            
        }
    }
    
    private func manageSendedMessage(cellMessage: IGRoomMessage,id: Int64){
        
        if self.room!.isInvalidated {
            return
        }
        
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let copy = UIAlertAction(title: IGStringsManager.Copy.rawValue.localized, style: .default, handler: { (action) in
            self.copyMessage(cellMessage)
        })
        
        var pinTitle = IGStringsManager.Pin.rawValue.localized
        if self.room?.pinMessage != nil && self.room?.pinMessage?.id == cellMessage.id {
            pinTitle = IGStringsManager.UnPin.rawValue.localized
        }
        
        let pin = UIAlertAction(title: pinTitle, style: .default, handler: { (action) in
            if self.groupPinGranted(){
                if self.room?.pinMessage != nil && self.room?.pinMessage?.id == cellMessage.id {
                    self.groupPin()
                } else {
                    self.groupPin(messageId: cellMessage.id)
                }
            } else if self.channelPinGranted() {
                if self.room?.pinMessage != nil && self.room?.pinMessage?.id == cellMessage.id {
                    self.channelPin()
                } else {
                    self.channelPin(messageId: cellMessage.id)
                }
            }
        })
        let reply = UIAlertAction(title: IGStringsManager.Reply.rawValue.localized, style: .default, handler: { (action) in
            self.forwardOrReplyMessage(cellMessage)
        })
        
        let forward = UIAlertAction(title: IGStringsManager.Forward.rawValue.localized, style: .default, handler: { (action) in
            self.enableMultiSelect(State: true, cellMessage: cellMessage,isForward : true,isDelete : false,isShare : false,id:id)
        })
        
        let edit = UIAlertAction(title: IGStringsManager.dialogEdit.rawValue.localized, style: .default, handler: { (action) in
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalNoNetwork.rawValue.localized, preferredStyle: .alert)
                let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.editMessage(cellMessage)
            }
        })
        
        let share = UIAlertAction(title: IGStringsManager.Share.rawValue.localized, style: .default, handler: { (action) in
            var finalMessage = cellMessage.detach()
            if let forward = cellMessage.forwardedFrom {
                finalMessage = forward
            }
            IGHelperPopular.shareAttachment(url: finalMessage.attachment?.localUrl, viewController: self)
        })
        
        let report = UIAlertAction(title: IGStringsManager.Report.rawValue.localized, style: .default, handler: { (action) in
            self.report(room: self.room!.detach(), message: cellMessage)
        })
        
        var deleteTitle = ""
        if self.room!.type == .group || self.room!.type == .channel || self.room!.isCloud() {
            deleteTitle =  IGStringsManager.Delete.rawValue.localized
        } else {
            deleteTitle =  IGStringsManager.DeleteForMe.rawValue.localized
        }
        let deleteForMe = UIAlertAction(title: deleteTitle, style: .destructive, handler: { (action) in
            self.isBoth = false
            self.enableMultiSelect(State: true, cellMessage: cellMessage,isForward : false,isDelete : true,isShare : false, id: id)
            
        })
        let roomTitle = self.room?.title != nil ? self.room!.title! : ""
        let deleteForBoth = UIAlertAction(title: IGStringsManager.DeleteForMeAnd.rawValue.localized + roomTitle, style: .destructive, handler: { (action) in
            self.isBoth = true
            self.enableMultiSelect(State: true, cellMessage: cellMessage,isForward : false,isDelete : true,isShare : false, id: id)
            
        })
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: { (action) in
        })
        
        //Copy
        if allowCopy(cellMessage.detach()){
            alertC.addAction(copy)
        }
        
        if allowPin() {
            alertC.addAction(pin)
        }
        
        //Reply
        if allowReply(){
            alertC.addAction(reply)
        }
        
        //Forward
        if allowForward(cellMessage) {
            alertC.addAction(forward)
        }
        
        //Edit
        if self.allowEdit(cellMessage.detach()){
            alertC.addAction(edit)
        }
        
        //Share
        if self.allowShare(cellMessage.detach()){
            alertC.addAction(share)
        }
        
        alertC.addAction(report)
        
        //Delete
        let delete = allowDelete(cellMessage.detach())
        if delete.singleDelete {
            alertC.addAction(deleteForMe)
        }
        if delete.bothDelete {
            alertC.addAction(deleteForBoth)
        }
        
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    func enableMultiSelect(State: Bool! ,cellMessage: IGRoomMessage ,isForward:Bool? = nil ,isDelete:Bool? = nil ,isShare:Bool? = nil,id: Int64) {
        
        
        if cellMessage.type == .log ||  cellMessage.type == .unread || cellMessage.type == .time || cellMessage.type == .progress { } else {
            IGGlobal.shouldMultiSelect = State
            self.selectedMessages.removeAll()
            self.selectedMessages.append(cellMessage)
            self.showMultiSelectUI(state: State,isForward:isForward,isDelete:isDelete,id: id)

        }

        
    }
    
    
    func showMultiShareModal(isCloud: Bool = false) {
        self.MultiShareModalIsActive = true
        IGHelperBottomModals.shared.showMultiForwardModal(view: self,messages : self.selectedMessages, isFromCloud: isCloud )
    }
    
    private func manageFailedMessage(cellMessage: IGRoomMessage){
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let resend = UIAlertAction(title: IGStringsManager.SendAgain.rawValue.localized, style: .default, handler: { (action) in
            DispatchQueue.main.async {
                IGMessageSender.defaultSender.resend(message: cellMessage, to: self.room!)
            }
        })
        
        let copy = UIAlertAction(title: IGStringsManager.Copy.rawValue.localized, style: .default, handler: { (action) in
            self.copyMessage(cellMessage)
        })
        
        let delete = UIAlertAction(title: IGStringsManager.Delete.rawValue.localized, style: .destructive, handler: { (action) in
            if let attachment = cellMessage.attachment {
                IGMessageSender.defaultSender.deleteFailedMessage(primaryKeyId: attachment.cacheID, hasAttachment: true)
            } else {
                IGMessageSender.defaultSender.deleteFailedMessage(primaryKeyId: cellMessage.primaryKeyId)
            }
            
            if let roomMessage = self.messages, let indexOfMessage = roomMessage.firstIndex(of: cellMessage) {
                self.removeItem(cellPosition: indexOfMessage)
            }
        })
        
        let cancel = UIAlertAction(title: IGStringsManager.GlobalCancel.rawValue.localized, style: .cancel, handler: nil)
        
        alertC.addAction(resend)
        if let text = cellMessage.getFinalMessage().message, !text.isEmpty {
            alertC.addAction(copy)
        }
        alertC.addAction(delete)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    // MARK: - Start - Go to Message Position
    /**
     * if set 'enableFastReturn' true, after find and show message position a button is will be exist for return to clicked message
     */
    func goToPosition(messageId: Int64 = 0, enableFastReturn: Bool = false){
        
        if enableFastReturn {
            IGMessageViewController.highlightMessageId = messageId
        } else {
            IGMessageViewController.highlightWithoutFastReturn = messageId
        }
        
//        let msgId = messageId > 0 ? messageId : -messageId
        
        let indexOfMessage = IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.firstIndex(of: messageId)
        if indexOfMessage != nil {
            let indexPath = IndexPath(row: indexOfMessage!, section: 0)
            var previousIndexPath = indexPath
            var futureIndexPath = indexPath
            previousIndexPath.row = indexPath.row + 1
            futureIndexPath.row = indexPath.row - 1
            /* when 'previousIndexPath' is visible and user clicked on reply view 'indexPath' completely
             * is showing so JUST notify Position and DON'T call scroll to item
             */
            
            if !self.tableViewNode.indexPathsForVisibleRows().contains(previousIndexPath) {
                self.tableViewNode.scrollToRow(at: indexPath, at: .bottom, animated: false)
            } else if !self.tableViewNode.indexPathsForVisibleRows().contains(futureIndexPath) {
                self.tableViewNode.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
//            if !self.collectionViewNode.indexPathsForVisibleItems.contains(previousIndexPath) {
//                self.collectionViewNode.scrollToItem(at: indexPath, at: .bottom, animated: false)
//            } else if !self.tableViewNode.indexPathsForVisibleItems.contains(futureIndexPath) {
//                self.tableViewNode.scrollToItem(at: indexPath, at: .bottom, animated: false)
//            }
            
            if enableFastReturn {
                notifyPosition(messageId: IGMessageViewController.highlightMessageId)
            } else {
                notifyPosition(messageId: IGMessageViewController.highlightWithoutFastReturn)
            }
        } else {
            if IGRoomMessage.existMessage(roomId: self.room!.id, messageId: messageId) {
                loadMessageAfterFetch(messageId: messageId)
            } else {
                IGGlobal.prgShow()
                IGHelperMessage.shared.getMessage(roomId: self.room!.id, messageId: messageId) { (roomMessage) in
                    IGGlobal.prgHide()
                    DispatchQueue.main.async {
                        self.loadMessageAfterFetch(messageId: roomMessage?.id)
                    }
                }
            }
        }
    }
    
    private func loadMessageAfterFetch(messageId: Int64?){
        self.clearCollectionView()
        if messageId != nil {
            self.messageLoader.setSavedScrollMessageId(savedScrollMessageId: messageId!)
        }
        self.startLoadMessage()
    }
    
    func notifyPosition(messageId: Int64){
        if let indexOfMessge = IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.firstIndex(of: messageId) {
            let indexPath = IndexPath(row: indexOfMessge, section: 0)
//            self.tableViewNode.reloadItems(at: [indexPath])
//            self.tableViewNode.reloadRows(at: [indexPath], with: .none)
            if let cell = tableViewNode.nodeForRow(at: indexPath) as? ChatControllerNode {
                
//                cell.backgroundColor = ThemeManager.currentTheme.NavigationFirstColor.withAlphaComponent(0.6)
//                UIView.animate(withDuration: 2, delay: 0.2, options: .curveEaseOut, animations: {
//                    cell.backgroundColor = UIColor.clear
//                }, completion: nil)
                UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [.calculationModeCubic], animations: {
                    // Add animations

                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0/1.0, animations: {
                        cell.backgroundColor = UIColor.clear
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.5/1.0, relativeDuration: 1.0/1.0, animations: {
                        cell.backgroundColor = ThemeManager.currentTheme.NavigationFirstColor.withAlphaComponent(0.3)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 1.0/1.0, relativeDuration: 1.0/1.0, animations: {
                        cell.backgroundColor = UIColor.clear
                    })
                
                }, completion:{ _ in
                    print("I'm done animating!")
                })
                
            }
            
        }
    }
    // MARK: - Gift Sticker Actions
    /***********************************************************************************************************************************************************************/
    /************************************************************************** Gift Sticker *******************************************************************************/
    
    private func manageGiftStickerAction(stickerId: String){
        self.activationGiftStickerId = stickerId
        IGGlobal.prgShow()
        IGApiSticker.shared.getGiftCardGetStatus(stickerId: stickerId, completion: { [weak self] giftCardStatusInfo in
            IGGlobal.prgHide()
            
            if giftCardStatusInfo.isActive && giftCardStatusInfo.isCardOwner { //show card info
                self?.getCardPaymentInfo(stickerId: stickerId)
            } else if giftCardStatusInfo.isForwarded { //this card sended to another user
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.GiftCardSentNote.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            } else if giftCardStatusInfo.isActive { //this card is actived by another user
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalAttention.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.LabelColor, message: IGStringsManager.GiftCardAlreadyUsed.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            } else { // show (activation or send to another user) options
                self?.showCardInfo(stickerInfo: giftCardStatusInfo)
            }
            
        }, error: {
            IGGlobal.prgHide()
            //show message
        })
    }
    
    private func getCardPaymentInfo(stickerId: String){
        let nationalCode = IGSessionInfo.getNationalCode()
        if nationalCode == nil || nationalCode!.isEmpty {
            self.waitingCardId = stickerId
            showActiveOrForward(fetchNationalCode: true)
            return
        }
        
        IGGlobal.prgShow()
        guard let phone = IGRegisteredUser.getPhoneWithUserId(userId: IGAppManager.sharedManager.userID() ?? 0) else {return}
        
        IGApiSticker.shared.getGiftCardInfo(stickerId: stickerId, nationalCode: nationalCode!, mobileNumber: phone.phoneConvert98to0(), completion: { [weak self] giftCardInfo in
            IGGlobal.prgHide()
            self?.showGiftStickerPaymentInfo(cardInfo: giftCardInfo)
            }, error: {
                IGGlobal.prgHide()
        })
    }
    
    /************************************************************************** Gift Sticker *******************************************************************************/
    /***********************************************************************************************************************************************************************/
    
    /******* overrided method for show file attachment (use from UIDocumentInteractionControllerDelegate) *******/
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func didTapOnAttachment(cellMessage: IGRoomMessage) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(0.3)), animations: {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.view.layoutIfNeeded()
            
        })
        
        if cellMessage.status == .sending || cellMessage.status == .failed {
            return
        }
        
        var finalMessage = cellMessage
        if cellMessage.forwardedFrom != nil {
            finalMessage = cellMessage.forwardedFrom!
        }
        
        if finalMessage.type == .sticker {
            if finalMessage.additional?.dataType == AdditionalType.GIFT_STICKER.rawValue {
                self.view.endEditing(true)
                if let sticker = IGHelperJson.parseStickerMessage(data: (finalMessage.additional?.data)!) {
                    manageGiftStickerAction(stickerId: sticker.giftId)
                }
                return
            }
            if (finalMessage.attachment?.name?.contains(".json"))! {
                if let sticker = IGHelperJson.parseStickerMessage(data: (finalMessage.additional?.data)!) {
                    stickerPageType = StickerPageType.PREVIEW
                    stickerGroupId = sticker.groupId
                    performSegue(withIdentifier: "showSticker", sender: self)
                }
                return
            } else {
                if let sticker = IGHelperJson.parseStickerMessage(data: (finalMessage.additional?.data)!) {
                    stickerPageType = StickerPageType.PREVIEW
                    stickerGroupId = sticker.groupId
                    performSegue(withIdentifier: "showSticker", sender: self)
                }
                return
            }

        }
        
        if finalMessage.type == .location {
            isSendLocation = false
            receivedLocation = CLLocation(latitude: (finalMessage.location?.latitude)!, longitude: (finalMessage.location?.longitude)!)
            self.performSegue(withIdentifier: "showLocationViewController", sender: self)
            return
        }
        
        var attachmetVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: finalMessage.attachment!.cacheID!)
        if attachmetVariableInCache == nil {
            guard let attachment = finalMessage.attachment?.detach() else {
                return
            } //ThreadSafeReference(to: finalMessage.attachment!)
            IGAttachmentManager.sharedManager.add(attachment: attachment)
            attachmetVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: finalMessage.attachment!.cacheID!)
        }
        
        var attachment: IGFile!
        if attachmetVariableInCache == nil {
            attachment = attachmetVariableInCache!.value
        } else {
            attachment = finalMessage.attachment
        }
        
        if attachment.status != .ready && !IGGlobal.isFileExist(path: finalMessage.attachment?.localPath) {
            return
        }
        
        switch finalMessage.type {
        case .image, .imageAndText:
            let mediaViewer = IGMediaPager.instantiateFromAppStroryboard(appStoryboard: .Main)
            mediaViewer.hidesBottomBarWhenPushed = true
            mediaViewer.ownerId = self.room?.id
            mediaViewer.messageId = cellMessage.id
            mediaViewer.mediaPagerType = .imageAndVideo
            self.navigationController!.pushViewController(mediaViewer, animated: false)
            return
            
        case .video, .videoAndText:
            if let url = attachment.localUrl {
                let player = AVPlayer(url: url)
                let avController = AVPlayerViewController()
                avController.player = player
                player.play()
                present(avController, animated: true, completion: nil)
            }
            return
        case .voice , .audio, .audioAndText :
            let musicPlayer = IGMusicViewController()
            musicPlayer.attachment = finalMessage.attachment
            self.present(musicPlayer, animated: true, completion: nil)
            return
            
        case .file , .fileAndText:
            if let url = attachment.localUrl {
                let controller = UIDocumentInteractionController()
                controller.delegate = self
                controller.url = url
                controller.presentPreview(animated: true)
            }
            return
        default:
            return
        }
    }
    
    func didTapOnForwardedAttachment(cellMessage: IGRoomMessage) {
        if let forwardedMsgType = cellMessage.forwardedFrom?.type {
            switch forwardedMsgType {
            case .audio , .voice :
                let musicPlayer = IGMusicViewController()
                musicPlayer.attachment = cellMessage.forwardedFrom?.attachment
                self.present(musicPlayer, animated: true, completion: {
                })
                break
            case .video, .videoAndText:
                if let url = cellMessage.forwardedFrom?.attachment?.localUrl {
                    let player = AVPlayer(url: url)
                    let avController = AVPlayerViewController()
                    avController.player = player
                    player.play()
                    present(avController, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }
    
    func didTapOnSenderAvatar(cellMessage: IGRoomMessage) {
        if let user = cellMessage.authorUser?.user {
            self.selectedUserToSeeTheirInfo = user
            openUserProfile()
        }
    }
    
    func didTapOnUserName(user: IGRegisteredUser) {
        self.selectedUserToSeeTheirInfo = user
        openUserProfile()
    }
    
    func didTapOnHashtag(hashtagText: String) {
        
    }
    
    func didTapOnReply(cellMessage: IGRoomMessage){
        if let replyMessage = cellMessage.repliedTo {
            IGMessageViewController.returnToMessage = cellMessage
            
            var mainReplyId = replyMessage.id > 0 ? (replyMessage.id) : (replyMessage.id * -1)
            if let forwardedMessage = IGRoomMessage.fetchForwardMessage(roomId: self.room!.id, messageId: -mainReplyId) {
                mainReplyId = forwardedMessage.id
            }
            goToPosition(messageId: mainReplyId, enableFastReturn: true)
        }
    }
    
    func didTapOnForward(cellMessage: IGRoomMessage){
        if let forwardMessage = cellMessage.forwardedFrom {
            var usernameType : IGPClientSearchUsernameResponse.IGPResult.IGPType = .room
            if forwardMessage.authorUser != nil {
                usernameType = .user
            }
            IGHelperChatOpener.manageOpenChatOrProfile(usernameType: usernameType, user: forwardMessage.authorUser?.user, room: forwardMessage.authorRoom)
        }
    }
    
    func didTapOnReturnToMessage(){
        if let message = IGMessageViewController.returnToMessage {
            IGMessageViewController.highlightWithoutFastReturn = message.id
            goToPosition(messageId: message.id)
        }
    }
    
    func didTapOnMultiForward(cellMessage: IGRoomMessage,isFromCloud: Bool = false){
        self.selectedMessages.removeAll()
        self.selectedMessages.append(cellMessage)
        
        showMultiShareModal(isCloud : isFromCloud)
    }
    
    func didTapOnMention(mentionText: String) {
        
        var finalString = mentionText.trimmingCharacters(in: .whitespaces)
        
        if finalString[finalString.startIndex] == "@" {
            finalString.remove(at: finalString.startIndex)
        }
        if finalString.starts(with: "\n@") { //check if fetched mention name incorrectly
            
            finalString = String(finalString.dropFirst(2))
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
        
        //if dont have /join buy starts with igap.net
        if urlStringLower.contains("https://igap.net/") || urlStringLower.contains("http://igap.net/") ||  urlStringLower.contains("igap.net/") {
            if urlStringLower.contains("https://igap.net/join") || urlStringLower.contains("http://igap.net/join") ||  urlStringLower.contains("igap.net/join") {
                didTapOnRoomLink(link: urlString)
                return
            } else {
                let strings = urlString.split(separator: "/")
                let token = strings[strings.count-1]
                IGHelperChatOpener.checkUsernameAndOpenRoom(username: String(token))

                return

            }
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
        let strings = link.split(separator: "/")
        let token = strings[strings.count-1]
        IGHelperJoin.getInstance().requestToCheckInvitedLink(invitedLink: String(token))
    }
    
    func didTapOnBotAction(action: String){
        if !isBotRoom() {return}
        
        var myaction : String = action
        if !(myaction.contains("/")) {
            myaction = "/"+myaction
        }
        messageTextView.text = myaction
        self.didTapOnSendButton(self.btnSend)
    }
    
    func createChat(selectedUser: IGRegisteredUser) {
        let hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        hud.mode = .indeterminate
        IGChatGetRoomRequest.Generator.generate(peerId: selectedUser.id).success({ [weak self] (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let chatGetRoomResponse as IGPChatGetRoomResponse:
                    let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                    
                    IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ [weak self] (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                let room = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                let roomVC = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                                roomVC.room = room
                                roomVC.hidesBottomBarWhenPushed = true
                                self?.navigationController!.pushViewController(roomVC, animated: true)
                            default:
                                break
                            }
                            self?.hud.hide(animated: true)
                        }
                    }).error ({ [weak self] (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            switch errorCode {
                            case .timeout:
                                break
                            default:
                                break
                            }
                            self?.hud.hide(animated: true)
                        }
                    }).send()
                    
                    hud.hide(animated: true)
                    break
                default:
                    break
                }
            }
            
        }).error({ [weak self] (errorCode, waitTime) in
            hud.hide(animated: true)
            let alert = UIAlertController(title: IGStringsManager.GlobalWarning.rawValue.localized, message: IGStringsManager.GlobalTryAgain.rawValue.localized, preferredStyle: .alert)
            let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
            alert.addAction(okAction)
            self?.present(alert, animated: true, completion: nil)
        }).send()
    }
}



//MARK: - StatusBar Tap
extension IGMessageViewController {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func addNotificationObserverForTapOnStatusBar() {
        NotificationCenter.default.addObserver(forName: IGNotificationStatusBarTapped.name, object: .none, queue: .none) {  [weak self] _ in
            if self != nil {
                if self!.tableViewNode.view.contentSize.height < self!.tableViewNode.view.frame.height {
                    return
                }
                //1200 is just an arbitrary number. can be anything
                let newOffsetY = min(self!.tableViewNode.contentOffset.y + 1200, self!.tableViewNode.view.contentSize.height - self!.tableViewNode.view.frame.height + self!.tableViewNode.contentInset.bottom)
                let newOffsett = CGPoint(x: 0, y: newOffsetY)
                self!.tableViewNode.setContentOffset(newOffsett , animated: true)
            }
        }
    }
    
}

//MARK: - Set and cancel current action (typing, ...)
extension IGMessageViewController {
    fileprivate func sendTyping() {
        IGClientActionManager.shared.sendTyping(for: self.room!)
    }
    @objc fileprivate func sendCancelTyping() {
        
        if !self.allowSendTyping() {
            typingStatusExpiryTimer.invalidate()
            typingStatusExpiryTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                           target:   self,
                                                           selector: #selector(sendCancelTyping),
                                                           userInfo: nil,
                                                           repeats:  false)
        } else {
            typingStatusExpiryTimer.invalidate()
            IGClientActionManager.shared.cancelTying(for: self.room!)
        }
    }
    
    fileprivate func sendRecordingVoice() {
        IGClientActionManager.shared.sendRecordingVoice(for: self.room!)
    }
    fileprivate func sendCancelRecoringVoice() {
        IGClientActionManager.shared.sendCancelRecoringVoice(for: self.room!)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}


/************************************************************************************/
/********************************** Message Loader **********************************/
/************************************************************************************/

extension IGMessageViewController {
    
    /*********************************************************************************/
    /******************* Collection Manager (Add , Remove , Update) ******************/
    
    /** manage current state of scroll and reload message history from end or just scroll to end */
    private func manageSendMessage(message: IGRoomMessage, addForwardOrReply: Bool = true, isSticker: Bool = false) {
        if self.messageLoader.allowAddToView() {
            let detachedMessage = message.detach()
            IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
            if addForwardOrReply {
                message.forwardedFrom = IGMessageViewController.selectedMessageToForwardToThisRoom // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                message.repliedTo = selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
            }
            if isSticker {
                IGMessageSender.defaultSender.sendSticker(message: message, to: room!)
            } else {
                IGMessageSender.defaultSender.send(message: message, to: room!)
            }
            self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
        } else {
            resetAndGetFromEnd()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let detachedMessage = message.detach()
                IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                if addForwardOrReply {
                    message.forwardedFrom = IGMessageViewController.selectedMessageToForwardToThisRoom // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                    message.repliedTo = self.selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                }
                if isSticker {
                    IGMessageSender.defaultSender.sendSticker(message: message, to: self.room!)
                } else {
                    IGMessageSender.defaultSender.send(message: message, to: self.room!)
                }
                self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
            }
        }
    }
    
    
    /* scroll to bottom as default for send message (Text Message/File Message) */
    func addChatItem(realmRoomMessages: [IGRoomMessage], direction: IGPClientGetRoomHistory.IGPDirection, scrollToBottom: Bool = true){

        if realmRoomMessages.count == 0 || self.room!.isInvalidated {
            return
        }

        if direction == .down {
            if self.messageLoader.getBiggestMessageId() != 0 && self.messageLoader.getBiggestMessageId() > realmRoomMessages[realmRoomMessages.count-1].id {
                return
            }
            self.messageLoader.setBiggestMessage(biggestMessage: realmRoomMessages[realmRoomMessages.count-1])
        }

        if scrollToBottom && !self.messageLoader.allowAddToView() {
            // in this state (mabye all stats) when "scrollToBottom" is true, "realmRoomMessages" just has one item
            if let authorHash = realmRoomMessages[0].authorHash, authorHash == IGAppManager.sharedManager.authorHash() {
                resetAndGetFromEnd()
                return
            } else {
                return
            }
        }

        if direction == .up { // Up direction
            if self.messageLoader.isFirstLoadUp() {
                
                var delay: Double = 0
                if self.messageLoader.hasUnread() || self.messageLoader.hasSavedState() {
                    delay = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.appendMessageArray(realmRoomMessages, direction)
                    self.addChatItemToTop(count: realmRoomMessages.count)
                    self.messageLoader.setFirstLoadUp(firstLoadUp: false)
                    self.messageLoader.setForceFirstLoadUp(forceFirstLoadUp: false)
                    self.messageLoader.setWaitingHistoryUpLocal(isWaiting: false)
                }
            } else {
                // update first item into the view for manage avatar and message sender name
                var updateMessageId: Int64 = 0
                if self.room != nil && !self.room!.isInvalidated && self.room!.type == .group , let messageIds = IGMessageViewController.messageIdsStatic[(self.room?.id)!] {
                    if messageIds.count > 0 {
                        updateMessageId = messageIds[messageIds.count-1]
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.appendMessageArray(realmRoomMessages, direction)
                    self.addChatItemToTop(count: realmRoomMessages.count)
                    self.messageLoader.setWaitingHistoryUpLocal(isWaiting: false)
                    if updateMessageId != 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                            if let pos = IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.firstIndex(of: updateMessageId) {
                                self.updateItem(cellPosition: pos)
                            }
                        }
                    }
                }
            }
        } else { // Down Direction

            if self.messageLoader.isFirstLoadDown() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.appendMessageArray(realmRoomMessages, direction)
                    self.addChatItemToBottom(count: realmRoomMessages.count, scrollToBottom: scrollToBottom)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let bottomOffset = CGPoint(x: 0, y: self.tableViewNode.view.contentSize.height - self.tableViewNode.view.bounds.size.height)
                        self.tableViewNode.setContentOffset(bottomOffset, animated: false)
                    }
                    self.messageLoader.setFirstLoadDown(firstLoadDown : false)
                    self.messageLoader.setWaitingHistoryDownLocal(isWaiting: false)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.appendMessageArray(realmRoomMessages, direction)
                    if self.isNearToBottom() {
                        self.addChatItemToBottom(count: realmRoomMessages.count, scrollToBottom: scrollToBottom)
                    }else {
                        if realmRoomMessages[0].type != .log, let authorHash = realmRoomMessages[0].authorHash, authorHash == IGAppManager.sharedManager.authorHash() {
                            self.addChatItemToBottom(count: realmRoomMessages.count, scrollToBottom: scrollToBottom)
                        } else {

                            self.addChatItemToBottom(count: realmRoomMessages.count, scrollToBottom: false)
                        }
                    }
                    self.messageLoader.setWaitingHistoryDownLocal(isWaiting: false)
                    if scrollToBottom {
                        // check log type for avoid from always scroll to bottom after pin message
                        if realmRoomMessages[0].type != .log, let authorHash = realmRoomMessages[0].authorHash, authorHash == IGAppManager.sharedManager.authorHash() {
                            self.scrollManager(force: true)
                        } else {
                            self.scrollManager()
                        }
                    }
                }
            }
        }
    }
    
    private func addChatItemToBottom(count: Int, scrollToBottom: Bool = false) {
        let contentHeight = self.tableViewNode!.view.contentSize.height
        let offsetY = self.tableViewNode!.contentOffset.y
        let bottomOffset = contentHeight - offsetY
        
        if !scrollToBottom {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        
        self.tableViewNode?.performBatchUpdates({
            var arrayIndex: [IndexPath] = []
            
            for index in 0...(count-1) {
                arrayIndex.append(IndexPath(row: index, section: 0))
            }
            
            self.tableViewNode?.insertRows(at: arrayIndex, with: .none)
        }, completion: { _ in
            if !scrollToBottom {
                self.tableViewNode!.contentOffset = CGPoint(x: 0, y: self.tableViewNode!.view.contentSize.height - bottomOffset)
                CATransaction.commit()
            }
        })
        if isNearToBottom() {
            self.newMessageArrivedCount = 0
            self.lblUnreadArrieved.isHidden = true
            self.lblUnreadArrieved.text = "0".inLocalizedLanguage()
        } else {
            if newMessageArrivedCount == 0 {
                self.lblUnreadArrieved.isHidden = true
            } else {
                self.lblUnreadArrieved.isHidden = false
            }
        }
    }
    
    private func addChatItemToTop(count: Int) {
        self.tableViewNode?.performBatchUpdates({
            var arrayIndex: [IndexPath] = []
            
            for index in 0...(count-1) {
                arrayIndex.append(IndexPath(row: (messages!.count-count)+index, section: 0))
            }
            
            self.tableViewNode.insertRows(at: arrayIndex, with: .none)
        }, completion: nil)
    }
    
    private func addWaitingProgress(direction: IGPClientGetRoomHistory.IGPDirection){
        if direction == .up {
            addChatItemToTop(count: 1)
        } else {
            addChatItemToBottom(count: 1, scrollToBottom: true)
        }
    }
    
    private func removeItem(cellPosition: Int?){
        if cellPosition == nil {return}
        
        deleteThread.sync {
            self.removeMessageArrayByPosition(cellPosition: cellPosition)
            self.tableViewNode?.performBatchUpdates({
                self.tableViewNode?.deleteRows(at: [IndexPath(row: cellPosition!, section: 0)], with: .none)
            }, completion: nil)
        }
    }
    
    private func removeProgress(fakeMessageId: Int64, direction: IGPClientGetRoomHistory.IGPDirection){
        DispatchQueue.main.async {
            if let cellPosition = IGMessageViewController.messageIdsStatic[(self.currentRoomId)!]?.firstIndex(of: fakeMessageId) {
                if self.messages!.count <= cellPosition  {
                    return
                }
                self.removeMessageArrayByPosition(cellPosition: cellPosition)
                self.tableViewNode?.performBatchUpdates({
                    self.tableViewNode?.deleteRows(at: [IndexPath(row: cellPosition, section: 0)], with: .none)
                }, completion: nil)
            }
        }
    }
    
    private func updateItem(cellPosition: Int,action: ChatMessageAction = .none){
        if self.messages!.count <= cellPosition  {
            return
        }

        switch action {
            default:
                self.tableViewNode.reloadRows(at: [IndexPath(row: cellPosition, section: 0)], with: .none)
        }
    }
    
    private func updateMessageStatus(cellPosition: Int,status: IGRoomMessageStatus = .unknown) {
        for indexPath in [IndexPath(row: cellPosition, section: 0)] {
            let cell = self.tableViewNode.nodeForRow(at: indexPath) as? ChatControllerNode
            print("=-=-=-=- update called Message status")
            cell?.updatMessage(action: .updateStatus,status: status, message: nil)

        }

    }
    
    /*********************************************************************************/
    /******************************** Popular Methods ********************************/
    
    private func appendMessageArray(_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection){
        if IGMessageViewController.messageIdsStatic[(self.room?.id)!] == nil {
            IGMessageViewController.messageIdsStatic[(self.room?.id)!] = []
        }
        
        if direction == .up {
            for message in messages {
                self.messages!.append(message.detach())
                IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.append(message.id)
            }
        } else {
            for message in messages {
                self.messages!.insert(message.detach(), at: 0)
                IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.insert(message.id, at: 0)
            }
        }
    }
    
    private func appendAtSpecificPosition(_ message: IGRoomMessage, cellPosition: Int){
        if self.messages!.count <= cellPosition  {
            return
        }
        
        self.messages!.insert(message.detach(), at: cellPosition)
        IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.insert(message.id, at: cellPosition)
        
        self.tableViewNode?.performBatchUpdates({
            self.tableViewNode?.insertRows(at: [IndexPath(row: cellPosition, section: 0)], with: .none)
        }, completion: nil)
    }
    
    private func removeMessageArray(messageId: Int64){
        if let index = IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.firstIndex(of: messageId) {
            IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.remove(at: index)
        }
    }
    
    private func removeMessageArrayByPosition(cellPosition: Int?){
        if cellPosition != nil && self.messages!.count <= cellPosition!  {
            return
        }
        
        self.messages?.remove(at: cellPosition!)
        IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.remove(at: cellPosition!)
    }
    
    private func updateMessageArray(cellPosition: Int, message: IGRoomMessage){
        if self.messages!.count <= cellPosition  {
            return
        }
        
        self.messages![cellPosition] = message
        if IGMessageViewController.messageIdsStatic[(self.room?.id) ?? -1] != nil {
            IGMessageViewController.messageIdsStatic[(self.room?.id)!]![cellPosition] = message.id
        }
    }
    
    private func makeTimeItem(date: Date) -> IGRoomMessage {
        let message = IGRoomMessage(body: date.localizedDate().inLocalizedLanguage())
        message.type = .time
        return message
    }
    
    private func resetAndGetFromEnd(){
        self.scrollToBottomContainerView.isHidden = true
        self.clearCollectionView()
        self.startLoadMessage(fetchDown: false)
    }
    
    private func clearCollectionView(){
        self.messageLoader.resetMessagingValue()
        self.messages?.removeAll()
        IGMessageViewController.messageIdsStatic.removeAll()
        reloadCollection()
        self.tableViewNode.contentOffset = .zero
    }
    
    private func reloadCollection(){
        _ = self.tableViewNode.numberOfRows(inSection: 0)
        self.tableViewNode.reloadData()
    }
    
    /**
     * send scroll to bottom if needed
     */
    private func scrollManager(force: Bool = false){
        if force || isNearToBottom() {
            DispatchQueue.main.async {
                self.scrollToBottom()
            }
        }
    }
    
    /**
     * if current state of collection is near to bottom (according to "IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT" param),
     * so collection state is near to bottom
     */
    private func isNearToBottom() -> Bool {
        
        let visibleCells = self.tableViewNode.indexPathsForVisibleRows().sorted(by:{
            $0.section < $1.section || $0.row < $1.row
        }).compactMap({
            self.tableViewNode.nodeForRow(at: $0)
        })
        
        if visibleCells.count > 0, self.tableViewNode.indexPath(for: visibleCells[0])!.row > IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT {
            return false
        }
        return true
    }
    
    //TODO - make delete method for find deleted item position and then detect that deleted item is upper than user position or is lower that from user, and finally remove item without move view because of remove item
}
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}



extension IGMessageViewController : ASTableDelegate, ASTableDataSource {
    
    private func getMessageType(message: IGRoomMessage) -> IGRoomMessageType {
        if message.isInvalidated {
            return IGRoomMessageType.unknown
        }
        
        var finalMessage = message
        if let forward = message.forwardedFrom {
            finalMessage = forward
        }
        return finalMessage.type
    }
    
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.messages!.count
    }
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let msg = messages![indexPath.row]
        if (IGGlobal.shouldMultiSelect) {
            let cellNode  = self.tableViewNode.nodeForRow(at: indexPath) as! ChatControllerNode
            cellNode.isSelected = false
            
            if msg.type == .unread || msg.type == .progress || msg.type == .time || msg.type == .log || msg.type == .wallet {
                return
            }
            
            if ((self.tableViewNode.nodeForRow(at: indexPath) as! ChatControllerNode).checkNode!.view.tag) == 001 {
                (self.tableViewNode.nodeForRow(at: indexPath) as! ChatControllerNode).checkNode!.view.tag = 002
                self.selectedMessages.append(msg)
                IGGlobal.makeAsyncText(for: (self.tableViewNode.nodeForRow(at: indexPath) as! ChatControllerNode).checkNode!, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 30, weight: .regular, numberOfLines: 1, font: .fontIcon, alignment: .center)
            } else {
                if let index = self.selectedMessages.firstIndex(where: { $0.id == msg.id }) {
                    self.selectedMessages.remove(at: index)
                }
                (self.tableViewNode.nodeForRow(at: indexPath) as! ChatControllerNode).checkNode!.view.tag = 001
                IGGlobal.makeAsyncText(for: (self.tableViewNode.nodeForRow(at: indexPath) as! ChatControllerNode).checkNode!, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 30, weight: .regular, numberOfLines: 1, font: .fontIcon, alignment: .center)

            }
        }else {
            self.messageTextView.resignFirstResponder()
        }
        
        if self.selectedMessages.count > 0 {
            lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + " " + IGStringsManager.Selected.rawValue.localized
        } else {
            lblSelectedMessages.text = ""
        }
    }
    
    
    
//    let message = messages![indexPath.row]
//    if (IGGlobal.shouldMultiSelect) {
//        if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
//            self.selectedMessages.remove(at: index)
//        } else {
//            self.selectedMessages.append(message)
//        }
//
//        if self.selectedMessages.count > 0 {
//            lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + " " + IGStringsManager.Selected.rawValue.localized
//        } else {
//            lblSelectedMessages.text = ""
//        }
//        self.collectionView.reloadItems(at: [indexPath])
//
//    } else {
//        self.messageTextView.resignFirstResponder()
//        if message.type == .sticker {
//
//        }
//
//    }
    
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {

        let msg = messages?[indexPath.row]
        let cellnodeBlock  = {[weak self] () -> ASCellNode in
            
            guard let sSelf = self else {
                return ASCellNode()
            }
            
            var isIncomming = true
            let authorHash = msg!.authorHash
            var shouldShowAvatar = false
            let isFromSameSender = false
            
            if sSelf.finalRoom.type == .group || sSelf.finalRoom.type == .chat || sSelf.finalRoom.type == .channel  {
                shouldShowAvatar = true
                
                // if msg!.type != .log {
                //     if sSelf.messages!.indices.contains(indexPath.row + 1){
                //         let previousMessage = sSelf.messages![(indexPath.row + 1)]
                //         if previousMessage.type != .log && msg!.authorHash == previousMessage.authorHash {
                //             isFromSameSender = false // should be true for next version
                //         }
                //     }
                // }
            }
            var img = UIImage()
            
            if sSelf.finalRoom.type == .channel { // isIncommingMessage means that show message left side
                isIncomming = true
                img = tailLesImage
                
            } else {
                
                if let senderHash = authorHash, senderHash == IGAppManager.sharedManager.authorHash() {
                    isIncomming = false
                    
                }
                if isFromSameSender {
                    if isIncomming {
                        img = tailLesImage
                        
                    } else {
                        img = mineTailLesImage
                        
                    }
                    
                } else {
                    
                    if isIncomming {
                        img = someoneImage
                        
                    } else {
                        img = mineImage
                        
                    }
                }
                
            }
            
            let cellNode = ChatControllerNode(message: msg!.detach(), finalRoomType: sSelf.finalRoom!.type, finalRoom: sSelf.finalRoom!,isIncomming: isIncomming, bubbleImage: img, isFromSameSender: isFromSameSender, shouldShowAvatar: shouldShowAvatar, indexPath: indexPath)
            cellNode.selectionStyle = .none
            cellNode.delegate = self
            return cellNode
        }
            
        return cellnodeBlock
    }
            
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = collectionView.bounds.width;
        return ASSizeRangeMake(CGSize(width: width, height: 0), CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    }
}
