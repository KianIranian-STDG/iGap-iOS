//
//  MainViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 5/18/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//


import UIKit
import RxSwift

class MainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var disposeBag = DisposeBag()
    
    var isRTL: Bool {
        get {
            return LocaleManager.isRTL
        }
    }
    
    var transform: CGAffineTransform {
        get {
            return LocaleManager.transform
        }
    }
    
    var semantic: UISemanticContentAttribute {
        get {
            return LocaleManager.semantic
        }
    }
    
    var TextAlignment: NSTextAlignment {
        get {
            return LocaleManager.TextAlignment
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.hideKeyboardWhenTappedAround()
        self.view.backgroundColor = ThemeManager.currentTheme.BackGroundColor
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    private var orgContentSize : CGSize!
    private var isPresented: Bool = false
    @objc private func keyboardWillShow(_ notif: Notification) {
        
        guard let keyboardFrame: NSValue = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        if !isPresented {
            let myViews = UIApplication.topViewController()!.view.subviews.compactMap{$0 as? IGScrollView}

            if myViews.count > 0 {
                let sv = myViews.first
                sv!.changeContentSize(height: sv!.contentSize.height + keyboardHeight, width: view.frame.width)

            } else { }
            isPresented = true
        }
    }
    
    @objc private func keyboardWillHide(_ notif: Notification) {
        guard let keyboardFrame: NSValue = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let myViews = UIApplication.topViewController()!.view.subviews.compactMap{$0 as? IGScrollView}
        
        if myViews.count > 0 {
            let sv = myViews.first
            sv!.changeContentSize(height: sv!.contentSize.height - keyboardHeight, width: view.frame.width)
        } else {}
        isPresented = false

        
    }

    
    func initNavigationBar(title: String? = nil, rightItemText: String? = nil, iGapFont: Bool = false, rightAction: @escaping () -> ()) {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: rightItemText, title: title, iGapFont: iGapFont)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        navigationItem.rightViewContainer?.addAction(rightAction)
    }
    
    func initCustomtNav(title: String? = nil,font : UIFont = UIFont.igFont(ofSize: 17.0, weight: .bold)) {
        let barButton = IGHelperCustomNavigation.shared.createLeftButton()
        let titleView = IGHelperCustomNavigation.shared.createTitle(title: title,font : font)
        UIApplication.topViewController()!.navigationItem.titleView = titleView
        UIApplication.topViewController()!.navigationItem.leftBarButtonItem = barButton
        
    }

}
