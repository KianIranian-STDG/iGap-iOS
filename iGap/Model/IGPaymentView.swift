/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation
import SwiftEventBus

enum PaymentStatus: String {
    case canceledByUser = "CANCELED_BY_USER"
    case failure = "FAILURE"
    case moneyReversed = "MONEY_REVERSED"
    case pending = "PENDING"
    case success = "SUCCESS"
}

class IGPaymentView: UIView {
    /// Sigltone object
    static var sharedInstance = IGPaymentView()
    
    // MARK: - Outlets
    @IBOutlet var containerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var topIconView: UIView!
    @IBOutlet var topIconLbl: UILabel!
    @IBOutlet var mainSV: UIStackView!
    @IBOutlet var descriptionSV: UIStackView!
    @IBOutlet var costSV: UIStackView!
    @IBOutlet var statusSV: UIStackView!
    @IBOutlet var acceptBtn: UIButton!
    @IBOutlet var cancelBtn: UIButton!
    // LAbels
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var subTitleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var amountDescriptionLbl: UILabel!
    @IBOutlet var amountLbl: UILabel!
    @IBOutlet var statusDescriptionLbl: UILabel!
    @IBOutlet var statusCodeLbl: UILabel!
    @IBOutlet var errorMessageLbl: UILabel!
    
    // MARK: - Variables
    private var parentView: UIView!
    /// define a variable to store initial touch position on pan gesture
    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    var payToken: String!
    private var title: String!
    private var paymentData: IGStructPayment!
    private var giftCardPaymentData: IGStructGiftCardPayment!
    private var paymentStatus: PaymentStatus? = nil
    private var orderId: String? = nil
    
    // MARK: - Init functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("IGPaymentView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        setupInitialUI()
        
        //        addPanGesture()
    }
    
    private func setupInitialUI() {
        self.topIconView.layer.cornerRadius = self.topIconView.bounds.height / 2
        self.acceptBtn.layer.cornerRadius = self.acceptBtn.bounds.height / 2
        self.cancelBtn.layer.cornerRadius = self.cancelBtn.bounds.height / 2
        self.contentView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
    }
    
    
    
    // MARK: - User functions
    func showGiftCardPayment(on parentView: UIView, title: String, payment: IGStructGiftCardPayment) {
        parentView.endEditing(true)
        self.parentView = parentView
        self.title = title
        self.giftCardPaymentData = payment
        parentView.addSubview(self)
        parentView.addMaskView() {
            self.hideView()
        }
        self.frame.size = CGSize(width: parentView.frame.width, height: contentView.bounds.height)
        self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height , width: parentView.frame.width, height: self.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height - self.contentView.bounds.height, width: parentView.frame.width, height: self.contentView.bounds.height)
        }
        parentView.bringSubviewToFront(self)
        
        self.topIconLbl.text = ""
        self.topIconLbl.textColor = ThemeManager.currentTheme.LabelColor
        
        self.titleLbl.text = title
        self.subTitleLbl.text = payment.info.product.title
        self.descriptionLbl.text = payment.info.product.productDescription
        self.amountDescriptionLbl.text = IGStringsManager.AmountPlaceHolder.rawValue.localized
        self.amountLbl.text = "\(payment.info.price)".onlyDigitChars().inRialFormat()
        
        self.mainSV.isHidden = false
        self.statusSV.isHidden = true
        self.acceptBtn.isHidden = false
        self.cancelBtn.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
        self.acceptBtn.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        self.cancelBtn.backgroundColor = UIColor.iGapRed()
        
        self.errorMessageLbl.isHidden = true
    }
    
    /// show payment view modal
    func show(on parentView: UIView, title: String, payToken: String, payment: IGStructPayment) {
        parentView.endEditing(true)
        self.parentView = parentView
        self.title = title
        self.payToken = payToken
        self.paymentData = payment
        parentView.addSubview(self)
        parentView.addMaskView() {
            // on maske view hide
            self.hideView()
        }
        self.frame.size = CGSize(width: parentView.frame.width, height: contentView.bounds.height)
        self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height , width: parentView.frame.width, height: self.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height - self.contentView.bounds.height, width: parentView.frame.width, height: self.contentView.bounds.height)
        }
        parentView.bringSubviewToFront(self)
        
        self.topIconLbl.text = ""
        self.topIconLbl.textColor = ThemeManager.currentTheme.LabelColor
        
        self.titleLbl.text = title
        if let apiTitle = payment.info.product?.title {
            self.subTitleLbl.text = apiTitle
        }
        if let description = payment.info.product?.description {
            self.descriptionLbl.text = description
        }
        self.amountDescriptionLbl.text = IGStringsManager.AmountPlaceHolder.rawValue.localized
        if let price = payment.info.price {
            self.amountLbl.text = "\(price)".onlyDigitChars().inRialFormat()
        }
        
        self.mainSV.isHidden = false
        self.statusSV.isHidden = true
        self.acceptBtn.isHidden = false
        self.cancelBtn.setTitle(IGStringsManager.GlobalCancel.rawValue.localized, for: .normal)
        self.acceptBtn.setTitle(IGStringsManager.Pay.rawValue.localized, for: .normal)
        self.cancelBtn.backgroundColor = UIColor.iGapRed()
        
        self.errorMessageLbl.isHidden = true
    }
    
    /// show paymentview with payment result
    func showPaymentResult(on parentView: UIView, paymentStatusData: IGStructPaymentStatus, paymentStatus: PaymentStatus? = nil, message: String) {
        
        self.paymentStatus = paymentStatus
        self.orderId = paymentStatusData.info?.orderId
        
        parentView.endEditing(true)
        self.parentView = parentView
        self.title = paymentStatusData.info?.product?.title
        self.payToken = nil
        //        self.paymentData = paymentData
        parentView.addSubview(self)
        parentView.addMaskView() {
            // on maske view hide
            self.hideView()
        }
        self.frame.size = CGSize(width: parentView.frame.width, height: contentView.bounds.height)
        self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height , width: parentView.frame.width, height: self.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height - self.contentView.bounds.height, width: parentView.frame.width, height: self.contentView.bounds.height)
        }
        parentView.bringSubviewToFront(self)
        
        self.titleLbl.text = self.title
        if let apiTitle = paymentStatusData.info?.product?.title {
            self.subTitleLbl.text = apiTitle
        }
        if let description = paymentStatusData.info?.product?.description {
            self.descriptionLbl.text = description
        }
        self.amountDescriptionLbl.text = IGStringsManager.AmountPlaceHolder.rawValue.localized
        if let price = paymentStatusData.info?.price {
            self.amountLbl.text = "\(price)".onlyDigitChars()
        }
        
        guard let status = paymentStatusData.status else { return }
        self.reloadPaymentResult(status: PaymentStatus(rawValue: status) ?? .failure, message: message, RRN: "\(paymentStatusData.info?.rrn ?? 0)")
    }
    
    /// reload payment view on payment result
    func reloadPaymentResult(status: PaymentStatus, message: String, RRN: String) {
        self.mainSV.isHidden = false
        self.statusSV.isHidden = false
        self.statusDescriptionLbl.text = message
        self.statusCodeLbl.text = IGStringsManager.TransactionIdentifier.rawValue.localized + " : " + RRN.inLocalizedLanguage()
        
        self.errorMessageLbl.isHidden = true
        self.acceptBtn.isHidden = true
        self.cancelBtn.setTitle(IGStringsManager.GlobalClose.rawValue.localized, for: .normal)
        
        switch status {
            
        case .canceledByUser:
            self.topIconLbl.text = ""
            self.topIconLbl.textColor = UIColor.iGapRed()
            self.statusCodeLbl.isHidden = true
            self.cancelBtn.backgroundColor = UIColor.iGapRed()
            
        case .failure:
            self.topIconLbl.text = ""
            self.topIconLbl.textColor = UIColor.iGapRed()
            self.statusCodeLbl.isHidden = true
            self.cancelBtn.backgroundColor = UIColor.iGapRed()
            
        case .moneyReversed:
            self.topIconLbl.text = ""
            self.topIconLbl.textColor = UIColor.iGapRed()
            self.statusCodeLbl.isHidden = true
            self.cancelBtn.backgroundColor = UIColor.iGapRed()
            
        case .pending:
            self.topIconLbl.text = ""
            self.topIconLbl.textColor = UIColor.iGapGreen()
            self.statusCodeLbl.isHidden = false
            self.cancelBtn.backgroundColor = UIColor.iGapGreen()
            
        case .success:
            self.topIconLbl.text = ""
            self.topIconLbl.textColor = UIColor.iGapGreen()
            self.statusCodeLbl.isHidden = false
            self.cancelBtn.backgroundColor = UIColor.iGapGreen()
            
        }
    }
    
    /// show payment view modal with error
    func showOnErrorMessage(on parentView: UIView, title: String, message: String, payToken: String? = nil) {
        parentView.endEditing(true)
        self.parentView = parentView
        self.title = title
        self.payToken = payToken
        parentView.addSubview(self)
        parentView.addMaskView() {
            // on maske view hide
            self.hideView()
        }
        self.frame.size = CGSize(width: parentView.frame.width, height: contentView.bounds.height)
        self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height , width: parentView.frame.width, height: self.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: parentView.frame.minX, y: parentView.frame.height - self.contentView.bounds.height, width: parentView.frame.width, height: self.contentView.bounds.height)
        }
        parentView.bringSubviewToFront(self)
        
        self.errorMessageLbl.isHidden = false
        self.errorMessageLbl.text = message
        
        self.topIconLbl.text = ""
        self.topIconLbl.textColor = UIColor.iGapYellow()
        
//        self.titleLbl.isHidden = true
        self.titleLbl.text = title
        
        self.mainSV.isHidden = true
        self.statusSV.isHidden = true
        
        self.acceptBtn.isHidden = true
        self.cancelBtn.setTitle(IGStringsManager.GlobalClose.rawValue.localized, for: .normal)
        self.cancelBtn.backgroundColor = UIColor.iGapYellow()
    }
    
    func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizerHandler(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc private func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y - initialTouchPoint.y >= 0 {
                self.frame.origin = CGPoint(x: 0, y: (self.parentView.frame.height - self.contentView.bounds.height) + touchPoint.y - initialTouchPoint.y)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin = CGPoint(x: 0, y: self.parentView.frame.height - self.contentView.bounds.height)
                })
            }
            
        case .ended, .cancelled :
            if touchPoint.y - initialTouchPoint.y >= 0, touchPoint.y - initialTouchPoint.y > self.frame.height/3 {
                self.hideView()
                
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.frame.origin = CGPoint(x: 0, y: self.parentView.frame.height - self.contentView.bounds.height)
                })
            }
            
        case .possible:
            break
            
        case .failed:
            break
            
        @unknown default:
            return
        }
    }
    
    /// hides the view
    func hideView() {
        self.superview?.hideMaskView()
        UIView.animate(withDuration: 0.3, animations: {
            self.frame.origin.y += self.frame.height
        }) { (_) in
            self.removeFromSuperview()
        }
        
        if self.paymentStatus != nil && self.orderId != nil && IGStickerViewController.waitingGiftCardInfo.orderId == self.orderId {
            SwiftEventBus.post(EventBusManager.giftCardPayment, sender: paymentStatus)
            self.paymentStatus = nil
            self.orderId = nil
        }
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: UIButton) {
        hideView()
    }
    
    @IBAction func payTapped(_ sender: UIButton) {
        var url = paymentData?.redirectUrl
        if url == nil {
            url = giftCardPaymentData?.redirectURL
        }
        
        if url != nil {
            if let url = URL(string: url!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

extension UIView {
    
    // add mask to view
    public func addMaskView(on hid: @escaping () -> ()) {
        let maskingView = UIView(frame: self.bounds)
        maskingView.accessibilityIdentifier = "maskingViewId"
        maskingView.backgroundColor = .clear
        maskingView.addTapGestureRecognizer(action: { [weak self] in
            guard let `self` = self else {return}
            self.hideMaskView()
            hid()
        })
        self.addSubview(maskingView)
        maskingView.fillToSuperView()
        UIView.animate(withDuration: 0.2, animations: {
            maskingView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        })
    }
    
    func hideMaskView() {
        self.subviews.forEach { (subview) in
            if subview.accessibilityIdentifier == "maskingViewId" {
                UIView.animate(withDuration: 0.2, animations: {
                    subview.backgroundColor = .clear
                }) { (_) in
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    // src : https://medium.com/@sdrzn/adding-gesture-recognizers-with-closures-instead-of-selectors-9fb3e09a8f0b
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }
    
    fileprivate typealias Action = (() -> Void)?
    
    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    
    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
    
    func fillToSuperView(){
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
}
