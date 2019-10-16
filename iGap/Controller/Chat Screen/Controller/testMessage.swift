//
//  testMessage.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 10/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class testMessage: UIViewController,UITextViewDelegate {
    // MARK: - Outlets

    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var btnSticker: UIButton!
    @IBOutlet weak var btnMic: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnMoney: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnTrash: UIButton!
    @IBOutlet weak var btnStickerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!

    // MARK: - view life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewNewChatView()
        initNotificationsNewChatView()
        initFontsNewChatView()
        initAlignmentsNewChatView()
        initChangeLanguegeNewChatView()
        initDelegatesNewChatView()

    }
    // MARK: - view initialisers
    ///Delegates
    private func initDelegatesNewChatView() {
        messageTextView.delegate = self
    }
    ///view initialisers
    private func initViewNewChatView() {
        self.hideKeyboardWhenTappedAround()
        self.btnMic.isHidden = false
        self.btnMoney.isHidden = false
        self.btnAttachment.isHidden = false

        self.btnSend.isHidden = true
        self.btnShare.isHidden = true
        self.btnTrash.isHidden = true
        self.btnForward.isHidden = true



    }
    ///setting fonts in here
    private func initFontsNewChatView() {
        messageTextView.font = UIFont.igFont(ofSize: 15)
        lblPlaceHolder.font = UIFont.igFont(ofSize: 15,weight: .bold)
    }
    ///setting alignments based on language of app
    private func initAlignmentsNewChatView() {
        lblPlaceHolder.textAlignment = lblPlaceHolder.localizedNewDirection
//        messageTextView.textAlignment = messageTextView.localizedNewDirection
    }
    ///setting Strings based on language of App
    private func initChangeLanguegeNewChatView() {
        lblPlaceHolder.text = "MESSAGE".MessageViewlocalizedNew

    }
    ///Notifications initialisers
    private func initNotificationsNewChatView() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(IGMessageViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(IGMessageViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Development funcs
    //        inputTextView.setContentOffset(.zero, animated: true)
    //        inputTextView.scrollRangeToVisible(NSMakeRange(0, 0))

    
    ///Notification funcs for handling what happens to View when showing or hiding  keyboard
    @objc func keyboardWillShow(notification: Notification) {

        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let keyboardHeight = keyboardSize?.height
        if #available(iOS 11.0, *){
            self.messageTextViewBottomConstraint.constant = keyboardHeight! * -1
        }
         else {
              self.messageTextViewBottomConstraint.constant = view.safeAreaInsets.bottom
            }
          UIView.animate(withDuration: 0.5){

             self.view.layoutIfNeeded()

          }
      }

     @objc func keyboardWillHide(notification: Notification){
         self.messageTextViewBottomConstraint.constant =  0
          UIView.animate(withDuration: 0.5){
             self.view.layoutIfNeeded()
          }
     }

    private func showHideStickerButton(shouldShow : Bool!) {
        if shouldShow {
            
            UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.btnSticker.isHidden = false
                self.btnStickerWidthConstraint.constant = 25.0

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
            btnTrash.isHidden = false
        } else {
            btnTrash.isHidden = true

        }
    }
    ///Handle Show hide of forward button
    func handleShowHideForwardButton(shouldShow : Bool!) {
        if shouldShow {
            btnForward.isHidden = false
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
        } else {
            btnSend.isHidden = true
        }
    }
    ///Handle Show hide of Money button
    func handleShowHideMoneyButton(shouldShow : Bool!) {
        if shouldShow {
            btnMoney.isHidden = false
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
            btnShare.isHidden = false
        } else {
            btnShare.isHidden = true
        }
    }

    // MARK: - TextView Development Delegate funcs

    var previousRect = CGRect.zero

    func textViewDidChange(_ textView: UITextView) {

        if textView.text == "" || textView.text.isEmpty {
            lblPlaceHolder.isHidden = false
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
            print("numberofLines",numLines)
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
                
            }
            
//            let pos = textView.endOfDocument
//            let currentRect = textView.caretRect(for: pos)
//            self.previousRect = self.previousRect.origin.y == 0.0 ? currentRect : self.previousRect
//
//            if previousRect != CGRect.zero {
//                if currentRect.origin.y > previousRect.origin.y {
//                    print("new line")
//
//                    if self.messageTextViewHeightConstraint.constant < 250 {
//                    UIView.animate(withDuration: 0.5, animations: {
//                        self.messageTextViewHeightConstraint.constant += 15
//                    })
//                    } else {
//
//                    }
//
//                } else if (currentRect.origin.y < previousRect.origin.y)  {
//                    print("past line")
//
//                    if messageTextViewHeightConstraint.constant > 50 {
//                        UIView.animate(withDuration: 0.5, animations: {
//                            self.messageTextViewHeightConstraint.constant -= 15
//                        })
//                    } else {
//                        print("Original Size")
//                    }
//                } else {
//                        print("current line")
//                }
//            }
//            self.previousRect = currentRect

        }
    }
}
