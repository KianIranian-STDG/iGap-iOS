//
//  customeViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 10/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class customeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var textViewHolderConstraint : NSLayoutConstraint!
    @IBOutlet weak var stickerViewConstraint : NSLayoutConstraint!
    @IBOutlet weak var textViewHolder : UIView!
    var previousRect = CGRect.zero

    override func viewDidLoad(){
        self.hideKeyboardWhenTappedAround()
//        textView.delegate = self
    }

    func textViewDidChange(_ textView: UITextView) {
        let pos = textView.endOfDocument
        let currentRect = textView.caretRect(for: pos)
        if textView.text.isEmpty {
            UIView.animate(withDuration: 0.5, animations: {
                    self.stickerViewConstraint.constant = 32
                    self.textViewHolderConstraint.constant = 32
            })
        } else {
            if self.stickerViewConstraint.constant != 0 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.stickerViewConstraint.constant = 0
                })
            }
        }
        if previousRect != CGRect.zero {
            if currentRect.origin.y > previousRect.origin.y {
                print("new line")
                if self.textViewHolderConstraint.constant < 256 {

                UIView.animate(withDuration: 0.5, animations: {
                    self.textViewHolderConstraint.constant += 16
                })
                }
                
            } else if (currentRect.origin.y < previousRect.origin.y)  {
                print("past line")
                if textViewHolderConstraint.constant > 32 {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.textViewHolderConstraint.constant -= 16
                    })
                } else {
                    print("Original Size")
                }
            } else {
                print("current line")

            }
        }
        previousRect = currentRect
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
//        if text.contains(UIPasteboard.general.string ?? "") {
//            return true
//        }
        print(numberOfChars)
        return numberOfChars < 4096
    }

}

