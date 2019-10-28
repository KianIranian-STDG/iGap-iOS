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
import GrowingTextView
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

class IGMessageViewController: BaseViewController, DidSelectLocationDelegate, UIDocumentInteractionControllerDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CNContactPickerDelegate, EPPickerDelegate, UIDocumentPickerDelegate, AdditionalObserver, MessageViewControllerObserver, UIWebViewDelegate, StickerTapListener, UITextFieldDelegate, HandleReciept, HandleBackNavigation {
    
    //newUITextMessage
    // MARK: - Outlets
    
    @IBOutlet weak var stackTopViews: UIStackView!
    @IBOutlet weak var stackMessageView: UIStackView!
    @IBOutlet weak var mainHolder: UIStackView!
    @IBOutlet weak var holderRecordView: UIView!
    @IBOutlet weak var holderAttachmentBar: UIView!
    @IBOutlet weak var holderReplyBar: UIView!
    @IBOutlet weak var holderTextBox: UIView!
    @IBOutlet weak var holderMultiSelect: UIView!
    @IBOutlet weak var holderMusicPlayer: UIView!
    @IBOutlet weak var holderMusicPlayerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var floatingDateTopConstraints: NSLayoutConstraint!

    //musicplayer variables
    var singerName : String! = ""
    var songName : String! = ""
    var songTimer : Float! = 0.0
    ///
    @IBOutlet weak var lblFileType: UILabel!
    @IBOutlet weak var lblActionType: UILabel!
    @IBOutlet weak var lblFirstInStack: UILabel!
    @IBOutlet weak var lblSecondInStack: UILabel!
    @IBOutlet weak var lblThirdInStack: UILabel!
    @IBOutlet weak var lblFileSize: UILabel!
    
    @IBOutlet weak var lblReplyName : UILabel!
    @IBOutlet weak var lblReplyBody : UILabel!
    
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
    @IBOutlet weak var messageCollectionBottomCollectionConstrains: NSLayoutConstraint!

    @IBOutlet weak var btnStickerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Variables
    var alreadyInSendMode : Bool = false
    var musicFile : MusicFile!

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
        self.btnAttachment.isHidden = false
        
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
        self.holderMessageTextView.backgroundColor = UIColor(named: themeColor.modalViewBackgroundColor.rawValue)
        self.btnAttachmentNew.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        self.btnSend.setTitleColor(UIColor(named: themeColor.backgroundColor.rawValue), for: .normal)
        self.btnSend.backgroundColor = UIColor(named: themeColor.labelColor.rawValue)
        self.btnMoney.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        self.btnTrash.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        self.btnAttachmentNew.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        self.btnShare.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        self.btnMic.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
        self.btnSticker.setTitleColor(UIColor(named: themeColor.labelGrayColor.rawValue), for: .normal)
        self.lblPlaceHolder.textColor = UIColor(named: themeColor.textFieldPlaceHolderColor.rawValue)
        
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
        lblPlaceHolder.textAlignment = lblPlaceHolder.localizedNewDirection
        //        messageTextView.textAlignment = messageTextView.localizedNewDirection
    }
    ///setting Strings based on language of App
    private func initChangeLanguegeNewChatView() {
        lblPlaceHolder.isHidden = false
        lblPlaceHolder.text = "MESSAGE".MessageViewlocalizedNew
        lblCenterText.text = "SLIDE_TO_CANCEL".MessageViewlocalizedNew
        lblCenterIcon.text = ""
        self.btnCloseTopBar.titleLabel!.font = UIFont.iGapFonticon(ofSize: 25)
        self.btnCloseTopBar.setTitle("", for: .normal)
        
        self.btnCloseReplyBar.titleLabel!.font = UIFont.iGapFonticon(ofSize: 25)
        self.btnCloseReplyBar.setTitle("", for: .normal)
        
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
        
        let userInfo = notification.userInfo!
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        let window = UIApplication.shared.keyWindow!
        
        if #available(iOS 11.0, *){
            self.messageTextViewBottomConstraint.constant = keyboardHeight!
        }
        else {
            self.messageTextViewBottomConstraint.constant = view.safeAreaInsets.bottom
        }
        UIView.animate(withDuration: 0.5){
            
            self.view.layoutIfNeeded()
            
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
            
            if forwardModal != nil {
                self.hideMultiShareModal()
            }
        }
        self.view.layoutIfNeeded()
    }
    private func showHideStickerButton(shouldShow : Bool!) {
        if shouldShow {
            
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
    ///Handle Show hide of attachment button
    func handleShowHideAttachmentButton(shouldShow : Bool!) {
        if shouldShow {

            btnAttachment.isHidden = false
        } else {
            btnAttachment.isHidden = true
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
            if !isBotRoom() {
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
        print("BUTTON MIC STATE :","Single Tap On MIC BUTTON")
        sender.backgroundColor = UIColor(named: themeColor.labelColor.rawValue)
        sender.titleLabel!.textColor = UIColor.red

        sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        IGHelperShowToastAlertView.shared.showPopAlert(view: self,innerView: holderMessageTextView, message: "LONG_PRESS_TO_RECORD".MessageViewlocalizedNew, time: 2.0, type: .alert)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            sender.transform = CGAffineTransform.identity
            sender.backgroundColor = UIColor.clear
            sender.titleLabel!.textColor = UIColor.red
            sender.layoutIfNeeded()
        }, completion: { (completed) in
            sender.titleLabel!.textColor = UIColor.red
            sender.titleLabel!.textColor = UIColor(named:themeColor.labelColor.rawValue)

            sender.setTitleColor(UIColor(named: themeColor.labelColor.rawValue), for: .normal)
            
        })
        
    }
    
    @objc func didLongTapOnMicButton(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
            
        case .began :
            
            startRecording()
            initialLongTapOnRecordButtonPosition = gesture.location(in: self.view)
            
            print("BUTTON MIC STATE :","Long Press STARTED")
            
            break
        case .cancelled :
            print("BUTTON MIC STATE :","Long Press CANCELED")
            
            break
        case .changed :
            print("BUTTON MIC STATE :","Long Press CHANGED STATE")
            let point = gesture.location(in: self.view)
            let difX = (initialLongTapOnRecordButtonPosition?.x)! - point.x
            
            var newConstant:CGFloat = 0.0
            
            if difX > 10 {
                newConstant = 74 - difX
            } else {
                newConstant = 74
            }
            print(newConstant)
            
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
            print("BUTTON MIC STATE :","Long Press HAS ENDED")
            
            break
        case .possible:
            print("BUTTON MIC STATE :","Long Press IS POSSIBLE")
            
            break
        case .failed:
            print("BUTTON MIC STATE :","Long Press HAS FAILED")
            
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
        
        if textView.text == "" || textView.text.isEmpty {
            alreadyInSendMode = false
            
            lblPlaceHolder.isHidden = false///handle send button animation
            showHideStickerButton(shouldShow: true)
            ///hides send button and show Mic and Money button if textview is empty
            handleShowHideMicButton(shouldShow: true)
            handleShowHideShareButton(shouldShow: false)
            handleShowHideSendButton(shouldShow: false)
            handleShowHideMoneyButton(shouldShow: true)
            self.messageTextViewHeightConstraint.constant = 50
            
        } else {
            lblPlaceHolder.isHidden = true
            showHideStickerButton(shouldShow: false)
            ///hides Mic and Money button and show Send button if textview is empty
            handleShowHideMicButton(shouldShow: false)
            handleShowHideShareButton(shouldShow: false)
            handleShowHideSendButton(shouldShow: true)
            handleShowHideMoneyButton(shouldShow: false)
            
            let numLines = (textView.contentSize.height / textView.font!.lineHeight).rounded(.down)
            textView.scrollRangeToVisible(textView.selectedRange)
            switch numLines {
            case 0,1 :
                self.messageTextViewHeightConstraint.constant = 50
                break
            case 2 :
                self.messageTextViewHeightConstraint.constant = 60
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
                
                self.view.layoutIfNeeded()
                
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var selectedMessages : [IGRoomMessage] = []
    var sendTone: AVAudioPlayer?
    
    
    
    
    
    
    
    
    
    
    
    
    
    func diselect() {
        IGGlobal.shouldMultiSelect = false
        self.showMultiSelectUI(state: false)
    }
    
    func close() {
        self.dismiss(animated: true, completion: {
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
            self.callCallBackApi(token: SMUserManager.payToken!)
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
    
    var MoneyTransactionModal : SMMoneyTransactionOptions!
    var MoneyInputModal : SMSingleAmountInputView!
    var CardToCardModal : SMTwoInputView!
    var forwardModal : IGMultiForwardModal!
    var MoneyTransactionModalIsActive = false
    var MoneyInputModalIsActive = false
    var MultiShareModalIsActive = false
    var CardToCardModalIsActive = false
    var isBoth = false
    
    var blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    var blurEffectView = UIVisualEffectView()
    var dissmissViewBG = UIView()
    
    public var deepLinkMessageId: Int64?
    
    var dismissBtn : UIButton!
    @IBOutlet weak var pinnedMessageView: UIView!
    @IBOutlet weak var txtPinnedMessage: UILabel!
    @IBOutlet weak var collectionView: IGMessageCollectionView!
    @IBOutlet weak var inputBarContainerView: UIView!
    @IBOutlet weak var inputTextView: GrowingTextView!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var inputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarHeightContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarView: UIView!
    @IBOutlet weak var inputBarBackgroundView: UIView!
    @IBOutlet weak var inputBarLeftView: UIView!
    @IBOutlet weak var inputBarRightiew: UIView!
    @IBOutlet weak var inputBarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var inputBarRecordButton: UIButton!
    @IBOutlet weak var btnScrollToBottom: UIButton!
    @IBOutlet weak var inputBarSendButton: UIButton!
    @IBOutlet weak var inputBarShareButton: UIButton!
    @IBOutlet weak var inputBarDeleteButton: UIButton!
    @IBOutlet weak var inputBarForwardButton: UIButton!
    @IBOutlet weak var inputBarMoneyTransferButton: UIButton!
    @IBOutlet weak var btnCancelReplyOrForward: UIButton!
    @IBOutlet weak var btnDeleteSelectedAttachment: UIButton!
    @IBOutlet weak var btnClosePin: UIButton!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var lblSelectedMessages: UILabel!
    @IBOutlet weak var inputBarRecordTimeLabel: UILabel!
    @IBOutlet weak var inputBarRecordView: UIView!
    @IBOutlet weak var inputBarRecodingBlinkingView: UIView!
    @IBOutlet weak var inputBarRecordRightView: UIView!
    @IBOutlet weak var inputBarRecordViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var RightBarConstraints: NSLayoutConstraint!
    @IBOutlet weak var inputBarAttachmentView: UIView!
    @IBOutlet weak var inputBarAttachmentViewThumnailImageView: UIImageView!
    @IBOutlet weak var inputBarAttachmentViewFileNameLabel: UILabel!
    @IBOutlet weak var inputBarAttachmentViewFileSizeLabel: UILabel!
    @IBOutlet weak var inputBarAttachmentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarOriginalMessageView: UIView!
    @IBOutlet weak var inputBarOriginalMessageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputBarOriginalMessageViewSenderNameLabel: UILabel!
    @IBOutlet weak var inputBarOriginalMessageViewBodyTextLabel: UILabel!
    @IBOutlet weak var scrollToBottomContainerView: UIView!
    @IBOutlet weak var scrollToBottomContainerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatBackground: UIImageView!
    @IBOutlet weak var txtSticker: UILabel!
    @IBOutlet weak var floatingDateView: UIView!
    @IBOutlet weak var txtFloatingDate: UILabel!
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
    
    
    
    //var messages = [IGRoomMessage]()
    let sortProperties = [SortDescriptor(keyPath: "creationTime", ascending: false),
                          SortDescriptor(keyPath: "id", ascending: false)]
    let sortPropertiesForMedia = [SortDescriptor(keyPath: "creationTime", ascending: true),
                                  SortDescriptor(keyPath: "id", ascending: true)]
    private var messages: [IGRoomMessage]? = []
    static var messageIdsStatic: [Int64:[Int64]] = [:]
    var messagesWithMedia = try! Realm().objects(IGRoomMessage.self)
    
    var messagesWithForwardedMedia = try! Realm().objects(IGRoomMessage.self)
    var notificationToken: NotificationToken?
    
    var logMessageCellIdentifer = IGMessageLogCollectionViewCell.cellReuseIdentifier()
    var room : IGRoom?
    var forwardedMessageArray : [IGRoomMessage] = []
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
    static var highlightMessageId: Int64 = 0 // highlight message and show fast return to message icon
    static var highlightWithoutFastReturn: Int64 = 0 // highlight message after click on fast return to message icon
    static var returnToMessage: IGRoomMessage? // after click on reply header, save clicked message for fast return to message position again
    
    private var cellSizeLimit: CellSizeLimit!
    
    fileprivate var typingStatusExpiryTimer = Timer() //use this to send cancel for typing status
    internal static var additionalObserver: AdditionalObserver!
    internal static var messageViewControllerObserver: MessageViewControllerObserver!
    internal static var messageOnChatReceiveObserver: MessageOnChatReceiveObserver!
    
    private var saveDate: [String] = []
    private var firstSetDate = true
    private var messageLoader: IGMessageLoader!
    private var currentRoomId: Int64!
    private var allowManageForward = true
    
    func onMessageViewControllerDetection() -> UIViewController {
        return self
    }
    
    func onNavigationControllerDetection() -> UINavigationController {
        return self.navigationController!
    }
    
    func showMultiSelectUI(state : Bool!,isForward:Bool? = nil,isDelete:Bool?=nil) {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.setNavigationBarForRoom(room!)
        
        
        if state {
            if isForward! {
                UIView.transition(with: self.holderTextBox, duration: ANIMATE_TIME, options: .transitionCrossDissolve, animations: {
                    self.holderMultiSelect.isHidden = !isForward!
                    self.holderTextBox.isHidden = isForward!
                    
                    self.btnMoney.isHidden = true
                    self.btnMic.isHidden = true
                    self.btnSend.isHidden = true
                    self.btnShare.isHidden = true

                    //rightbar btns
                    self.btnShare.isHidden = true
                    self.btnTrash.isHidden = true
                    self.btnAttachmentNew.isHidden = true
                    
                    
                    self.reloadCollection()
                    self.btnForward.isHidden = !isForward!

                    
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
                
                UIView.transition(with: self.inputTextView, duration: ANIMATE_TIME, options: .transitionCrossDissolve, animations: {
                    self.holderMultiSelect.isHidden = !isDelete!
                    self.holderTextBox.isHidden = isDelete!
                    
                    self.btnMoney.isHidden = true
                    self.btnMic.isHidden = true
                    self.btnSend.isHidden = true
                    self.btnShare.isHidden = true

                    //rightbar btns
                    self.btnShare.isHidden = true
                    self.btnForward.isHidden = true
                    self.btnAttachmentNew.isHidden = true
                    
                    
                    self.reloadCollection()
                    self.btnTrash.isHidden = !isDelete!

                    
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
            UIView.transition(with: self.inputTextView, duration: ANIMATE_TIME, options: .transitionCrossDissolve, animations: {
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
                
                
                self.reloadCollection()
                self.btnTrash.isHidden = true

                
                
            }, completion: { (completed) in
            })
        }
        
        if self.selectedMessages.count > 0 {
            lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + " " + "SELECTED".MessageViewlocalizedNew
            inputBarDeleteButton.setTitleColor(UIColor.iGapDarkGray(), for: .normal)
            inputBarDeleteButton.isEnabled = true
            
            inputBarForwardButton.setTitleColor(UIColor.iGapDarkGray(), for: .normal)
            inputBarForwardButton.isEnabled = true
        }
        else {
            lblSelectedMessages.text = ""
            btnTrash.setTitleColor(UIColor.iGapGray(), for: .normal)
            btnTrash.isEnabled = false
            
            btnForward.setTitleColor(UIColor.iGapGray(), for: .normal)
            btnForward.isEnabled = false
        }
    }
    
    //MARK: - Initilizers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    
        
        ///newUITextMessage
        initViewNewChatView()
        initNotificationsNewChatView()
        initFontsNewChatView()
        initAlignmentsNewChatView()
        initChangeLanguegeNewChatView()
        initDelegatesNewChatView()
        
        
        
        
        
        
        
        
        
        
        
        
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor(named: themeColor.textFieldPlaceHolderColor.rawValue) ?? #colorLiteral(red: 0.6784313725, green: 0.6784313725, blue: 0.6784313725, alpha: 1),
            NSAttributedString.Key.font : UIFont.igFont(ofSize: 13) // Note the !
        ]
        self.removeHideKeyboardWhenTappedAround()
        initChangeLanguegeNewChatView()
        
        inputBarMoneyTransferButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 19)
        
        self.removeHideKeyboardWhenTappedAround()

        if !(IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
            RightBarConstraints.constant = 38
            btnMoney.isHidden = true
        } else {
            if isBotRoom(){
                btnMoney.isHidden = true
                btnSticker.isHidden = true
                self.btnStickerWidthConstraint.constant = 0.0

            }
            else {
                btnMoney.isHidden = false
                btnSticker.isHidden = false
                self.btnStickerWidthConstraint.constant = 25.0

            }
        }
        tmpUserID  =  self.room?.chatRoom?.peer?.id
        switch self.room!.type {
            
        case .chat:
            if !(IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
                self.btnMoney.isHidden = true
            }
            else {
                if !(IGAppManager.sharedManager.mplActive()) && (IGAppManager.sharedManager.walletActive()) {
                    
                }
                else if (IGAppManager.sharedManager.mplActive()) && !(IGAppManager.sharedManager.walletActive()) {
                    if isBotRoom(){
                        self.btnMoney.isHidden = true
                        self.RightBarConstraints.constant = 38
                        self.isCardToCardRequestEnable = false
                    }
                    else {
                        self.btnMoney.isHidden = false
                        self.RightBarConstraints.constant = 70
                        self.isCardToCardRequestEnable = true
                        self.manageCardToCardInputBar()
                    }
                }
                else {
                    if isBotRoom(){
                        messageCollectionBottomCollectionConstrains.constant = 50

                        self.btnMoney.isHidden = true
                        self.RightBarConstraints.constant = 38
                    }
                    else {
                        messageCollectionBottomCollectionConstrains.constant = 0.0
                        self.btnMoney.isHidden = false
                        self.RightBarConstraints.constant = 70
                    }
                }
            }
            
        case .channel:
            messageCollectionBottomCollectionConstrains.constant = 50
            self.btnMoney.isHidden = true
            self.RightBarConstraints.constant = 38

        default:
            self.btnMoney.isHidden = true
            self.RightBarConstraints.constant = 38
            
        }
        IGMessageViewController.messageIdsStatic[(self.room?.id)!] = []
        txtFloatingDate.font = UIFont.igFont(ofSize: 15)
        
        removeButtonsUnderline(buttons: [btnMic, btnScrollToBottom, inputBarSendButton, btnMoney, btnCancelReplyOrForward, btnDeleteSelectedAttachment, btnClosePin, btnAttachment])
        
        IGAppManager.sharedManager.connectionStatus.asObservable().subscribe(onNext: { (connectionStatus) in
            DispatchQueue.main.async {
                self.updateConnectionStatus(connectionStatus)
                
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        /*
         let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.tapOnMainView))
         mainView.addGestureRecognizer(gesture)
         */
        self.addNotificationObserverForTapOnStatusBar()
        var canBecomeFirstResponder: Bool { return true }
        let navigationController = self.navigationController as! IGNavigationController
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.delegate = self
        navigationItem.navigationController = navigationController
        navigationItem.setNavigationBarForRoom(room!)
        navigationController.interactivePopGestureRecognizer?.delegate = self
        //        self.navigationController?.interactivePopGestureRecognizer?.addTarget(self, action:#selector(self.handlePopGesture))
        navigationItem.rightViewContainer?.addAction {
            if self.room?.type == .chat {
                self.selectedUserToSeeTheirInfo = (self.room?.chatRoom?.peer)!
                self.openUserProfile()
            }
            if self.room?.type == .channel {
                self.selectedChannelToSeeTheirInfo = self.room?.channelRoom
                //self.performSegue(withIdentifier: "showChannelinfo", sender: self)
                
                let profile = IGProfileChannelViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                profile.selectedChannel = self.selectedChannelToSeeTheirInfo
                profile.room = self.room
                profile.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(profile, animated: true)
            }
            if self.room?.type == .group {
                
                let profile = IGProfileGroupViewController.instantiateFromAppStroryboard(appStoryboard: .Profile)
                profile.selectedGroup = self.room?.groupRoom
                profile.room = self.room
                profile.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(profile, animated: true)
            }
            
        }
        navigationItem.centerViewContainer?.addAction {
            if self.room?.type == .chat {
                self.selectedUserToSeeTheirInfo = (self.room?.chatRoom?.peer)!
                self.openUserProfile()
            } else {
                
            }
        }
        //        if customizeBackItem {
        //            navigationItem.backViewContainer?.addAction {
        //                // if call page is enable set "isFirstEnterToApp" true for open "IGRecentsTableViewController" automatically
        //                AppDelegate.isFirstEnterToApp = true
        //                self.performSegue(withIdentifier: "showRoomList", sender: self)
        //            }
        //        }
        
        if room!.isReadOnly {
            if room!.isParticipant == false {
                mainHolder.isHidden = true
                joinButton.isHidden = false
            } else {
                mainHolder.isHidden = true
                collectionViewTopInsetOffset = -54.0 + 8.0
            }
        }
        
        if isBotRoom() {
            btnSticker.isHidden = true
            if IGHelperDoctoriGap.isDoctoriGapRoom(room: room!) {
                self.getFavoriteMenu()
            }
            
            let predicate = NSPredicate(format: "roomId = %lld AND (id >= %lld OR statusRaw == %d OR statusRaw == %d) AND isDeleted == false AND id != %lld" , self.room!.id, lastId ,0 ,1 ,0)
            do {
                let messagesCount = try! Realm().objects(IGRoomMessage.self).filter(predicate).count
                if messagesCount == 0 {
                    mainHolder.isHidden = true
                    joinButton.isHidden = false
                    joinButton.setTitle("START".MessageViewlocalizedNew, for: UIControl.State.normal)
                    joinButton.layer.cornerRadius = 5
                    joinButton.layer.masksToBounds = false
                    joinButton.layer.shadowColor = UIColor.black.cgColor
                    joinButton.layer.shadowOffset = CGSize(width: 0, height: 0)
                    joinButton.layer.shadowRadius = 4.0
                    joinButton.layer.shadowOpacity = 0.15
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.manageKeyboard(firstEnter: true)
                    }
                }
                
            } catch _ as NSError {
                print("RLM EXEPTION ERR HAPPENDED IN VIEW DID LOAD FOR ISBOT ROOM:",String(describing: self))
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
        
        self.collectionView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        self.collectionView.delaysContentTouches = false
        self.collectionView.keyboardDismissMode = .none
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let bgColor = UIColor(named: themeColor.modalViewBackgroundColor.rawValue)
        
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
        scrollToBottomContainerView.backgroundColor = UIColor(named: themeColor.modalViewBackgroundColor.rawValue)
        scrollToBottomContainerView.layer.borderWidth = 0.2
        scrollToBottomContainerView.layer.borderColor = #colorLiteral(red: 0.4477736669, green: 0.4477736669, blue: 0.4477736669, alpha: 1)
        scrollToBottomContainerView.isHidden = true
        
        floatingDateView.layer.cornerRadius = 12.0
        floatingDateView.alpha = 0.0
        txtFloatingDate.alpha = 0.0
        
        txtPinnedMessage.lineBreakMode = .byTruncatingTail
        txtPinnedMessage.numberOfLines = 1
        self.setCollectionViewInset()
        
        notification(register: true)
        let tapOnMessageTextView = UITapGestureRecognizer(target: self, action: #selector(didTapOnInputTextView))
        messageTextView.addGestureRecognizer(tapOnMessageTextView)
        messageTextView.isUserInteractionEnabled = true
        
        if let messageId = self.deepLinkMessageId {
            // need to make 'IGMessageLoader' for first time
            if messageLoader == nil {
                messageLoader = IGMessageLoader(room: self.room!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.goToPosition(messageId: messageId)
            }
        } else {
            startLoadMessage()
        }
        initiconFonts()
        eventBusInitialiser()
        holderMusicPlayer.backgroundColor = .clear
        print("CHECK TOPBAR PLAYER :",IGGlobal.shouldShowTopBarPlayer)
        if IGGlobal.shouldShowTopBarPlayer {
            let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
            var defaultValue : CGFloat = 20

            if !(pinnedMessageView.isHidden) {
                defaultValue = 112
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            } else {
                defaultValue = 60
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }

            floatingDateTopConstraints.constant = defaultValue
            self.createTopMusicPlayer()

        }
        print("CHECK TOPBAR PLAYER STATE5:",self.holderMusicPlayer.subviews)

    }
        private func stopButtonPlayForRow() {
                self.collectionView.reloadData()
        }

    private func eventBusInitialiser() {
        SwiftEventBus.onMainThread(self, name: EventBusManager.stopLastButtonState) { result in
              self.stopButtonPlayForRow()
              
          }

        SwiftEventBus.onMainThread(self, name: EventBusManager.hideTopMusicPlayer) { result in
            self.hideMusicTopPlayerWithAnimation()
        }
        SwiftEventBus.onMainThread(self, name: EventBusManager.showTopMusicPlayer) { result in
            self.musicFile = result?.object as! MusicFile
            print("CHECK TOPBAR PLAYER CONTENTS:",self.musicFile.songTime,self.musicFile.songName,self.musicFile.singerName)

            IGGlobal.topBarSongTime = self.musicFile.songTime
            IGGlobal.topBarSongName = self.musicFile.songName
            IGGlobal.topBarSongSinger = self.musicFile.singerName
            self.showMusicTopPlayerWithAnimation()
//            SwiftEventBus.post(EventBusManager.updateLabelsData,sender: self.musicFile)

        }
        SwiftEventBus.onMainThread(self, name: EventBusManager.updateLabelsData) { result in
            //            print(result?.object as! Bool)
            self.updateLabelsData(singerName: IGGlobal.topBarSongSinger,songName: IGGlobal.topBarSongName)
        }
  


    }

    @objc func updateLabelsData(singerName: String!,songName: String!) {
        if IGGlobal.shouldShowTopBarPlayer {
            let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
            var defaultValue : CGFloat = 20

            if !(pinnedMessageView.isHidden) {
                defaultValue = 112
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            } else {
                defaultValue = 60
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }

            floatingDateTopConstraints.constant = defaultValue
            self.createTopMusicPlayer()
            

        }
    }
    private func hideMusicTopPlayerWithAnimation() {
        IGGlobal.shouldShowTopBarPlayer = false
        holderMusicPlayerHeightConstraint.constant = 0
        IGPlayer.shared.stopMedia()
        let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
        var defaultValue : CGFloat = 20

        if !(pinnedMessageView.isHidden) {
            defaultValue = 70
            self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
        } else {
            defaultValue = 20
            self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
        }
        floatingDateTopConstraints.constant = defaultValue

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

    }
    private func showMusicTopPlayerWithAnimation() {
        IGGlobal.shouldShowTopBarPlayer = true
        holderMusicPlayerHeightConstraint.constant = 40.0
        let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
        var defaultValue : CGFloat = 20

        if !(pinnedMessageView.isHidden) {
            defaultValue = 112
            self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
        } else {
            defaultValue = 60
            self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
        }

        floatingDateTopConstraints.constant = defaultValue
        UIView.animate(withDuration: 0.0) {
            self.view.layoutIfNeeded()
        }
        self.createTopMusicPlayer()
        print("CHECK TOPBAR PLAYER STATE6:",self.holderMusicPlayer.subviews)


    }
    
    private func createTopMusicPlayer() {
//        if !(IGGlobal.shouldShowTopBarPlayer) {
     
        if IGGlobal.topBarSongTime != 0 { // check if could be able to fetch time of song

            if IGGlobal.isAlreadyOpen == false {

            holderMusicPlayerHeightConstraint.constant = 40.0
            print("CHECK HOLDER SUBVIEWS1:",holderMusicPlayer.subviews.count)
            
            if holderMusicPlayer.subviews.count > 0 {
                holderMusicPlayer.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
                print("CHECK HOLDER SUBVIEWS2:",holderMusicPlayer.subviews.count)
            }
                addMusicPlayerToHolder() // add musicPlayer to holder
            }
        } else {
//            IGHelperAlert.shared.showCustomAlert(view: self, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: true, showCancelButton: true, message: "ERROR IN FETCHING SONG TIME", doneText: "Done", cancelText: "Cancel")
        }
        print("CHECK TOPBAR PLAYER STATE4.6:",self.holderMusicPlayer.subviews)
        if self.holderMusicPlayer.subviews.count == 0 {
            addMusicPlayerToHolder()
        } else {
            addMusicPlayerToHolder()
        }
        print("CHECK TOPBAR PLAYER STATE4.7:",self.holderMusicPlayer.subviews)
        IGHelperMusicPlayer.shared.room = self.room // pass room obj to helper music layer in order to be used in showing audio list of room at the bottom music player
    }
    private func addMusicPlayerToHolder() {
        if holderMusicPlayer.subviews.count > 0 {
            holderMusicPlayer.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
            print("CHECK HOLDER SUBVIEWS2:",holderMusicPlayer.subviews.count)
        }

            let view = (IGHelperMusicPlayer.shared.showTopMusicPlayer(view: self, songTime: IGGlobal.topBarSongTime, singerName: IGGlobal.topBarSongSinger, songName: IGGlobal.topBarSongName))
            holderMusicPlayer.addSubview(view)
            print("CHECK HOLDER CONTENT2:",IGGlobal.topBarSongName)
            print("CHECK HOLDER CONTENT2:",IGGlobal.topBarSongSinger)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.topAnchor.constraint(equalTo: holderMusicPlayer.topAnchor, constant: 0).isActive = true
            view.bottomAnchor.constraint(equalTo: holderMusicPlayer.bottomAnchor, constant: 0).isActive = true
            view.leftAnchor.constraint(equalTo: holderMusicPlayer.leftAnchor, constant: 0).isActive = true
            view.rightAnchor.constraint(equalTo: holderMusicPlayer.rightAnchor, constant: 0).isActive = true
            IGGlobal.isAlreadyOpen = !IGGlobal.isAlreadyOpen


    }
    private func initiconFonts() {
        txtSticker.font = UIFont.iGapFonticon(ofSize: 25)
        btnAttachment.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        inputBarDeleteButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        inputBarForwardButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        inputBarMoneyTransferButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        inputBarRecordButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        inputBarSendButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        inputBarShareButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 25)
        
        txtSticker.text = ""
        inputBarShareButton.setTitle("", for: .normal)
        inputBarSendButton.setTitle("", for: .normal)
        inputBarRecordButton.setTitle("", for: .normal)
        inputBarMoneyTransferButton.setTitle("", for: .normal)
        btnAttachment.setTitle("", for: .normal)
        inputBarDeleteButton.setTitle("", for: .normal)
        inputBarForwardButton.setTitle("", for: .normal)
    }
    /* reason of "manageForward" bool
     * sometimes startLoadMessage call from another state so will be send forwarded message twice
     * currentlly for manage this state just should be manage forward from one state
     */
    private func startLoadMessage(){
        if messageLoader == nil {
            messageLoader = IGMessageLoader(room: self.room!)
        }

        let hasUnread = messageLoader.hasUnread()
        let hasSaveState = messageLoader.hasSavedState()
        if hasUnread || hasSaveState {
            self.collectionView.fadeOut(0)
        }
        
        messageLoader.getMessages { (messages, direction) in
            self.addChatItem(realmRoomMessages: messages, direction: direction, scrollToBottom: false)
            if hasUnread || hasSaveState {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.collectionView.fadeIn(0.1)
                }
            }
            if self.allowManageForward {
                self.allowManageForward = false
                self.manageForward()
            }
        }
    }
    
    private func manageForward(index: Int = 0){
        if self.forwardedMessageArray.count > 0 && self.forwardedMessageArray.count > index {
            let delay: Double = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                var indexOfMessage = index
                let message = self.forwardedMessageArray[indexOfMessage]
                IGMessageSender.defaultSender.sendSingleForward(message: message, to: self.room!, success: {
                    indexOfMessage = indexOfMessage + 1
                    self.manageForward(index: indexOfMessage)
                }, error: {
                    indexOfMessage = indexOfMessage + 1
                    self.manageForward(index: indexOfMessage)
                })
                self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
            }
        }
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
            if let observer = IGStickerViewController.stickerToolbarObserver {
                
                switch sender.tag {
                case IGStickerToolbar.shared.STICKER_ADD:
                    if let observer = IGStickerViewController.stickerCurrentGroupIdObserver {
                        IGStickerViewController.currentStickerGroupId = observer.fetchCurrentStickerGroupId()
                    }
                    IGTabBarStickerController.openStickerCategories()
                    break
                    
                case IGStickerToolbar.shared.STICKER_SETTING:
                    disableStickerView(delay: 0.0)
                    break
                    
                default:
                    observer.onToolbarClick(index: sender.tag)
                    break
                }
            }
        }
    }
    
    func setupNotifications() {
        unsetNotifications()
    }
    
    func unsetNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if MoneyInputModalIsActive {
            if let MoneyInput = MoneyInputModal {
                self.view.addSubview(MoneyInput)
                UIView.animate(withDuration: 0.3) {
                    //                    self.messageTextView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
                    
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
    }
    
    
    func onStickerTap(stickerItem: IGRealmStickerItem) {
        
        if let attachment = IGAttachmentManager.sharedManager.getFileInfo(token: stickerItem.token!) {
            let message = IGRoomMessage(body: stickerItem.name!)
            message.type = .sticker
            message.roomId = self.room!.id
            message.attachment = attachment
            message.additional = IGRealmAdditional(additionalData: IGHelperJson.convertRealmToJson(stickerItem: stickerItem)!, additionalType: AdditionalType.STICKER.rawValue)
            IGAttachmentManager.sharedManager.add(attachment: attachment)
            
            let detachedMessage = message.detach()
            IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
            message.repliedTo = self.selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
            IGMessageSender.defaultSender.sendSticker(message: message, to: self.room!)
            
            self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
            
            self.sendMessageState(enable: false)
            self.messageTextView.text = ""
            self.currentAttachment = nil
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = nil
            self.setInputBarHeight()
        } else {
            IGAttachmentManager.sharedManager.getStickerFileInfo(token: stickerItem.token!, completion: { (attachment) -> Void in })
        }
    }
    
    @objc func keyboardWillAppear() {
        //Do something here
    }
    
    @objc func keyboardWillDisappear() {
        disableStickerView(delay: 0.4)
        if isBotRoom() {
            self.reloadCollection()
        }
    }
    
    @objc func tapOnMainView(sender : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    private func getFavoriteMenu(){
        IGClientGetFavoriteMenuRequest.Generator.generate().success ({ (responseProtoMessage) in
            if let favoriteResponse = responseProtoMessage as? IGPClientGetFavoriteMenuResponse {
                DispatchQueue.main.async {
                    let results = favoriteResponse.igpFavorites
                    if results.count == 0 {
                        return
                    }
                    
                    if self.room!.isReadOnly {
                        self.collectionViewTopInsetOffset = 0
                    } else {
                        self.collectionViewTopInsetOffset = CGFloat(self.DOCTOR_BOT_HEIGHT)
                    }
                    
                    self.apiStructArray = results
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                        self.doctorBotView(results: results)
                    }
                    
                    self.setCollectionViewInset(withDuration: 0.9)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.collectionView.contentInset.top) , animated: true)
                    }
                }
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getFavoriteMenu()
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
    }
    
    private func makeDoctorBotButtonView(parent: UIView, result: IGPFavorite){
        let text : String = result.igpName
        
        
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
        let value : String! = detectBotValue(name: sender.titleLabel?.text!)
        
        if value.starts(with: "$financial") {
            IGHelperFinancial.getInstance(viewController: self).manageFinancialServiceChoose()
        } else if value.starts(with: "@") {
            if let username = IGRoom.fetchUsername(room: room!) { // if username is for current room don't open this room again
                if username == value.dropFirst() {
                    return
                }
            }
            IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: self, username: value)
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
    
    private func makeKeyboardButton(){
        
        if btnChangeKeyboard != nil {
            return
        }
        
        btnChangeKeyboard = UIButton()
        btnChangeKeyboard.isHidden = false
        btnChangeKeyboard.addTarget(self, action: #selector(onKeyboardChangeClick), for: .touchUpInside)
        btnChangeKeyboard.titleLabel?.font = UIFont.iGapFonticon(ofSize: 18.0)
        btnChangeKeyboard.setTitleColor(UIColor.iGapColor(), for: UIControl.State.normal)
        btnChangeKeyboard.backgroundColor = inputBarLeftView.backgroundColor
        btnChangeKeyboard.layer.masksToBounds = false
        btnChangeKeyboard.layer.cornerRadius = 5.0
        self.view.addSubview(btnChangeKeyboard)
        
        btnChangeKeyboard.snp.makeConstraints { (make) in
            make.right.equalTo(inputBarRightiew.snp.left)
            make.centerY.equalTo(inputBarRightiew.snp.centerY)
            make.width.equalTo(33)
            make.height.equalTo(33)
        }
        
        messageTextView.snp.makeConstraints { (make) in
            make.right.equalTo(btnChangeKeyboard.snp.left)
            make.left.equalTo(inputBarLeftView.snp.right)
        }
    }
    
    private func removeKeyboardButton(){
        
        if btnChangeKeyboard == nil {
            return
        }
        
        btnChangeKeyboard.removeFromSuperview()
        btnChangeKeyboard.isHidden = true
        btnChangeKeyboard = nil
        messageTextView.snp.makeConstraints { (make) in
            make.right.equalTo(inputBarRightiew.snp.left)
            make.left.equalTo(inputBarLeftView.snp.right)
        }
    }
    
    private func manageKeyboard(firstEnter: Bool = false){
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
                    let additionalData = getAdditional(roomMessage: latestMessage)
                    
                    if !self.messageTextView.isFirstResponder {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.reloadCollection()
                        }
                    }
                    
                    if additionalData != nil {
                        self.makeKeyboardButton()
                        isCustomKeyboard = true
                        btnChangeKeyboard.setTitle(KEYBOARD_MAIN_ICON, for: UIControl.State.normal)
                        latestKeyboardAdditionalView = IGHelperBot.shared.makeBotView(additionalArrayMain: additionalData!, isKeyboard: true)
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
    
    /* overrided method */
    func onAdditionalSendMessage(structAdditional: IGStructAdditionalButton) {
        
        let message = IGRoomMessage(body: structAdditional.label)
        message.type = .text
        message.additional = IGRealmAdditional(additionalData: structAdditional.json, additionalType: 3)
        let detachedMessage = message.detach()
        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
        IGMessageSender.defaultSender.send(message: message, to: room!)
        
        self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
    }
    
    func onAdditionalLinkClick(structAdditional: IGStructAdditionalButton) {
        openWebView(url: structAdditional.value)
    }
    
    func onAdditionalRequestPhone(structAdditional :IGStructAdditionalButton){
        manageRequestPhone()
    }
    
    func onAdditionalRequestLocation(structAdditional :IGStructAdditionalButton){
        openLocation()
    }
    
    func onBotClick(){
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.collectionView.contentInset.top) , animated: false)
    }
    
    func onAdditionalRequestPayDirect(structAdditional :IGStructAdditionalButton){
        tmpUserID = self.room?.chatRoom?.peer?.id
        IGHelperAlert.shared.showAlert(data: structAdditional)
    }
    
    
    private func manageRequestPhone(){
        self.view.endEditing(true)
        if let roomTitle = self.room?.title {
            let alert = UIAlertController(title: nil, message: "there is a request to access your phone number from" + " \(roomTitle)" + " . do you allow?", preferredStyle: IGGlobal.detectAlertStyle())
            
            let sendPhone = UIAlertAction(title: "SEND_PHOTO".MessageViewlocalizedNew, style: .default, handler: { (action) in
                if let userId = IGAppManager.sharedManager.userID(), let userInfo = IGRegisteredUser.getUserInfo(id: userId) {
                    self.messageTextView.text = String(describing: userInfo.phone)
                    self.didTapOnSendButton(self.btnSend)
                }
            })
            
            let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: nil)
            
            alert.addAction(sendPhone)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
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
                chatBackground.image = UIImage(named: "iGap-Chat-BG-V")
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
    
    func findAllMessages(isHistory: Bool = false) -> Results<IGRoomMessage>!{
        
        if lastId == 0 {
            
            do {
                
                let realm = try Realm()
                if !(realm.isInWriteTransaction) {
                    try realm.write {
                        let predicate = NSPredicate(format: "roomId = %lld AND isDeleted == false AND id != %lld", self.room!.id, 0)
                        allMessages = realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
                        
                    }
                }
                
                let messageCount = allMessages.count
                if messageCount == 0 {
                    return allMessages
                }
                
                firstId = allMessages.toArray()[0].id
                
                if messageCount <= getMessageLimit {
                    hasLocal = false
                    scrollToTopLimit = 500
                    lastId = allMessages.toArray()[allMessages.count-1].id
                } else {
                    lastId = allMessages.toArray()[getMessageLimit].id
                }
                
            } catch _ as NSError {
                print("RLM EXEPTION ERR HAPPENDED IN findAllMessages:",String(describing: self))
            }
            
        } else {
            page += 1
            
            if page > 1 {
                getMessageLimit = 100
            }
            
            let messageLimit = page * getMessageLimit
            let messageCount = allMessages.count
            
            if messageCount <= messageLimit {
                hasLocal = false
                scrollToTopLimit = 500
                lastId = allMessages.toArray()[allMessages.count-1].id
            } else {
                lastId = allMessages.toArray()[messageLimit].id
            }
        }
        
        let predicate = NSPredicate(format: "roomId = %lld AND (id >= %lld OR statusRaw == %d OR statusRaw == %d) AND isDeleted == false AND id != %lld" , self.room!.id, lastId ,0 ,1 ,0)
        var tmpMessages:Results<IGRoomMessage>!
        
        do {
            let realm = try Realm()
            tmpMessages = realm.objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties)
            
        } catch _ as NSError {
            print("RLM EXEPTION ERR HAPPENDED IN findAllMessagesII:",String(describing: self))
        }
        DispatchQueue.main.async {
            self.reloadCollection()
        }
        
        return tmpMessages
    }
    
    /* reset values for get history from first */
    func resetGetHistoryValues(){
        lastId = 0
        page = 0
        getMessageLimit = 50
        scrollToTopLimit = 20
        hasLocal = true
    }
    
    
    /* delete all local messages before first message that have shouldFetchBefore==true */
    func deleteUnusedLocalMessage(){
        let predicate = NSPredicate(format: "roomId = %lld AND shouldFetchBefore == true", self.room!.id)
        let message = try! Realm().objects(IGRoomMessage.self).filter(predicate).sorted(by: sortProperties).last
        
        var deleteId:Int64 = 0
        if let id = message?.id {
            deleteId = id
        }
        
        let predicateDelete = NSPredicate(format: "roomId = %lld AND id <= %lld", self.room!.id , deleteId)
        let messageDelete = try! Realm().objects(IGRoomMessage.self).filter(predicateDelete).sorted(by: sortProperties)
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(messageDelete)
        }
    }
    
    private func getUserInfo(){
        guard !(room?.isInvalidated)!, let userId = self.room?.chatRoom?.peer?.id else {
            return
        }
        
        IGUserInfoRequest.Generator.generate(userID: userId).success({ (protoResponse) in
            if let userInfoResponse = protoResponse as? IGPUserInfoResponse {
                IGUserInfoRequest.Handler.interpret(response: userInfoResponse)
            }
        }).error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                // call "getUserInfo" in main thread for avoid from "Realm Accessed from incorrect thread"
                DispatchQueue.main.async {
                    self.getUserInfo()
                }
            default:
                break
            }
        }).send()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IGGlobal.isInChatPage = true
        IGMessageViewController.messageViewControllerObserver = self
        IGMessageViewController.additionalObserver = self
        IGMessageViewController.messageOnChatReceiveObserver = self
        self.currentRoomId = self.room?.id
        CellSizeLimit.updateValues(roomId: (self.room?.id)!)
        setupNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        getUserInfo()
        setBackground()
        
        if let forwardMsg = IGMessageViewController.selectedMessageToForwardToThisRoom {
            self.forwardOrReplyMessage(forwardMsg, isReply: false)
        }
        
        if let draft = self.room!.draft {
            if draft.message != "" || draft.replyTo != -1 {
                messageTextView.text = draft.message
                //                messageTextView.placeholder = "MESSAGE".MessageViewlocalizedNew
                initChangeLanguegeNewChatView()
                lblPlaceHolder.isHidden = true
                if draft.replyTo != -1 {
                    let predicate = NSPredicate(format: "id = %lld AND roomId = %lld", draft.replyTo, self.room!.id)
                    if let replyToMessage = try! Realm().objects(IGRoomMessage.self).filter(predicate).first {
                        forwardOrReplyMessage(replyToMessage)
                    }
                }
                setSendAndRecordButtonStates()
            }
        }
        notification(register: true)
        inputTextViewHeightConstraint.constant = 34.0
        if IGGlobal.shouldShowTopBarPlayer {
            let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
            var defaultValue : CGFloat = 20

            if !(pinnedMessageView.isHidden) {
                defaultValue = 112
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            } else {
                defaultValue = 60
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }

            floatingDateTopConstraints.constant = defaultValue
            self.createTopMusicPlayer()

        }
        print("CHECK TOPBAR PLAYER STATE5:",self.holderMusicPlayer.subviews)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        txtSticker.font = UIFont.iGapFonticon(ofSize: 19)
        inputBarMoneyTransferButton.titleLabel?.font = UIFont.iGapFonticon(ofSize: 19)
        
        if self.room!.isInvalidated {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        messageTextView.setContentOffset(.zero, animated: true)
        messageTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        
        if #available(iOS 10.0, *) {
            IGStickerViewController.stickerTapListener = self
        }
        IGRecentsTableViewController.visibleChat[(room?.id)!] = true
        IGAppManager.sharedManager.currentMessagesNotificationToekn = self.notificationToken
        let navigationItem = self.navigationItem as! IGNavigationItem
        if let roomVariable = IGRoomManager.shared.varible(for: room!) {
            roomVariable.asObservable().subscribe({ (event) in
                if event.element == self.room! {
                    DispatchQueue.main.async {
                        navigationItem.updateNavigationBarForRoom(event.element!)
                        
                    }
                }
            }).disposed(by: disposeBag)
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) in }
        
        setMessagesRead()
        manageStickerPosition()
        IGHelperGetMessageState.shared.clearMessageViews()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IGGlobal.isInChatPage = false
        
        currentRoomId = 0
        currentPageName = ""
        IGGlobal.shouldMultiSelect = false
        unsetNotifications()
        saveMessagePosition()
        
        if !holderReplyBar.isHidden { // maybe has forward
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
        }
        notificationToken?.invalidate()
        self.view.endEditing(true)
        IGRecentsTableViewController.visibleChat[(room?.id)!] = false
        IGAppManager.sharedManager.currentMessagesNotificationToekn = nil
        self.sendCancelTyping()
        self.sendCancelRecoringVoice()
        if let room = self.room, !room.isInvalidated {
            room.saveDraft(messageTextView.text, replyToMessage: selectedMessageToReply)
            IGFactory.shared.markAllMessagesAsRead(roomId: room.id)
            if openChatFromLink { // TODO - also check if user before joined to this room don't send this request
                sendUnsubscribForRoom(roomId: room.id)
                IGFactory.shared.updateRoomParticipant(roomId: room.id, isParticipant: false)
            }
        }
        //        if self.selectedMessageToReply != nil {
        //            self.selectedMessageToReply = nil
        //        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        if notificationToken != nil {
            notificationToken?.invalidate()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView!.collectionViewLayout.invalidateLayout()
    }
    
    private func sendUnsubscribForRoom(roomId: Int64){
        IGClientUnsubscribeFromRoomRequest.Generator.generate(roomId: roomId).success { (responseProtoMessage) in
        }.error({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.sendUnsubscribForRoom(roomId: roomId)
            default:
                break
            }
        }).send()
    }
    
    private func saveMessagePosition() {
        let visibleCells = self.collectionView.indexPathsForVisibleItems.sorted(by:{
            $0.section < $1.section || $0.row < $1.row
        }).compactMap({
            self.collectionView.cellForItem(at: $0)
        })
        
        guard let firstVisibleItem = fetchVisibleMessage(visibleCells: visibleCells, index: 0) else {
            return
        }
        guard let lastVisibleItem = fetchVisibleMessage(visibleCells: visibleCells, index: visibleCells.count-1) else {
            return
        }
        
        var saveState = true
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        if self.collectionView.indexPath(for: visibleCells[0])!.row > IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT {
            for index in 1...IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT {
                var cell: IGRoomMessage!
                if let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: numberOfItems - index, section: 0)) as? AbstractCell {
                    cell = collectionCell.realmRoomMessage
                } else if let collectionCell = self.collectionView.cellForItem(at: IndexPath(row: numberOfItems - index, section: 0)) as? IGMessageGeneralCollectionViewCell {
                    cell = collectionCell.cellMessage
                }
                
                if cell != nil && cell.id == firstVisibleItem.id {
                    saveState = false
                    break
                }
            }
            if saveState {
                IGRoom.saveMessagePosition(roomId: self.room!.id, saveScrollMessageId: lastVisibleItem.id)
            }
        } else { // clear save message position
            IGRoom.saveMessagePosition(roomId: self.room!.id, saveScrollMessageId: 0)
        }
    }
    
    /* fetch visible message from collection view according to entered index */
    private func fetchVisibleMessage(visibleCells: [UICollectionViewCell], index: Int) -> IGRoomMessage? {
        if visibleCells.count > 0 {
            if let visibleMessage = visibleCells[index] as? AbstractCell {
                return visibleMessage.realmRoomMessage
            } else if let visibleMessage = visibleCells[index] as? IGMessageGeneralCollectionViewCell {
                return visibleMessage.cellMessage
            }
        }
        return nil
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
            if btnMic.isHidden {
                return
            }
            
            self.btnMic.isHidden = true
            switch self.room!.type {
            case .chat:
                if self.isBotRoom() {
                    self.btnMoney.isHidden = true
                    self.RightBarConstraints.constant = 38
                    
                }
                else {
                    self.btnMoney.isHidden = true
                    self.RightBarConstraints.constant = 38
                    
                }
                self.view.layoutIfNeeded()
                
                break
            default :
                self.btnMoney.isHidden = true
                self.RightBarConstraints.constant = 38
                self.view.layoutIfNeeded()
                
            }
            self.view.layoutIfNeeded()
            self.btnSend.isHidden = false
            self.btnMoney.isHidden = true
            switch self.room!.type {
            case .chat:
                self.btnMoney.isHidden = true
                self.RightBarConstraints.constant = 38
                self.view.layoutIfNeeded()
                
                break
            default :
                self.btnMoney.isHidden = true
                self.RightBarConstraints.constant = 38
                self.view.layoutIfNeeded()
                
            }
            
            
            
            UIView.transition(with: self.btnSticker, duration: ANIMATE_TIME, options: .transitionFlipFromBottom, animations: {
                self.btnSticker.isHidden = true
                
            }, completion: nil)
            
        } else {
            self.hideMoneyTransactionModal()
            self.hideMoneyInputModal()
            self.hideCardToCardModal()
            
            self.btnSend.isHidden = true
            self.btnMoney.isHidden = true
            switch self.room!.type {
            case .chat:
                self.btnMoney.isHidden = true
                self.RightBarConstraints.constant = 38
                self.view.layoutIfNeeded()
                
                break
            default :
                self.btnMoney.isHidden = true
                self.RightBarConstraints.constant = 38
                self.view.layoutIfNeeded()
                
            }
            self.view.layoutIfNeeded()
            
            
            self.btnMic.isHidden = false
            self.btnMoney.isHidden = false
            switch self.room!.type {
            case .chat:
                if self.isBotRoom(){
                    self.btnMoney.isHidden = true
                    self.RightBarConstraints.constant = 38
                    
                }
                else {
                    self.btnMoney.isHidden = false
                    self.RightBarConstraints.constant = 70
                    
                }
                self.view.layoutIfNeeded()
                
                break
            default :
                self.btnMoney.isHidden = true
                self.RightBarConstraints.constant = 38
                self.view.layoutIfNeeded()
                
            }
            self.view.layoutIfNeeded()
            
            
            
            if self.isBotRoom() {
                self.btnSticker.isHidden = true
            } else {
                self.btnSticker.isHidden = false
                self.inputTextView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
                
                
            }
            
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
        let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
        var defaultValue : CGFloat = 20
        switch mode {
        case .withBoth :
            defaultValue = 112
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        case .withTopPlayer :
            defaultValue = 60
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        case .withPin :
            defaultValue = 70
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
            }, completion: { (completed) in
                
            })

            break
        case .none :
            defaultValue = 20
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: defaultValue, right: 0)
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
            if IGStickerViewController.currentStickerGroupId != nil {
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
        
        let detachedMessage = message.detach()
        
        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
        message.forwardedFrom = IGMessageViewController.selectedMessageToForwardToThisRoom // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
        message.repliedTo = selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
        IGMessageSender.defaultSender.send(message: message, to: room!)
        
        self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
        
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
            self.collectionView.contentOffset = initialContentOffset
        } else {
            let contentOffsetY = self.collectionView.contentSize.height - (initialContentSize.height - initialContentOffset.y)
            // + self.collectionView.contentOffset.y - initialContentSize.height
            self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: contentOffsetY)
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
            } else {
                //showing keyboard
                if UIDevice.current.hasNotch {
                    bottomConstraint = keyboardEndFrame.size.height - 34
                } else {
                    bottomConstraint = keyboardEndFrame.size.height
                }
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(animationCurveOption)), animations: {
                self.messageTextViewBottomConstraint.constant = bottomConstraint
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
    }
    
    func setCollectionViewInset(withDuration: TimeInterval = 0.2) {
        let value = mainHolder.frame.size.height + collectionViewTopInsetOffset// + inputBarViewBottomConstraint.constant
        UIView.animate(withDuration: withDuration, animations: {
            self.collectionView.contentInset = UIEdgeInsets.init(top: value, left: 0, bottom: 20, right: 0)
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
        
        var message = "UNPIN_ARE_U_SURE".MessageViewlocalizedNew
        var title = "UNPIN_FOR_ALL".MessageViewlocalizedNew
        let titleMe = "UNPIN_FOR_ME".MessageViewlocalizedNew
        if messageId != 0 {
            message = "PIN_ARE_U_SURE".MessageViewlocalizedNew
            title = "PINN".MessageViewlocalizedNew
        }
        
        let alertC = UIAlertController(title: nil, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        let unpin = UIAlertAction(title: title, style: .default, handler: { (action) in
            IGGroupPinMessageRequest.Generator.generate(roomId: (self.room?.id)!, messageId: messageId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    if let groupPinMessage = protoResponse as? IGPGroupPinMessageResponse {
                        if groupPinMessage.hasIgpPinnedMessage {
                            self.txtPinnedMessage.text = IGRoomMessage.detectPinMessageProto(message: groupPinMessage.igpPinnedMessage)
                            self.pinnedMessageView.isHidden = false
                            self.collectionView.contentInset.bottom = self.pinnedMessageView.frame.size.height
                        } else {
                            self.pinnedMessageView.isHidden = true
                            self.collectionView.contentInset.bottom = 0
                            
                        }
                        IGGroupPinMessageRequest.Handler.interpret(response: groupPinMessage)
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".MessageViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".MessageViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        })
        
        let unpinJustForMe = UIAlertAction(title: titleMe, style: .default, handler: { (action) in
            self.pinnedMessageView.isHidden = true
            IGFactory.shared.roomPinMessage(roomId: (self.room?.id)!)
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".localizedNew, style: .cancel, handler: nil)
        
        alertC.addAction(unpin)
        if messageId == 0 {
            alertC.addAction(unpinJustForMe)
        }
        alertC.addAction(cancel)
        self.present(alertC, animated: true, completion: nil)
    }
    
    func channelPin(messageId: Int64 = 0){
        
        var message = "UNPIN_ARE_U_SURE".MessageViewlocalizedNew
        var title = "UNPIN_FOR_ALL".MessageViewlocalizedNew
        let titleMe = "UNPIN_FOR_ME".MessageViewlocalizedNew
        if messageId != 0 {
            message = "PIN_ARE_U_SURE".MessageViewlocalizedNew
            title = "PINN".MessageViewlocalizedNew
        }
        
        let alertC = UIAlertController(title: nil, message: message, preferredStyle: IGGlobal.detectAlertStyle())
        let unpin = UIAlertAction(title: title, style: .default, handler: { (action) in
            IGChannelPinMessageRequest.Generator.generate(roomId: (self.room?.id)!, messageId: messageId).success({ (protoResponse) in
                DispatchQueue.main.async {
                    if let channelPinMessage = protoResponse as? IGPChannelPinMessageResponse {
                        if channelPinMessage.hasIgpPinnedMessage {
                            self.txtPinnedMessage.text = IGRoomMessage.detectPinMessageProto(message: channelPinMessage.igpPinnedMessage)
                            self.pinnedMessageView.isHidden = false
                            self.collectionView.contentInset.bottom = self.pinnedMessageView.frame.size.height
                        } else {
                            self.pinnedMessageView.isHidden = true
                            self.collectionView.contentInset.bottom = 0
                        }
                        IGChannelPinMessageRequest.Handler.interpret(response: channelPinMessage)
                    }
                }
            }).error({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "TIME_OUT".MessageViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".MessageViewlocalizedNew, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default:
                    break
                }
                
            }).send()
        })
        
        let unpinJustForMe = UIAlertAction(title: titleMe, style: .default, handler: { (action) in
            self.pinnedMessageView.isHidden = true
            IGFactory.shared.roomPinMessage(roomId: (self.room?.id)!)
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: nil)
        
        alertC.addAction(unpin)
        if messageId == 0 {
            alertC.addAction(unpinJustForMe)
        }
        alertC.addAction(cancel)
        self.present(alertC, animated: true, completion: nil)
    }
    
    func groupPinGranted() -> Bool{
        if room?.type == .group && room?.groupRoom?.role != .member {
            return true
        }
        return false
    }
    
    func channelPinGranted() -> Bool{
        if room?.type == .channel && room?.channelRoom?.role != .member {
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
    
    func allowEdit(_ message: IGRoomMessage) -> Bool{
        if  (message.forwardedFrom == nil) && message.type != .sticker && message.authorHash == currentLoggedInUserAuthorHash && message.type != .contact && message.type != .location &&
            ((self.room!.type == .chat) || (self.room!.type == .channel && self.room!.channelRoom!.role != .member) || (self.room!.type == .group && self.room!.groupRoom!.role != .member)) {
            return true
        }
        return false
    }
    
    func allowDelete(_ message: IGRoomMessage) -> (singleDelete: Bool, bothDelete: Bool){
        var singleDelete = false
        var bothDelete = false
        if (message.authorHash == currentLoggedInUserAuthorHash) || (self.room!.type == .chat) ||
            (self.room!.type == .channel && self.room!.channelRoom!.role == .owner) ||
            (self.room!.type == .group && self.room!.groupRoom!.role == .owner) {
            if (self.room!.type == .chat) && (message.authorHash == currentLoggedInUserAuthorHash) && (message.creationTime != nil) && (Date().timeIntervalSince1970 - message.creationTime!.timeIntervalSince1970 < 2 * 3600) {
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
            message.type == .gif) && IGGlobal.isFileExist(path: message.attachment!.path(), fileSize: message.attachment!.size) {
            return true
        }
        return false
    }
    
    @objc func didTapOnInputTextView() {
        //        messageTextView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        disableStickerView(delay: 0.0, openKeyboard: true)
    }
    @objc func didTapOnDissmissView() {
        if forwardModal != nil {
            
            hideMultiShareModal()
            self.view.endEditing(true)
            
        }
        
    }
    
    
    @IBAction func didTapOnPickSticker(_ sender: UIButton) {
        print("clicked")
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
            self.pinnedMessageView.isHidden = true
            IGFactory.shared.roomPinMessage(roomId: (self.room?.id)!)
            self.collectionView.contentInset.bottom = 0
            
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
            IGGlobal.playSound(isInChat : IGGlobal.isInChatPage,isSilent : IGGlobal.isSilent,isSendMessage: true)
            
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
            
            let detachedMessage = message.detach()
            
            IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
            message.forwardedFrom = IGMessageViewController.selectedMessageToForwardToThisRoom // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
            message.repliedTo = selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
            IGMessageSender.defaultSender.send(message: message, to: room!)
            
            self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
            
            self.sendMessageState(enable: false)
            self.messageTextView.text = ""
            self.currentAttachment = nil
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = nil
            self.setInputBarHeight()
            self.setupMessageTextHeightChnage()
            
        } else {
            ///play send sound
            IGGlobal.playSound(isInChat : IGGlobal.isInChatPage,isSilent : IGGlobal.isSilent,isSendMessage: true)
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
                    
                    let detachedMessage = message.detach()
                    
                    IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                    message.forwardedFrom = IGMessageViewController.selectedMessageToForwardToThisRoom // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                    message.repliedTo = self.selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
                    IGMessageSender.defaultSender.send(message: message, to: self.room!)
                    
                    self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
                    
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
                    MoneyTransactionModal!.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: MoneyTransactionModal.frame.height)
                    
                    
                    
                    MoneyTransactionModal.btnWalletTransfer.setTitle("BTN_CASHOUT_WALLET".MessageViewlocalizedNew, for: .normal)
                    MoneyTransactionModal.btnCardToCardTransfer.setTitle("CARD_TO_CARD".MessageViewlocalizedNew, for: .normal)
                    //                    MoneyTransactionModal.infoLbl.text = "ENTER_RECIEVER_CODE".MessageViewlocalizedNew
                    
                    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
                    swipeDown.direction = .down
                    
                    MoneyTransactionModal.addGestureRecognizer(swipeDown)
                    self.view.addSubview(MoneyTransactionModal!)
                    
                }
                else {
                    MoneyTransactionModal.btnWalletTransfer.setTitle("BTN_CASHOUT_WALLET".MessageViewlocalizedNew, for: .normal)
                    MoneyTransactionModal.btnCardToCardTransfer.setTitle("CARD_TO_CARD".MessageViewlocalizedNew, for: .normal)
                    //                    MoneyTransactionModal.infoLbl.text = "ENTER_RECIEVER_CODE".MessageViewlocalizedNew
                    //                    MoneyTransactionModal.inputTF.placeholder = "ENTER_CODE".MessageViewlocalizedNew
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
            //            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
        })
    }
    func transferToWallet(pbKey: String!,token: String)  {
        
        SMLoading.shared.showInputPinDialog(viewController: self, icon: nil, title: "", message: "enterpin".localized, yesPressed: { pin in
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
                    SMLoading.shared.showNormalDialog(viewController: self, height: 200, isleftButtonEnabled: false, title: "error".localized, message: ((err as! Dictionary<String, AnyObject>)["NSLocalizedDescription"]! as! String).localized)
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
            
            
            
            MoneyInputModal.confirmBtn.setTitle("GLOBAL_OK".MessageViewlocalizedNew, for: .normal)
            //                    MoneyTransactionModal.infoLbl.text = "ENTER_RECIEVER_CODE".MessageViewlocalizedNew
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            MoneyInputModal.addGestureRecognizer(swipeDown)
            self.view.addSubview(MoneyInputModal!)
            
        }
        else {
            MoneyInputModal.confirmBtn.setTitle("GLOBAL_OK".MessageViewlocalizedNew, for: .normal)
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
            
            
            
            CardToCardModal.confirmBtn.setTitle("REQUEST_CARD_TO_CARD".MessageViewlocalizedNew, for: .normal)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            CardToCardModal.addGestureRecognizer(swipeDown)
            self.view.addSubview(CardToCardModal!)
            
        }
        else {
            CardToCardModal.confirmBtn.setTitle("REQUEST_CARD_TO_CARD".MessageViewlocalizedNew, for: .normal)
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
    
    @objc func confirmTapped() {
        
        if MoneyInputModal != nil {
            if MoneyInputModal.inputTF.text == "" ||  MoneyInputModal.inputTF.text == nil {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: nil, showIconView: true, showDoneButton: false, showCancelButton: true, message: "FILL_AMOUNT".MessageViewlocalizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)

            }
            else {
                self.hideMoneyTransactionModal()
                self.hideMoneyInputModal()
                self.hideCardToCardModal()
                
                let tmpJWT : String! =  KeychainSwift().get("accesstoken")!
                SMLoading.showLoadingPage(viewcontroller: self)
                IGRequestWalletPaymentInit.Generator.generate(jwt: tmpJWT, amount: (Int64((MoneyInputModal.inputTF.text!).inEnglishNumbersNew().onlyDigitChars())!), userID: tmpUserID, description: "", language: IGPLanguage(rawValue: IGPLanguage.faIr.rawValue)!).success ({ (protoResponse) in
                    SMLoading.hideLoadingPage()
                    if let response = protoResponse as? IGPWalletPaymentInitResponse {
                        SMUserManager.publicKey = response.igpPublicKey
                        SMUserManager.payToken = response.igpToken
                        self.transferToWallet(pbKey: SMUserManager.publicKey, token: SMUserManager.payToken!)
                    }
                }).error ({ (errorCode, waitTime) in
                    switch errorCode {
                        
                    case .timeout:
                        SMLoading.hideLoadingPage()
                        self.walletTransferTapped()
                    default:
                        break
                    }
                }).send()
            }
        }
        
        if CardToCardModal != nil {
            if CardToCardModal.inputTFOne.text == "" ||  CardToCardModal.inputTFOne.text == nil || CardToCardModal.inputTFTwo.text == "" ||  CardToCardModal.inputTFTwo.text == nil || CardToCardModal.inputTFThree.text == "" ||  CardToCardModal.inputTFThree.text == nil {
                IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: "GLOBAL_WARNING".localizedNew, showIconView: true, showDoneButton: false, showCancelButton: true, message: "FILL_AMOUNT".MessageViewlocalizedNew, cancelText: "GLOBAL_CLOSE".localizedNew)
            } else {
                
                let messageText = CardToCardModal.inputTFOne.text!.substring(offset: MAX_TEXT_LENGHT)
                let message = IGRoomMessage.makeCardToCardRequestWithAmount(messageText: messageText, amount: ((CardToCardModal.inputTFTwo.text!).inEnglishNumbersNew().onlyDigitChars()), cardNumber: ((CardToCardModal.inputTFThree.text!).inEnglishNumbersNew().onlyDigitChars()))
                let detachedMessage = message.detach()
                IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
                IGMessageSender.defaultSender.send(message: message, to: self.room!)
                self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
                
                IGMessageViewController.selectedMessageToForwardToThisRoom = nil
                self.sendMessageState(enable: false)
                self.isCardToCardRequestEnable = false
                self.messageTextView.text = ""
                self.currentAttachment = nil
                self.selectedMessageToReply = nil
                self.setInputBarHeight()
                self.hideCardToCardModal()
            }
        }
    }
    
    @objc func didtapOutSide() {
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
            
            dismissBtn.removeFromSuperview()
            dismissBtn = nil
        }
    }
    
    @objc func cardToCardTaped() {
        if MoneyTransactionModal != nil {
            hideMoneyTransactionModal()
            self.hideMoneyInputModal()
            self.hideCardToCardModal()
            
            self.isCardToCardRequestEnable = true
            self.manageCardToCardInputBar()
        }
    }
    
    @objc func sendMultiForwardRequest() {
        diselect()
        if forwardModal != nil {
            hideMultiShareModal()
            IGHelperForward.handleForward(messages: self.selectedMessages, forwardModal: forwardModal, controller: self)
        }
    }
    
    func hideMoneyTransactionModal() {
        
        self.MoneyTransactionModalIsActive = false
        if MoneyTransactionModal != nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.MoneyTransactionModal.frame.origin.y = self.view.frame.height
                
            }) { (true) in
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                //                self.MoneyTransactionModal.removeFromSuperview()
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
                self.MoneyInputModal.removeFromSuperview()
                self.MoneyInputModal = nil
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
    func hideMultiShareModal() {
        self.MultiShareModalIsActive = false
        
        if forwardModal != nil {
            self.dissmissViewBG.removeFromSuperview()
            //            self.blurEffectView.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.forwardModal.frame.origin.y = self.view.frame.height
            }) { (true) in
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // Change `2.0` to the desired number of seconds.
                self.forwardModal.removeFromSuperview()
                self.forwardModal = nil
                if self.dismissBtn != nil {
                    self.dismissBtn.removeFromSuperview()
                }
            }
            
        }
        forwardModal.searchBar.endEditing(true)
        
        
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
        if forwardModal != nil {
            
            hideMultiShareModal()
            self.view.endEditing(true)
            
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
            self.deleteMessage(message , both:self.isBoth)
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
        
        let camera = UIAlertAction(title: "CAMERA_DEVICE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.attachmentPicker(screens: [.photo, .video])
        })
        
        let galley = UIAlertAction(title: "PHOTO_GALLERY".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.attachmentPicker(screens: [.library])
        })
        
        let document = UIAlertAction(title: "FILE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.sendAsFileAlert()
        })
        
        let contact = UIAlertAction(title: "CONTACT".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.openContact()
        })
        
        let location = UIAlertAction(title: "LOCATION".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.openLocation()
        })
        //location.setValue(UIImage(named: "Location_Marker"), forKey: "image")
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: nil)
        
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
        let photoOrVideo = UIAlertAction(title: "PHOTO_OR_VIDEO".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.attachmentPicker(sendAsFile: true)
        })
        let document = UIAlertAction(title: "DOCUMENT".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.documentPicker()
        })
        let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: nil)
        
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
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filename = mediaUrl.lastPathComponent
        let fileSize = Int(IGGlobal.getFileSize(path: mediaUrl))
        let randomString = IGGlobal.randomString(length: 16) + "_"
        
        /*** get thumbnail from video ***/
        let asset = AVURLAsset(url: mediaUrl)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = try!imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let uiImage = UIImage(cgImage: cgImage)
        
        let attachment = IGFile(name: filename)
        attachment.size = fileSize
        attachment.duration = asset.duration.seconds
        attachment.fileNameOnDisk = randomString + filename
        attachment.name = filename
        attachment.attachedImage = uiImage
        attachment.type = .video
        attachment.height = Double(cgImage.height)
        attachment.width = Double(cgImage.width)
        
        let pathOnDisk = documents + "/" + randomString + filename
        try! FileManager.default.copyItem(atPath: mediaUrl.path, toPath: pathOnDisk)
        
        self.inputBarAttachmentViewThumnailImageView.image = uiImage
        self.inputBarAttachmentViewThumnailImageView.layer.cornerRadius = 6.0
        self.inputBarAttachmentViewThumnailImageView.layer.masksToBounds = true
        self.didSelectAttachment(attachment)
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
        let randomString = IGGlobal.randomString(length: 16) + "_"
        
        var scaledImage = originalImage
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        let fileNameOnDisk = randomString + filename
        
        if (originalImage.size.width) > CGFloat(2000.0) || (originalImage.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: originalImage)
        }
        
        let attachment = IGFile(name: filename)
        attachment.attachedImage = scaledImage
        attachment.fileNameOnDisk = fileNameOnDisk
        attachment.height = Double((scaledImage.size.height))
        attachment.width = Double((scaledImage.size.width))
        attachment.size = (imgData?.count)!
        attachment.data = imgData
        attachment.type = .image
        
        DispatchQueue.main.async {
            self.saveAttachmentToLocalStorage(data: imgData!, fileNameOnDisk: fileNameOnDisk)
        }
        
        self.inputBarAttachmentViewThumnailImageView.image = attachment.attachedImage
        self.inputBarAttachmentViewThumnailImageView.layer.cornerRadius = 6.0
        self.inputBarAttachmentViewThumnailImageView.layer.masksToBounds = true
        
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
                self.manageFile(fileData: data, filename: "FILE_VIDEO_" + IGGlobal.randomString(length: 3), single: single)
            }
            return
        }
        
        let mediaUrl = videoInfo.url
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filename = mediaUrl.lastPathComponent
        let fileSize = Int(IGGlobal.getFileSize(path: mediaUrl))
        let randomString = IGGlobal.randomString(length: 16) + "_"
        
        /*** get thumbnail from video ***/
        let attachment = IGFile(name: filename)
        attachment.size = fileSize
        attachment.duration = videoInfo.asset!.duration
        attachment.fileNameOnDisk = randomString + filename
        attachment.name = filename
        attachment.attachedImage = videoInfo.thumbnail
        attachment.type = .video
        attachment.height = Double(videoInfo.asset!.pixelHeight)
        attachment.width = Double(videoInfo.asset!.pixelWidth)
        
        let pathOnDisk = documents + "/" + randomString + filename
        try! FileManager.default.copyItem(atPath: mediaUrl.path, toPath: pathOnDisk)
        
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
    
    func manageImage(imageInfo: YPMediaPhoto, single: Bool = true, sendAsFile: Bool = false){
        
        var image = imageInfo.modifiedImage
        if image == nil {
            image = imageInfo.originalImage
        }
        
        if sendAsFile {
            if let data = image!.pngData() {
                self.manageFile(fileData: data, filename: "FILE_IMAGE_" + IGGlobal.randomString(length: 3), single: single)
            }
            return
        }
        
        let filename = "IMAGE_" + IGGlobal.randomString(length: 16)
        var scaledImage: UIImage! = image
        let imgData = scaledImage.jpegData(compressionQuality: 0.7)
        
        if (image!.size.width) > CGFloat(2000.0) || (image!.size.height) >= CGFloat(2000) {
            scaledImage = IGUploadManager.compress(image: image!)
        }
        
        let attachment = IGFile(name: filename)
        attachment.attachedImage = scaledImage
        attachment.fileNameOnDisk = filename
        attachment.height = Double((scaledImage.size.height))
        attachment.width = Double((scaledImage.size.width))
        attachment.size = (imgData?.count)!
        attachment.data = imgData
        attachment.type = .image
        //TODO - don't use 'DispatchQueue.main.async' like this, use closure
        //DispatchQueue.main.async {
        self.saveAttachmentToLocalStorage(data: imgData!, fileNameOnDisk: filename)
        //}
        
        if single {
            self.imgAttachmentImage.image = attachment.attachedImage
            self.imgAttachmentImage.layer.cornerRadius = 6.0
            self.imgAttachmentImage.layer.masksToBounds = true
            self.didSelectAttachment(attachment)
        } else {
            self.currentAttachment = attachment
            self.didTapOnSendButton(self.btnSend)
        }
    }
    
    func manageFile(fileData: Data, filename: String, single: Bool = true) {
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathOnDisk = documents + "/" + filename
        let fileUrl : URL = NSURL(fileURLWithPath: pathOnDisk) as URL
        let fileSize = Int(fileData.count)
        
        writeFileToUrl(data: fileData, url: fileUrl) {
            DispatchQueue.main.async {
                let attachment = IGFile(name: filename)
                attachment.size = fileSize
                attachment.fileNameOnDisk = filename
                attachment.name = filename
                attachment.type = .file
                
                if single {
                    self.imgAttachmentImage.image = UIImage(named: "IG_Message_Cell_File_Generic")
                    //                    self.imgAttachmentImage.frame = CGRect(x: 0, y: 0, width: 30, height: 34)
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
    
    /*
     func manageFile(fileData: Data, filename: String) {
     
     let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
     let randomString = IGGlobal.randomString(length: 16) + "_"
     let pathOnDisk = documents + "/" + randomString + filename
     
     let fileUrl : URL = NSURL(fileURLWithPath: pathOnDisk) as URL
     let fileSize = Int(fileData.count)
     
     // write data to my fileUrl
     try! fileData.write(to: fileUrl)
     
     let attachment = IGFile(name: filename)
     attachment.size = fileSize
     attachment.fileNameOnDisk = randomString + filename
     attachment.name = filename
     attachment.type = .file
     
     let randomStringFinal = IGGlobal.randomString(length: 16) + "_"
     let pathOnDiskFinal = documents + "/" + randomStringFinal + filename
     try! FileManager.default.copyItem(atPath: fileUrl.path, toPath: pathOnDiskFinal)
     
     self.inputBarAttachmentViewThumnailImageView.image = UIImage(named: "IG_Message_Cell_File_Generic")
     self.inputBarAttachmentViewThumnailImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 34)
     self.inputBarAttachmentViewThumnailImageView.layer.cornerRadius = 6.0
     self.inputBarAttachmentViewThumnailImageView.layer.masksToBounds = true
     
     self.didSelectAttachment(attachment)
     }
     */
    
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
        collectionView.isHidden = true
        chatBackground.isHidden = true
        self.mainHolder.isHidden = true
        self.webView.isHidden = false
        self.view.endEditing(true)
        
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.backViewContainer?.addAction {
            self.back()
        }
        
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
        collectionView.isHidden = false
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
            webViewProgressbar.color = UIColor(named: themeColor.labelGrayColor.rawValue)
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
            let navigationItem = self.navigationItem as! IGNavigationItem
            navigationItem.backViewContainer?.isUserInteractionEnabled = false
            
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
        let detachedMessage = message.detach()
        IGFactory.shared.saveNewlyWriitenMessageToDatabase(detachedMessage)
        message.forwardedFrom = IGMessageViewController.selectedMessageToForwardToThisRoom // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
        message.repliedTo = self.selectedMessageToReply // Hint: if use this line before "saveNewlyWriitenMessageToDatabase" app will be crashed
        IGMessageSender.defaultSender.send(message: message, to: self.room!)
        
        self.appendMessageArray([message], .down)
        self.addChatItemToBottom(count: 1, scrollToBottom: true)
        self.messageLoader.setWaitingHistoryDownLocal(isWaiting: false)
        
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
        }
    }
    
    @IBAction func didTapOnCancelReplyOrForwardButton(_ sender: UIButton) {
        IGMessageViewController.selectedMessageToForwardToThisRoom = nil
        self.isCardToCardRequestEnable = false
        self.selectedMessageToReply = nil
        if self.selectedMessageToEdit != nil {
            self.selectedMessageToEdit = nil
            self.messageTextView.text = ""
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
    }
    
    private func scrollToBottom(){
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -self.collectionView.contentInset.top) , animated: false)
    }
    
    @IBAction func didTapOnJoinButton(_ sender: UIButton) {
        
        if isBotRoom() {
            messageTextView.text = "/Start"
            self.didTapOnSendButton(self.btnSend)
            
            self.joinButton.isHidden = true
            
            self.mainHolder.isHidden = false
            return
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
        if let publicRooomUserName = username {
            self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.hud.mode = .indeterminate
            IGClientJoinByUsernameRequest.Generator.generate(userName: publicRooomUserName).success({ (protoResponse) in
                self.openChatFromLink = false
                DispatchQueue.main.async {
                    switch protoResponse {
                    case let clientJoinbyUsernameResponse as IGPClientJoinByUsernameResponse:
                        if let roomId = self.room?.id {
                            IGClientJoinByUsernameRequest.Handler.interpret(response: clientJoinbyUsernameResponse, roomId: roomId)
                        }
                        self.joinButton.isHidden = true
                        self.hud.hide(animated: true)
                        self.collectionViewTopInsetOffset = -54.0 + 8.0
                    default:
                        break
                    }
                }
            }).error ({ (errorCode, waitTime) in
                switch errorCode {
                case .timeout:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                case .clinetJoinByUsernameForbidden:
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "You don't have permission to join this room", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.hud.hide(animated: true)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                default:
                    break
                }
                
            }).send()
        }
    }
    
    
    //MARK: AudioRecorder
    @objc func didTapAndHoldOnRecord(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            startRecording()
            initialLongTapOnRecordButtonPosition = gestureRecognizer.location(in: self.view)
        case .cancelled:
            print("cancelled")
        case .changed:
            let point = gestureRecognizer.location(in: self.view)
            let difX = (initialLongTapOnRecordButtonPosition?.x)! - point.x
            
            var newConstant:CGFloat = 0.0
            print(newConstant)
            if difX > 10 {
                newConstant = 74 - difX
            } else {
                newConstant = 74
            }
            
            if newConstant > 0{
                //                inputBarRecordViewLeftConstraint.constant = newConstant
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                cancelRecording()
            }
            
        case .ended:
            finishRecording()
        case .failed:
            print("failed")
        case .possible:
            print("possible")
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
        bouncingViewWhileRecord?.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
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
            
            
            self.inputTextView.isHidden = false
            self.inputBarLeftView.isHidden = false
            
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
            let fileName = "Recording - \(NSDate.timeIntervalSinceReferenceDate)"
            
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
    
    func saveAttachmentToLocalStorage(data: Data, fileNameOnDisk: String) {
        let path = IGFile.path(fileNameOnDisk: fileNameOnDisk)
        FileManager.default.createFile(atPath: path.path, contents: data, attributes: nil)
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
        //        messageTextView.placeholder = "MESSAGE".MessageViewlocalizedNew
        initChangeLanguegeNewChatView()
        self.messageTextView.becomeFirstResponder()
        self.lblReplyName.text = "EDITE_MESSAGE".MessageViewlocalizedNew
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
            prefix = "REPLY".MessageViewlocalizedNew
            IGMessageViewController.selectedMessageToForwardToThisRoom = nil
            self.selectedMessageToReply = message
        } else {
            prefix = "FORWARD".MessageViewlocalizedNew
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
                self.lblReplyBody.text = textMessage! + "LBL_STICKER".MessageViewlocalizedNew
            } else {
                self.lblReplyBody.text = textMessage
                
                let markdown = MarkdownParser()
                markdown.enabledElements = MarkdownParser.EnabledElements.bold
                self.lblReplyBody.attributedText = markdown.parse(textMessage!)
                self.lblReplyBody.textColor = UIColor(named: themeColor.labelGrayColor.rawValue)
                self.lblReplyBody.font = UIFont.igFont(ofSize: 11.0)
            }
            
        } else if finalMessage.contact != nil {
            self.lblReplyBody.text = "\(prefix)" + "CONTACT_MESSAGE".MessageViewlocalizedNew
        } else if finalMessage.location != nil {
            self.lblReplyBody.text = "\(prefix)" + "LOCATION_MESSAGE".MessageViewlocalizedNew
        } else if let file = finalMessage.attachment {
            self.lblReplyBody.text = "\(prefix) '\(IGFile.convertFileTypeToString(fileType: file.type))'" + "MESSAGE".MessageViewlocalizedNew
        }
        
        self.setInputBarHeight()
    }
    
    private func manageCardToCardInputBar(){
        self.lblReplyName.text = "CARD_TO_CARD_REQUEST".MessageViewlocalizedNew
        self.lblReplyBody.text = "CARD_TO_CARD_FILL_INFO".MessageViewlocalizedNew
        self.setInputBarHeight()
    }
    
    func reportRoom(roomId: Int64, messageId: Int64, reason: IGPClientRoomReport.IGPReason) {
        self.hud = MBProgressHUD.showAdded(to: self.view.superview!, animated: true)
        self.hud.mode = .indeterminate
        IGClientRoomReportRequest.Generator.generate(roomId: roomId, messageId: messageId, reason: reason).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case _ as IGPClientRoomReportResponse:
                    let alert = UIAlertController(title: "Success", message: "Your report has been successfully submitted", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).error({ (errorCode , waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "Timeout", message: "Please try again later", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportReportedBefore:
                    let alert = UIAlertController(title: "Error", message: "This Room Reported Before", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                case .clientRoomReportForbidden:
                    let alert = UIAlertController(title: "Error", message: "Room Report Fobidden", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                    
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
    }
    
    func report(room: IGRoom, message: IGRoomMessage){
        let roomId = room.id
        let messageId = message.id
        
        let alertC = UIAlertController(title: title, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let abuse = UIAlertAction(title: "ABUSE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.abuse)
        })
        
        let spam = UIAlertAction(title: "SPAM".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.spam)
        })
        
        let violence = UIAlertAction(title: "VIOLENCE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.violence)
        })
        
        let pornography = UIAlertAction(title: "PORNOGRAPHY".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.reportRoom(roomId: roomId, messageId: messageId, reason: IGPClientRoomReport.IGPReason.pornography)
        })
        
        let other = UIAlertAction(title: "OTHER".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.reportMessageId = messageId
            self.performSegue(withIdentifier: "showReportPage", sender: self)
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: { (action) in
            
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
            let alert = UIAlertController(title: "GLOBAL_WARNING".MessageViewlocalizedNew, message: "NO_NETWORK".MessageViewlocalizedNew, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
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
        self.reloadCollection()
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
                //                stickerViewController.backGroundColor = UIColor(named: themeColor.tableViewCell.rawValue)
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
extension IGMessageViewController: IGMessageCollectionViewDataSource {
    
    private func getMessageType(message: IGRoomMessage) -> IGRoomMessageType {
        var finalMessage = message
        if let forward = message.forwardedFrom {
            finalMessage = forward
        }
        return finalMessage.type
    }
    
    func collectionView(_ collectionView: IGMessageCollectionView, messageAt indexpath: IndexPath) -> IGRoomMessage {
        return messages![indexpath.row]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if messages != nil {
            return messages!.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /* if room was deleted close chat room */
        if (self.room?.isInvalidated)! {
            self.navigationController?.popViewController(animated: true)
            
            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
            cell.setUnknownMessage()
            
            return cell
        }
        
        self.collectionView = collectionView as? IGMessageCollectionView
        let message = messages![indexPath.row]
        var isIncommingMessage = true
        var shouldShowAvatar = false
        var isPreviousMessageFromSameSender = false
        let isNextMessageFromSameSender = false
        
        let messageType = getMessageType(message: message)
        
        
        if self.room?.type == .channel { // isIncommingMessage means that show message left side
            isIncommingMessage = true
        } else if let senderHash = message.authorHash, senderHash == IGAppManager.sharedManager.authorHash() {
            isIncommingMessage = false
        }
        
        if room?.groupRoom != nil {
            shouldShowAvatar = true
            
            if isIncommingMessage {
                if message.type != .log {
                    if messages!.indices.contains(indexPath.row + 1){
                        let previousMessage = messages![(indexPath.row + 1)]
                        if previousMessage.type != .log && message.authorHash == previousMessage.authorHash {
                            isPreviousMessageFromSameSender = true
                        }
                    }
                    
                    //Hint: comment following code because corrently we don't use from 'isNextMessageFromSameSender' variable
                    /*
                     if messages!.indices.contains(indexPath.row - 1){
                     let nextMessage = messages![(indexPath.row - 1)]
                     if message.authorHash == nextMessage.authorHash {
                     isNextMessageFromSameSender = true
                     }
                     }
                     */
                }
            } else {
                shouldShowAvatar = false
            }
        }
        
        
        if messageType == .text {
            let cell: TextCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCell.cellReuseIdentifier(), for: indexPath) as! TextCell
            
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .image ||  messageType == .imageAndText {
            let cell: ImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellReuseIdentifier(), for: indexPath) as! ImageCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .video || messageType == .videoAndText {
            let cell: VideoCell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.cellReuseIdentifier(), for: indexPath) as! VideoCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .gif || messageType == .gifAndText {
            let cell: GifCell = collectionView.dequeueReusableCell(withReuseIdentifier: GifCell.cellReuseIdentifier(), for: indexPath) as! GifCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .contact {
            let cell: ContactCell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactCell.cellReuseIdentifier(), for: indexPath) as! ContactCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .file || messageType == .fileAndText {
            let cell: FileCell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCell.cellReuseIdentifier(), for: indexPath) as! FileCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .voice  {
            let cell: VoiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: VoiceCell.cellReuseIdentifier(), for: indexPath) as! VoiceCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .audio || messageType == .audioAndText {
            let cell: AudioCell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCell.cellReuseIdentifier(), for: indexPath) as! AudioCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.clickedAudioCellIndexPath = indexPath
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .sticker {
            let cell: StickerCell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCell.cellReuseIdentifier(), for: indexPath) as! StickerCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .location {
            let cell: LocationCell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCell.cellReuseIdentifier(), for: indexPath) as! LocationCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
            
            if IGGlobal.shouldMultiSelect {
                if selectedMessages.count > 0 {
                    let selectedBefore = self.selectedMessages.filter{$0.id == messages![indexPath.row].id}.count > 0
                    if selectedBefore {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    } else {
                        UIView.transition(with: cell.btnCheckMark, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.btnCheckMark.setTitle("", for: .normal)
                        }, completion: nil)
                    }
                } else {
                    if cell.btnCheckMark != nil {
                        cell.btnCheckMark.setTitle("", for: .normal)
                    }
                }
            }
            
            manageHighlightMode(cell: cell, messageId: message.id)
            
            cell.delegate = self
            return cell
            
        } else if messageType == .wallet {
            
            if message.wallet?.type == IGPRoomMessageWallet.IGPType.cardToCard.rawValue {
                let cell: CardToCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: CardToCardCell.cellReuseIdentifier(), for: indexPath) as! CardToCardCell
                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
                cell.delegate = self
                return cell
            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.payment.rawValue {
                let cell: PaymentCell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.cellReuseIdentifier(), for: indexPath) as! PaymentCell
                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
                cell.delegate = self
                return cell
            } else if message.wallet?.type == IGPRoomMessageWallet.IGPType.moneyTransfer.rawValue {
                let cell: MoneyTransferCell = collectionView.dequeueReusableCell(withReuseIdentifier: MoneyTransferCell.cellReuseIdentifier(), for: indexPath) as! MoneyTransferCell
                let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
                cell.setMessage(message, room: self.room!, isIncommingMessage: isIncommingMessage,shouldShowAvatar: shouldShowAvatar,messageSizes: bubbleSize,isPreviousMessageFromSameSender: isPreviousMessageFromSameSender,isNextMessageFromSameSender: isNextMessageFromSameSender)
                cell.delegate = self
                return cell
            }
            
        } else if message.type == .log {
            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
            let bubbleSize = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setMessage(message, room: self.room!,isIncommingMessage: true,shouldShowAvatar: false,messageSizes:bubbleSize,isPreviousMessageFromSameSender: false,isNextMessageFromSameSender: false)
            return cell
        } else if message.type == .time {
            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
            cell.setTime(message.message!)
            return cell
        } else if message.type == .unread {
            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
            let _ = CellSizeCalculator.sharedCalculator.mainBubbleCountainerSize(room: self.room!, for: message)
            cell.setUnreadMessage(message)
            return cell
        } else {
            let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
            cell.setUnknownMessage()
            return cell
        }
        
        
        let cell: IGMessageLogCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: logMessageCellIdentifer, for: indexPath) as! IGMessageLogCollectionViewCell
        cell.setUnknownMessage()
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0.001, height: 0.001)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        if kind == UICollectionView.elementKindSectionFooter {
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: IGMessageLogCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! IGMessageLogCollectionViewCell
            
            if indexPath.row < messages!.count {
                if let message = messages?[indexPath.row] {
                    if message.shouldFetchBefore {
                        header.setText("Loading ...".MessageViewlocalizedNew)
                    } else {
                        
                        let dayTimePeriodFormatter = DateFormatter()
                        dayTimePeriodFormatter.dateFormat = "MMMM dd"
                        dayTimePeriodFormatter.calendar = Calendar.current
                        let dateString = (message.creationTime!).localizedDate()
                        
                        header.setText(dateString.inLocalizedLanguage())
                    }
                }
            }
            reusableview = header
        }
        return reusableview
    }
    
    private func manageHighlightMode(cell: UICollectionViewCell, messageId: Int64) {
        if messageId == IGMessageViewController.highlightMessageId || messageId == IGMessageViewController.highlightWithoutFastReturn {
            IGMessageViewController.highlightMessageId = 0
            IGMessageViewController.highlightWithoutFastReturn = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIView.transition(with: cell, duration: 0.5, animations: {
                    cell.backgroundColor = UIColor.iGapGreen().withAlphaComponent(0.5)
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.backgroundColor = UIColor.clear
                    }, completion: nil)
                })
            }
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension IGMessageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if messages!.count <= indexPath.row { return CGSize(width: 0, height: 0) }
        
        let message = messages![indexPath.row]
        let size = self.collectionView.layout.sizeCell(room: self.room!, for: message)
        let frame = size.bubbleSize
        
        return CGSize(width: self.collectionView.frame.width, height: frame.height + size.additionalHeight + 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let message = messages![indexPath.row]
        if (IGGlobal.shouldMultiSelect) {
            if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                self.selectedMessages.remove(at: index)
            } else {
                self.selectedMessages.append(message)
            }
            
            if self.selectedMessages.count > 0 {
                lblSelectedMessages.text = String(self.selectedMessages.count).inLocalizedLanguage() + " " + "SELECTED".MessageViewlocalizedNew
                inputBarDeleteButton.setTitleColor(UIColor.iGapDarkGray(), for: .normal)
                inputBarDeleteButton.isEnabled = true
            } else {
                lblSelectedMessages.text = ""
                inputBarDeleteButton.setTitleColor(UIColor.iGapGray(), for: .normal)
                inputBarDeleteButton.isEnabled = false
            }
            self.collectionView.reloadItems(at: [indexPath])
            
        } else {
            self.messageTextView.resignFirstResponder()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // TODO - when isWaiting for get from server return this method and don't do any action
        
        if self.collectionView.numberOfItems(inSection: 0) == 0 {
            return
        }
        
        setFloatingDate()
        
        //currently use inverse
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) { //reach top
            if (!self.messageLoader.isFirstLoadUp() || self.messageLoader.isForceFirstLoadUp()) && !self.messageLoader.isWaitingHistoryUpLocal() {
                self.messageLoader.loadMessage(direction: .up, onMessageReceive: { (messages, direction) in
                    self.addChatItem(realmRoomMessages: messages, direction: direction, scrollToBottom: false)
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
            if !self.messageLoader.isFirstLoadDown() && !self.messageLoader.isWaitingHistoryDownLocal() {
                self.messageLoader.loadMessage(direction: .down, onMessageReceive: { (messages, direction) in
                    self.addChatItem(realmRoomMessages: messages, direction: direction, scrollToBottom: false)
                })
            }
        }
        
        //100 is an arbitrary number. can be anything
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y > 100 {
            self.scrollToBottomContainerView.isHidden = false
        } else {
            if isBotRoom() && IGHelperDoctoriGap.isDoctoriGapRoom(room: room!) {
                scrollToBottomContainerViewConstraint.constant = CGFloat(DOCTOR_BOT_HEIGHT)
            } else {
                if room!.isReadOnly {
                    scrollToBottomContainerViewConstraint.constant = -40
                }
            }
            self.scrollToBottomContainerView.isHidden = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5, animations: {
            self.floatingDateView.alpha = 0.0
        })
        UIView.animate(withDuration: 0.5, animations: {
            self.txtFloatingDate.alpha = 0.0
        })
    }
    
    private func setFloatingDate(){
        if messages == nil {return}
        let arrayOfVisibleItems = collectionView.indexPathsForVisibleItems.sorted()
        if let lastIndexPath = arrayOfVisibleItems.last {
            if latestIndexPath != lastIndexPath {
                
                if let cell = self.collectionView?.cellForItem(at: IndexPath(row: lastIndexPath.row, section: 0)) as? IGMessageLogCollectionViewCell, cell.cellMessage?.type != .log {
                    return
                }
                
                latestIndexPath = lastIndexPath
            } else {
                return
            }
            
            if latestIndexPath.row < messages!.count {
                
                var previousMessage: IGRoomMessage!
                if  messages!.count > latestIndexPath.row + 1 {
                    previousMessage = (messages?[latestIndexPath.row + 1])!
                }
                
                if let message = messages?[latestIndexPath.row], !message.isInvalidated , message.type != .time , message.type != .unread {
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
}


//MARK: - GrowingTextViewDelegate
extension IGMessageViewController: GrowingTextViewDelegate {
    
    //    func textViewDidChange(_ textView: UITextView) {
    //
    //        let pos = textView.endOfDocument
    //        let currentRect = inputTextView.caretRect(for: pos)
    //        if(currentRect.origin.y > (previousRect.origin.y)){
    //            if inputTextView.frame.height < 150.0 {
    //                inputTextView.scrollRangeToVisible(NSMakeRange(0, 0))
    //            }
    //        }
    //        previousRect = currentRect
    //
    //        self.setSendAndRecordButtonStates()
    //        if allowSendTyping() {
    //            self.sendTyping()
    //            typingStatusExpiryTimer.invalidate()
    //            typingStatusExpiryTimer = Timer.scheduledTimer(timeInterval: 1.0,
    //                                                           target:   self,
    //                                                           selector: #selector(sendCancelTyping),
    //                                                           userInfo: nil,
    //                                                           repeats:  false)
    //        }
    //
    //    }
    
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
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        inputTextViewHeight = height
        setInputBarHeight()
    }
    
    func setInputBarHeight() {
        
        //        {
        //                let height = max(self.inputTextViewHeight - 16, 30)
        //                var inputBarHeight = height + 16.0
        //
        //                inputTextViewHeightConstraint.constant = inputBarHeight - 12
        //
        if currentAttachment != nil {
            //        //            inputBarAttachmentViewBottomConstraint.constant = inputBarHeight
            //        //            inputBarHeight += 36
            holderAttachmentBar.isHidden = false
        } else {
            //        //            inputBarAttachmentViewBottomConstraint.constant = 0.0
            holderAttachmentBar.isHidden = true
        }
        //
        if selectedMessageToEdit != nil {
            //                    inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight
            //                    inputBarHeight += 36.0
            holderReplyBar.isHidden = false
        } else if selectedMessageToReply != nil {
            //                    inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight
            //                    inputBarHeight += 36.0
            holderReplyBar.isHidden = false
        } else if IGMessageViewController.selectedMessageToForwardToThisRoom != nil {
            //                    inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight
            //                    inputBarHeight += 36.0
            holderReplyBar.isHidden = false
            
            //                } else if isCardToCardRequestEnable {
            //                    inputBarOriginalMessageViewBottomConstraint.constant = inputBarHeight
            //                    inputBarHeight += 36.0
        } else {
            //                    inputBarOriginalMessageViewBottomConstraint.constant = 0.0
            holderReplyBar.isHidden = true
        }
        //
        //
        //                inputBarHeightConstraint.constant = inputBarHeight
        //                inputBarHeightContainerConstraint.constant = inputBarHeight + 16
        //
        //                UIView.animate(withDuration: 0.2, animations: {
        //                }, completion: { (completed) in
        //                    self.setCollectionViewInset()
        //                })
        //            }
        //
    }
    
    func managePinnedMessage(){
        if room?.pinMessage != nil && room?.pinMessage?.id != room?.deletedPinMessageId {
            txtPinnedMessage.text = IGRoomMessage.detectPinMessage(message: (room?.pinMessage)!)
            pinnedMessageView.isHidden = false
            
        } else {
            pinnedMessageView.isHidden = true
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
            //discard file if time is too small
            
            //AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:avAudioRecorder.url options:nil];
            //CMTime time = asset.duration;
            //double durationInSeconds = CMTimeGetSeconds(time);
            let asset = AVURLAsset(url: filePath)
            let time = CMTimeGetSeconds(asset.duration)
            if time < 1.0 {
                return
            }
            do {
                let attachment = IGFile(name: filePath.lastPathComponent)
                
                let data = try Data(contentsOf: filePath)
                self.saveAttachmentToLocalStorage(data: data, fileNameOnDisk: filePath.lastPathComponent)
                attachment.fileNameOnDisk = filePath.lastPathComponent
                attachment.size = data.count
                attachment.type = .voice
                self.currentAttachment = attachment
                self.didTapOnSendButton(self.btnSend)
            } catch {
                //there was an error recording voice
            }
        }
        self.isRecordingVoice = false
    }
}

//MARK: - IGMessageGeneralCollectionViewCellDelegate
extension IGMessageViewController: IGMessageGeneralCollectionViewCellDelegate {
    func didTapAndHoldOnMessage(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        
        if cellMessage.isInvalidated {return}
        
        if cellMessage.status == IGRoomMessageStatus.sending {
            return
        }
        
        self.view.endEditing(true)
        
        if cellMessage.status == IGRoomMessageStatus.failed {
            if !(IGGlobal.shouldMultiSelect) {
                manageFailedMessage(cellMessage: cellMessage, cell: cell)
            }
        } else {
            if !(IGGlobal.shouldMultiSelect) {
                manageSendedMessage(cellMessage: cellMessage, cell: cell)
                
            }
        }
    }
    func swipToReply(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        if !(IGGlobal.shouldMultiSelect) {
            
            if cellMessage.status == IGRoomMessageStatus.sending {
                return
            }
            
            self.view.endEditing(true)
            
            if cellMessage.status == IGRoomMessageStatus.failed {
            } else {
                self.forwardOrReplyMessage(cellMessage)
            }
            
        }
    }
    
    private func manageSendedMessage(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell){
        
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        let copy = UIAlertAction(title: "COPY".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.copyMessage(cellMessage)
        })
        
        var pinTitle = "PINN".MessageViewlocalizedNew
        if self.room?.pinMessage != nil && self.room?.pinMessage?.id == cellMessage.id {
            pinTitle = "UNPINN".MessageViewlocalizedNew
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
        let reply = UIAlertAction(title: "REPLY".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.forwardOrReplyMessage(cellMessage)
        })
        let forward = UIAlertAction(title: "FORWARD".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.enableMultiSelect(State: true, cellMessage: cellMessage,isForward : true,isDelete : false,isShare : false)
            
        })
        
        let edit = UIAlertAction(title: "BTN_EDITE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            if self.connectionStatus == .waitingForNetwork || self.connectionStatus == .connecting {
                let alert = UIAlertController(title: "GLOBAL_WARNING".MessageViewlocalizedNew, message: "NO_NETWORK".MessageViewlocalizedNew, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }else {
                //                self.shouldMultiSelect = true
                //MARK:-DELETE CELL
                
                self.editMessage(cellMessage)
            }
        })
        
        let share = UIAlertAction(title: "SHARE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            var finalMessage = cellMessage
            if let forward = cellMessage.forwardedFrom {
                finalMessage = forward
            }
            IGHelperPopular.shareAttachment(url: finalMessage.attachment?.path(), viewController: self)
        })
        
        let report = UIAlertAction(title: "REPORT".MessageViewlocalizedNew, style: .default, handler: { (action) in
            self.report(room: self.room!, message: cellMessage)
        })
        
        _ = UIAlertAction(title: "MORE".MessageViewlocalizedNew, style: .default, handler: { (action) in
            for visibleCell in self.collectionView.visibleCells {
                let aCell = visibleCell as! IGMessageGeneralCollectionViewCell
                aCell.setMultipleSelectionMode(true)
            }
        })
        _ = UIAlertAction(title: "BTN_DELETE".MessageViewlocalizedNew, style: .destructive, handler: { (action) in
            self.deleteMessage(cellMessage)
        })
        var deleteTitle = ""
        if self.room!.type == .group || self.room!.type == .channel {
            deleteTitle =  "BTN_DELETE".MessageViewlocalizedNew
        } else {
            deleteTitle =  "DELETE_FOR_ME".MessageViewlocalizedNew
        }
        let deleteForMe = UIAlertAction(title: deleteTitle, style: .destructive, handler: { (action) in
            self.isBoth = false
            self.enableMultiSelect(State: true, cellMessage: cellMessage,isForward : false,isDelete : true,isShare : false)
            
        })
        let roomTitle = self.room?.title != nil ? self.room!.title! : ""
        let deleteForBoth = UIAlertAction(title: "DELETE_FOR_ME_AND".MessageViewlocalizedNew + roomTitle, style: .destructive, handler: { (action) in
            //            self.deleteMessage(cellMessage, both: true)
            self.isBoth = true
            self.enableMultiSelect(State: true, cellMessage: cellMessage,isForward : false,isDelete : true,isShare : false)
            
        })
        let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: { (action) in
        })
        
        //Copy
        if allowCopy(cellMessage){
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
        switch room!.type {
        case .channel :
            break
        default:
            alertC.addAction(forward)
        }
        //Edit
        if self.allowEdit(cellMessage){
            alertC.addAction(edit)
        }
        
        //Share
        if self.allowShare(cellMessage){
            alertC.addAction(share)
        }
        
        alertC.addAction(report)
        
        //Delete
        let delete = allowDelete(cellMessage)
        if delete.singleDelete {
            alertC.addAction(deleteForMe)
        }
        if delete.bothDelete {
            alertC.addAction(deleteForBoth)
        }
        
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    func enableMultiSelect(State: Bool! ,cellMessage: IGRoomMessage ,isForward:Bool? = nil ,isDelete:Bool? = nil ,isShare:Bool? = nil) {
        IGGlobal.shouldMultiSelect = State
        self.selectedMessages.removeAll()
        self.selectedMessages.append(cellMessage)
        self.showMultiSelectUI(state: State,isForward:isForward,isDelete:isDelete)
    }
    func showMultiShareModal() {
        self.MultiShareModalIsActive = true
        
        if forwardModal == nil {
            //            blurEffectView = UIVisualEffectView(effect: blurEffect)
            //            blurEffectView.frame = view.bounds
            //            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            //            view.addSubview(blurEffectView)
            
            
            forwardModal = IGMultiForwardModal.loadFromNib()
            
            forwardModal.btnSend.addTarget(self, action: #selector(sendMultiForwardRequest), for: .touchUpInside)
            
            forwardModal!.frame = CGRect(x: 0, y: self.view.frame.height , width: self.view.frame.width, height: forwardModal.frame.height)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(IGMessageViewController.handleGesture(gesture:)))
            swipeDown.direction = .down
            
            forwardModal.addGestureRecognizer(swipeDown)
            self.view.addSubview(forwardModal!)
            //dismissView
            dissmissViewBG.frame = view.bounds
            dissmissViewBG.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(dissmissViewBG)
            dissmissViewBG.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
            let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(didTapOnDissmissView))
            dissmissViewBG.addGestureRecognizer(tapToDismiss)
            dissmissViewBG.isUserInteractionEnabled = true
            
            self.view.bringSubviewToFront(dissmissViewBG)
            
            self.view.bringSubviewToFront(forwardModal!)
            
        }
        
        if #available(iOS 11.0, *) {
            UIView.animate(withDuration: 0.3) {
                if UIDevice.current.hasNotch {
                    let tmpY = ((self.view.frame.height) - (self.forwardModal.frame.height))
                    self.forwardModal!.frame = CGRect(x: 0, y: tmpY - 44, width: self.view.frame.width, height: self.forwardModal.frame.height)
                    
                } else {
                    let tmpY = ((self.view.frame.height) - (self.forwardModal.frame.height))
                    self.forwardModal!.frame = CGRect(x: 0, y: tmpY , width: self.view.frame.width, height: self.forwardModal.frame.height)
                    
                }
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                
                if UIDevice.current.hasNotch {
                    let tmpY = ((self.view.frame.height) - (self.forwardModal.frame.height))
                    self.forwardModal!.frame = CGRect(x: 0, y: tmpY - 44, width: self.view.frame.width, height: self.forwardModal.frame.height)
                    
                } else {
                    let tmpY = ((self.view.frame.height) - (self.forwardModal.frame.height))
                    self.forwardModal!.frame = CGRect(x: 0, y: tmpY , width: self.view.frame.width, height: self.forwardModal.frame.height)
                    
                }
            }
        }
    }
    
    private func manageFailedMessage(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell){
        let alertC = UIAlertController(title: nil, message: nil, preferredStyle: IGGlobal.detectAlertStyle())
        
        let resend = UIAlertAction(title: "SEND_AGAIN".MessageViewlocalizedNew, style: .default, handler: { (action) in
            DispatchQueue.main.async {
                IGMessageSender.defaultSender.resend(message: cellMessage, to: self.room!)
            }
        })
        
        let delete = UIAlertAction(title: "BTN_DELETE".MessageViewlocalizedNew, style: .destructive, handler: { (action) in
            if let attachment = cellMessage.attachment {
                IGMessageSender.defaultSender.deleteFailedMessage(primaryKeyId: attachment.cacheID, hasAttachment: true)
            } else {
                IGMessageSender.defaultSender.deleteFailedMessage(primaryKeyId: cellMessage.primaryKeyId)
            }
            
            if let roomMessage = self.messages, let indexOfMessage = roomMessage.firstIndex(of: cellMessage) {
                self.removeItem(cellPosition: indexOfMessage)
            }
        })
        
        let cancel = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: nil)
        
        alertC.addAction(resend)
        alertC.addAction(delete)
        alertC.addAction(cancel)
        
        self.present(alertC, animated: true, completion: nil)
    }
    
    // MARK: - Start - Go to Message Position
    /**
     * if don't set 'messageIdPosition' this value automatically will be fetched from message.
     * sometimes messageId from message is not useful (for example at click of header reply state).
     * finally for globalization usage of following method 'messageIdPosition' is optional
     */
    func goToPosition(messageId: Int64 = 0, enableFastReturn: Bool = false){
        
        if enableFastReturn {
            IGMessageViewController.highlightMessageId = messageId
        } else {
            IGMessageViewController.highlightWithoutFastReturn = messageId
        }
        
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
            
            if !self.collectionView.indexPathsForVisibleItems.contains(previousIndexPath) {
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
            } else if !self.collectionView.indexPathsForVisibleItems.contains(futureIndexPath) {
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
            }
            
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
                    
                    let messageId = roomMessage?.id
                    DispatchQueue.main.async {
                        if messageId != nil {
                            self.loadMessageAfterFetch(messageId: messageId!)
                        } else {
                            self.startLoadMessage()
                        }
                    }
                }
            }
        }
    }
    
    private func loadMessageAfterFetch(messageId: Int64){
        self.clearCollectionView()
        self.messageLoader.setSavedScrollMessageId(savedScrollMessageId: messageId)
        self.startLoadMessage()
    }
    
    func notifyPosition(messageId: Int64){
        if let indexOfMessge = IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.firstIndex(of: messageId) {
            let indexPath = IndexPath(row: indexOfMessge, section: 0)
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    // MARK: - End - Go to Message Position
    
    
    /******* overrided method for show file attachment (use from UIDocumentInteractionControllerDelegate) *******/
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func didTapOnAttachment(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell, imageView: IGImageView?) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions(rawValue: UInt(0.3)), animations: {
            self.inputBarViewBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            self.inputBarViewBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            
        })
        var finalMessage = cellMessage
        var roomMessageLists = self.messagesWithMedia
        if cellMessage.forwardedFrom != nil {
            //roomMessageLists = self.messagesWithForwardedMedia
            roomMessageLists = self.messagesWithMedia
            finalMessage = cellMessage.forwardedFrom!
        }
        
        if finalMessage.type == .sticker {
            if let sticker = IGHelperJson.parseStickerMessage(data: (finalMessage.additional?.data)!) {
                stickerPageType = StickerPageType.PREVIEW
                stickerGroupId = sticker.groupId
                performSegue(withIdentifier: "showSticker", sender: self)
            }
            return
        }
        
        if finalMessage.type == .location {
            isSendLocation = false
            receivedLocation = CLLocation(latitude: (finalMessage.location?.latitude)!, longitude: (finalMessage.location?.longitude)!)
            self.performSegue(withIdentifier: "showLocationViewController", sender: self)
            return
        }
        
        var attachmetVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: finalMessage.attachment!.cacheID!)
        if attachmetVariableInCache == nil {
            let attachmentRef = ThreadSafeReference(to: finalMessage.attachment!)
            IGAttachmentManager.sharedManager.add(attachmentRef: attachmentRef)
            attachmetVariableInCache = IGAttachmentManager.sharedManager.getRxVariable(attachmentPrimaryKeyId: finalMessage.attachment!.cacheID!)
        }
        
        let attachment = attachmetVariableInCache!.value
        if attachment.status != .ready && !IGGlobal.isFileExist(path: finalMessage.attachment?.path(), fileSize: (finalMessage.attachment?.size)!) {
            return
        }
        
        switch finalMessage.type {
        case .image, .imageAndText:
            break
        case .video, .videoAndText:
            if let path = attachment.path() {
                let player = AVPlayer(url: path)
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
            if let path = attachment.path() {
                let controller = UIDocumentInteractionController()
                controller.delegate = self
                controller.url = path
                controller.presentPreview(animated: true)
            }
            return
        default:
            return
        }
        
        let thisMessageInSharedMediaResult = roomMessageLists.filter("id == \(cellMessage.id)")
        var indexOfThis = 0
        if let this = thisMessageInSharedMediaResult.first {
            indexOfThis = roomMessageLists.firstIndex(of: this)!
        }
        
        let photos: [INSPhotoViewable] = Array(roomMessageLists.map { (message) -> IGMedia in
            return IGMedia(message: message, forwardedMedia: false)
        })
        
        sizesArray.removeAll()
        indexOfVideos.removeAll()
        
        for element in roomMessageLists {
            indexOfVideos.append((element.typeRaw))
        }
        
        let currentPhoto = photos[indexOfThis]
        
        let galleryPreview = INSPhotosViewController(photos: photos, initialPhoto: currentPhoto, referenceView: imageView)
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { photo in
            return imageView
        }
        present(galleryPreview, animated: true, completion: nil)
    }
    
    func didTapOnForwardedAttachment(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        if let forwardedMsgType = cellMessage.forwardedFrom?.type {
            switch forwardedMsgType {
            case .audio , .voice :
                let musicPlayer = IGMusicViewController()
                musicPlayer.attachment = cellMessage.forwardedFrom?.attachment
                self.present(musicPlayer, animated: true, completion: {
                })
                break
            case .video, .videoAndText:
                if let path = cellMessage.forwardedFrom?.attachment?.path() {
                    let player = AVPlayer(url: path)
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
    
    func didTapOnSenderAvatar(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell) {
        if let user = cellMessage.authorUser?.user {
            self.selectedUserToSeeTheirInfo = user
            openUserProfile()
        }
    }
    
    func didTapOnHashtag(hashtagText: String) {
        
    }
    
    func didTapOnReply(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell){
        if let replyMessage = cellMessage.repliedTo {
            IGMessageViewController.returnToMessage = cellMessage
            
            var mainReplyId = replyMessage.id * -1
            if let forwardedMessage = IGRoomMessage.fetchForwardMessage(roomId: self.room!.id, messageId: replyMessage.id) {
                mainReplyId = forwardedMessage.id
            }
            goToPosition(messageId: mainReplyId, enableFastReturn: true)
        }
    }
    
    func didTapOnForward(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell){
        if let forwardMessage = cellMessage.forwardedFrom {
            var usernameType : IGPClientSearchUsernameResponse.IGPResult.IGPType = .room
            if forwardMessage.authorUser != nil {
                usernameType = .user
            }
            IGHelperChatOpener.manageOpenChatOrProfile(viewController: self, usernameType: usernameType, user: forwardMessage.authorUser?.user, room: forwardMessage.authorRoom)
        }
    }
    
    func didTapOnReturnToMessage(){
        if let message = IGMessageViewController.returnToMessage {
            IGMessageViewController.highlightWithoutFastReturn = message.id
            goToPosition(messageId: message.id)
        }
    }
    
    func didTapOnMultiForward(cellMessage: IGRoomMessage, cell: IGMessageGeneralCollectionViewCell){
        self.selectedMessages.removeAll()
        self.selectedMessages.append(cellMessage)
        showMultiShareModal()
    }
    
    func didTapOnMention(mentionText: String) {
        IGHelperChatOpener.checkUsernameAndOpenRoom(viewController: self, username: mentionText)
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
        
        IGHelperOpenLink.openLink(urlString: urlString, navigationController: self.navigationController!)
    }
    
    func didTapOnDeepLink(url: URL) {
        DeepLinkManager.shared.handleDeeplink(url: url)
        DeepLinkManager.shared.checkDeepLink()
    }
    
    func didTapOnRoomLink(link: String) {
        let strings = link.split(separator: "/")
        let token = strings[strings.count-1]
        self.requestToCheckInvitedLink(invitedLink: String(token))
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
        IGChatGetRoomRequest.Generator.generate(peerId: selectedUser.id).success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let chatGetRoomResponse as IGPChatGetRoomResponse:
                    let roomId = IGChatGetRoomRequest.Handler.interpret(response: chatGetRoomResponse)
                    
                    IGClientGetRoomRequest.Generator.generate(roomId: roomId).success({ (protoResponse) in
                        DispatchQueue.main.async {
                            switch protoResponse {
                            case let clientGetRoomResponse as IGPClientGetRoomResponse:
                                IGClientGetRoomRequest.Handler.interpret(response: clientGetRoomResponse)
                                let room = IGRoom(igpRoom: clientGetRoomResponse.igpRoom)
                                let roomVC = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                                roomVC.room = room
                                roomVC.hidesBottomBarWhenPushed = true
                                self.navigationController!.pushViewController(roomVC, animated: true)
                            default:
                                break
                            }
                            self.hud.hide(animated: true)
                        }
                    }).error ({ (errorCode, waitTime) in
                        DispatchQueue.main.async {
                            switch errorCode {
                            case .timeout:
                                let alert = UIAlertController(title: "TIME_OUT".MessageViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".MessageViewlocalizedNew, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            default:
                                break
                            }
                            self.hud.hide(animated: true)
                        }
                    }).send()
                    
                    hud.hide(animated: true)
                    break
                default:
                    break
                }
            }
            
        }).error({ (errorCode, waitTime) in
            hud.hide(animated: true)
            let alert = UIAlertController(title: "GLOBAL_WARNING".MessageViewlocalizedNew, message: "UNSSUCCESS_OTP".MessageViewlocalizedNew, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }).send()
    }
    
    func joinRoombyInvitedLink(room:IGPRoom, invitedToken: String) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGClientJoinByInviteLinkRequest.Generator.generate(invitedToken: invitedToken).success({ (protoResponse) in
            DispatchQueue.main.async {
                if let _ = protoResponse as? IGPClientJoinByInviteLinkResponse {
                    IGFactory.shared.updateRoomParticipant(roomId: room.igpID, isParticipant: true)
                    let predicate = NSPredicate(format: "id = %lld", room.igpID)
                    if let roomInfo = try! Realm().objects(IGRoom.self).filter(predicate).first {
                        self.openChatAfterJoin(room: roomInfo)
                    }
                }
                self.hud.hide(animated: true)
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    let alert = UIAlertController(title: "TIME_OUT".MessageViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".MessageViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                case .clientJoinByInviteLinkForbidden:
                    let alert = UIAlertController(title: "GLOBAL_WARNING", message: "GROUP_DOES_NOT_EXIST".MessageViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                    
                case .clientJoinByInviteLinkAlreadyJoined:
                    self.openChatAfterJoin(room: IGRoom(igpRoom: room), before: true)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
        }).send()
        
    }
    func requestToCheckInvitedLink(invitedLink: String) {
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGClinetCheckInviteLinkRequest.Generator.generate(invitedToken: invitedLink).success({ (protoResponse) in
            DispatchQueue.main.async {
                self.hud.hide(animated: true)
                if let clinetCheckInvitedlink = protoResponse as? IGPClientCheckInviteLinkResponse {
                    IGClinetCheckInviteLinkRequest.Handler.interpret(response: clinetCheckInvitedlink)
                    let alert = UIAlertController(title: "iGap", message: "ARE_U_SURE_TO_JOIN".MessageViewlocalizedNew + "\n \(clinetCheckInvitedlink.igpRoom.igpTitle)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: { (action) in
                        self.joinRoombyInvitedLink(room:clinetCheckInvitedlink.igpRoom, invitedToken: invitedLink)
                    })
                    let cancelAction = UIAlertAction(title: "CANCEL_BTN".MessageViewlocalizedNew, style: .cancel, handler: nil)
                    
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }).error ({ (errorCode, waitTime) in
            DispatchQueue.main.async {
                switch errorCode {
                case .timeout:
                    
                    let alert = UIAlertController(title: "TIME_OUT".MessageViewlocalizedNew, message: "MSG_PLEASE_TRY_AGAIN".MessageViewlocalizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                default:
                    break
                }
                self.hud.hide(animated: true)
            }
            
        }).send()
    }
    
    private func openChatAfterJoin(room: IGRoom, before:Bool = false){
        
        var beforeString = ""
        if before {
            beforeString = "before "
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "SUCCESS".MessageViewlocalizedNew, message: "U_JOINED".MessageViewlocalizedNew + " \(beforeString)" + "TO".MessageViewlocalizedNew + " \(room.title!)!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "GLOBAL_OK".MessageViewlocalizedNew, style: .default, handler: nil)
            let openNow = UIAlertAction(title: "OPEN_NOW".MessageViewlocalizedNew, style: .default, handler: { (action) in
                let chatPage = IGMessageViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
                chatPage.room = room
                chatPage.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(chatPage, animated: true)
            })
            alert.addAction(okAction)
            alert.addAction(openNow)
            self.present(alert, animated: true, completion: nil)
        }
    }
}



//MARK: - StatusBar Tap
extension IGMessageViewController {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func addNotificationObserverForTapOnStatusBar() {
        NotificationCenter.default.addObserver(forName: IGNotificationStatusBarTapped.name, object: .none, queue: .none) { _ in
            if self.collectionView.contentSize.height < self.collectionView.frame.height {
                return
            }
            //1200 is just an arbitrary number. can be anything
            let newOffsetY = min(self.collectionView.contentOffset.y + 1200, self.collectionView.contentSize.height - self.collectionView.frame.height + self.collectionView.contentInset.bottom)
            let newOffsett = CGPoint(x: 0, y: newOffsetY)
            self.collectionView.setContentOffset(newOffsett , animated: true)
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
    
    //    Capturing Image
    //    Capturign Video
    //    Sending Gif
    //    Sending Location
    //    Choosing Contact
    //    Painting
    
}
extension String {
    func chopPrefix(_ count: Int = 1) -> String {
        return substring(from: index(startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return substring(to: index(endIndex, offsetBy: -count))
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



extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}



/************************************************************************************/
/********************************** Message Loader **********************************/
/************************************************************************************/

extension IGMessageViewController: MessageOnChatReceiveObserver {
    
    /*************************************************************************/
    /******************************* Observers *******************************/
    
    func onMessageRecieveInChatPage(roomId: Int64, message: IGPRoomMessage, roomType: IGPRoom.IGPType) {
        if roomType == .chat && self.currentRoomId == roomId {
            IGGlobal.playSound(isInChat : IGGlobal.isInChatPage,isSilent : IGGlobal.isSilent,isSendMessage: false)
        }
        
        // if message is for another room shouldn't be add to current room
        if self.currentRoomId != roomId {return}
        
        /**
         * set "firstLoadDown" to false value for avoid from scroll to top after receive/send message
         * from current callback when not loaded before any message from get history callback
         * Hint-TODO : do better action if is possible instead set false after each message
         */
        self.messageLoader.setFirstLoadDown(firstLoadDown : false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let message = IGRoomMessage.getMessageWithId(messageId: message.igpMessageID) {
                self.addChatItem(realmRoomMessages: [message], direction: IGPClientGetRoomHistory.IGPDirection.down)
            }
        }
    }
    
    func onMessageUpdate(roomId: Int64, message: IGPRoomMessage, identity: IGRoomMessage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let roomMessage = self.messages {
                var indexOfMessage = 0
                if let index = roomMessage.firstIndex(of: identity) {
                    indexOfMessage = index
                }
                self.updateMessageArray(cellPosition: indexOfMessage, message: IGRoomMessage(igpMessage: message, roomId: roomId))
                self.updateItem(cellPosition: indexOfMessage)
            }
        }
    }
    
    func onMessageUpdateStatus(messageId: Int64) {
        if self.room == nil || self.room!.isInvalidated {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let messages = IGMessageViewController.messageIdsStatic[(self.room?.id)!]
            if messages == nil {
                return
            }
            if let indexOfMessage = messages!.firstIndex(of: messageId) {
                if let message = IGRoomMessage.getMessageWithId(messageId: messageId) {
                    self.updateMessageArray(cellPosition: indexOfMessage, message: message)
                    self.updateItem(cellPosition: indexOfMessage)
                }
            }
        }
    }
    
    func onChannelGetMessageState(roomId: Int64){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.room!.id == roomId {
                self.reloadCollection()
            }
        }
    }
    
    func onLocalMessageUpdateStatus(localMessage: IGRoomMessage) {
        if self.room == nil || self.room!.isInvalidated || localMessage.isInvalidated {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let messages = IGMessageViewController.messageIdsStatic[(self.room?.id)!]
            if messages == nil {
                return
            }
            
            if let roomMessage = self.messages, let indexOfMessage = roomMessage.firstIndex(of: localMessage) {
                if let newMessage = IGRoomMessage.getMessageWithPrimaryKeyId(primaryKeyId: localMessage.primaryKeyId!) {
                    self.updateMessageArray(cellPosition: indexOfMessage, message: newMessage)
                    self.updateItem(cellPosition: indexOfMessage)
                    
                    if newMessage.status == IGRoomMessageStatus.sending {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            let message = IGRoomMessage.makeCopyOfMessage(message: newMessage)
                            if message.type == .sticker {
                                IGMessageSender.defaultSender.sendSticker(message: newMessage, to: self.room!)
                            } else {
                                IGMessageSender.defaultSender.send(message: newMessage, to: self.room!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onMessageEdit(messageId: Int64, roomId: Int64, message: String, messageType: IGPRoomMessageType, messageVersion: Int64) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            /* this messageId updated so after get this message from realm it has latest update */
            if let newMessage = IGRoomMessage.getMessageWithId(messageId: messageId) {
                if let position = IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.firstIndex(of: messageId) {
                    self.updateMessageArray(cellPosition: position, message: newMessage)
                    self.updateItem(cellPosition: position)
                }
            }
        }
    }
    
    func onMessageDelete(roomId: Int64, messageId: Int64) {
        DispatchQueue.main.async {
            self.removeItem(cellPosition: IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.firstIndex(of: messageId))
        }
    }
    
    func onFetchUserInfo(userId: Int64){
        /* fetch user info and notify collection item if exist in visible items into the collection */
        IGUserInfoRequest.sendRequestAvoidDuplicate(userId: userId) { (userInfo) in
            DispatchQueue.main.async {
                for indexPath in self.collectionView.indexPathsForVisibleItems {
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? AbstractCell {
                        if let peerId = cell.realmRoomMessage.authorUser?.userId, userInfo.igpID == peerId {
                            self.updateItem(cellPosition: indexPath.row)
                        }
                    }
                }
            }
        }
    }
    
    /*********************************************************************************/
    /******************* Collection Manager (Add , Remove , Update) ******************/
    
    /* scroll to bottom as default for send message (Text Message/File Message) */
    func addChatItem(realmRoomMessages: [IGRoomMessage], direction: IGPClientGetRoomHistory.IGPDirection, scrollToBottom: Bool = true){
        if realmRoomMessages.count == 0 {
            return
        }
        
        if scrollToBottom && !self.messageLoader.allowAddToView() {
            // in this state (mabye all stats) when "scrollToBottom" is true, "realmRoomMessages" just has one item
            if let authorHash = realmRoomMessages[0].authorHash, authorHash == IGAppManager.sharedManager.authorHash() {
                resetAndGetFromEnd()
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            if let pos = IGMessageViewController.messageIdsStatic[(self.room?.id)!]?.firstIndex(of: updateMessageId) {
                                self.updateItem(cellPosition: pos)
                            }
                        }
                    }
                }
            }
        } else { // Down Direction
            if self.messageLoader.isFirstLoadDown() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.appendMessageArray(realmRoomMessages, direction)
                    self.addChatItemToBottom(count: realmRoomMessages.count, scrollToBottom: scrollToBottom)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let bottomOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - self.collectionView.bounds.size.height)
                        self.collectionView.setContentOffset(bottomOffset, animated: false)
                    }
                    self.messageLoader.setFirstLoadDown(firstLoadDown : false)
                    self.messageLoader.setWaitingHistoryDownLocal(isWaiting: false)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.appendMessageArray(realmRoomMessages, direction)
                    self.addChatItemToBottom(count: realmRoomMessages.count, scrollToBottom: scrollToBottom)
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
        let contentHeight = self.collectionView!.contentSize.height
        let offsetY = self.collectionView!.contentOffset.y
        let bottomOffset = contentHeight - offsetY
        
        if !scrollToBottom {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        
        self.collectionView?.performBatchUpdates({
            var arrayIndex: [IndexPath] = []
            
            for index in 0...(count-1) {
                arrayIndex.append(IndexPath(row: index, section: 0))
            }
            
            self.collectionView?.insertItems(at: arrayIndex)
        }, completion: { _ in
            if !scrollToBottom {
                self.collectionView!.contentOffset = CGPoint(x: 0, y: self.collectionView!.contentSize.height - bottomOffset)
                CATransaction.commit()
            }
        })
    }
    
    private func addChatItemToTop(count: Int) {
        self.collectionView?.performBatchUpdates({
            var arrayIndex: [IndexPath] = []
            
            for index in 0...(count-1) {
                arrayIndex.append(IndexPath(row: (messages!.count-count)+index, section: 0))
            }
            
            self.collectionView?.insertItems(at: arrayIndex)
        }, completion: nil)
    }
    
    private func removeItem(cellPosition: Int?){
        if cellPosition == nil {return}
        DispatchQueue.main.async {
            self.removeMessageArrayByPosition(cellPosition: cellPosition)
            self.collectionView?.performBatchUpdates({
                self.collectionView?.deleteItems(at: [IndexPath(row: cellPosition!, section: 0)])
            }, completion: nil)
        }
    }
    
    private func updateItem(cellPosition: Int){
        if self.messages!.count <= cellPosition  {
            return
        }
        
        self.collectionView.reloadItems(at: [IndexPath(row: cellPosition, section: 0)])
    }
    
    /*********************************************************************************/
    /******************************** Popular Methods ********************************/
    
    private func appendMessageArray(_ messages: [IGRoomMessage], _ direction: IGPClientGetRoomHistory.IGPDirection){
        if IGMessageViewController.messageIdsStatic[(self.room?.id)!] == nil {
            IGMessageViewController.messageIdsStatic[(self.room?.id)!] = []
        }
        
        if direction == .up {
            for message in messages {
                self.messages!.append(message)
                IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.append(message.id)
            }
        } else {
            for message in messages {
                self.messages!.insert(message, at: 0)
                IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.insert(message.id, at: 0)
            }
        }
    }
    
    private func appendAtSpecificPosition(_ message: IGRoomMessage, cellPosition: Int){
        if self.messages!.count <= cellPosition  {
            return
        }
        
        self.messages!.insert(message, at: cellPosition)
        IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.insert(message.id, at: cellPosition)
        
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItems(at: [IndexPath(row: cellPosition, section: 0)])
        }, completion: nil)
    }
    
    private func removeMessageArray(messageId: Int64){
        if let index = IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.firstIndex(of: messageId) {
            IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.remove(at: index)
        }
    }
    
    private func removeMessageArrayByPosition(cellPosition: Int?){
        if cellPosition != nil && self.messages!.count <= cellPosition!  {
            return
        }
        
        self.messages?.remove(at: cellPosition!)
        IGMessageViewController.messageIdsStatic[(self.room?.id)!]!.remove(at: cellPosition!)
    }
    
    private func updateMessageArray(cellPosition: Int, message: IGRoomMessage){
        if self.messages!.count <= cellPosition  {
            return
        }
        
        self.messages![cellPosition] = message
        IGMessageViewController.messageIdsStatic[(self.room?.id)!]![cellPosition] = message.id
    }
    
    private func makeTimeItem(date: Date) -> IGRoomMessage {
        let message = IGRoomMessage(body: date.localizedDate().inLocalizedLanguage())
        message.type = .time
        return message
    }
    
    private func resetAndGetFromEnd(){
        self.scrollToBottomContainerView.isHidden = true
        self.clearCollectionView()
        self.startLoadMessage()
    }
    
    private func clearCollectionView(){
        self.messageLoader.resetMessagingValue()
        self.messages?.removeAll()
        IGMessageViewController.messageIdsStatic.removeAll()
        reloadCollection()
        self.collectionView.contentOffset = .zero
    }
    
    private func reloadCollection(){
        self.collectionView.reloadData()
        self.collectionView.numberOfItems(inSection: 0) //<-- This code is no used, but it will let UICollectionView synchronize number of items, so it will not crash in following code.
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
        let visibleCells = self.collectionView.indexPathsForVisibleItems.sorted(by:{
            $0.section < $1.section || $0.row < $1.row
        }).compactMap({
            self.collectionView.cellForItem(at: $0)
        })
        
        if visibleCells.count > 0, self.collectionView.indexPath(for: visibleCells[0])!.row > IGMessageLoader.STORE_MESSAGE_POSITION_LIMIT {
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
