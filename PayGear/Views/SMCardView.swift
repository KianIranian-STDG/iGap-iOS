//
//  SMCardView.swift
//  PayGear
//
//  Created by a on 4/11/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import Wallet
import webservice

protocol VCPayDelegate {
    func finishPassing(card : SMCardView)
    
}
protocol HandleDefaultCard {
    func finishDefault(isPaygear : Bool? ,isCard : Bool?)
	func valueChanged(value: Bool)
}


class SMBaseCardView: CardView {
    
    
    
    var delegate: VCPayDelegate?
    var defaultDelegate:HandleDefaultCard?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.onCreate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.onCreate()
    }
    
    func onCreate(){
        
        self.addSubviews()
        self.setStyle()
        
    }
    
    func addSubviews(){}
    
    
    var hasShadow = false
    
    
    func setStyle(){
        if self.hasShadow == false {
            backgroundColor = UIColor.clear
            layer.cornerRadius = 5
            layer.shadowRadius = 10
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 3, height: 8)
            layer.shadowOpacity = 0.5
            self.clipsToBounds = true
            self.hasShadow = true
        }
    }
}





class SMCardView: SMBaseCardView, DefaultStatus {
    
    var card:SMCard = SMCard(){
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
            setStyle()
        }
    }
    
    var bankNameLabel: UILabel?
    var numberLabel: UILabel?
    var ownerNameLabel: UILabel?
    var bankLogoImage: UIImageView?
    var cardGradientLayer: SMCardGradient?
    var removeCardViewButton: SMBottomButton?
    var isDefaultView: SMIsDefaultCard?
    var selectCardView: SMSelectCardForPay?
    var isPay = false
    var topconstraint : NSLayoutConstraint?
    var cardNumberConstraint : NSLayoutConstraint?
    var amount = ""
    var cardNumbertrainling : NSLayoutConstraint?
    var payCardViewButton : SMBottomButton?
    
    override func tapped() {
        
        if let _ = walletView?.presentedCardView {
            walletView?.dismissPresentedCardView(animated: true, completion : {iscompeletAnimation in
                if iscompeletAnimation{
                    UIView.animate(withDuration: 0.2 ,delay: 0.1, animations: {
                        self.walletView?.walletHeader?.alpha = 1.0
                    })
                }
            })
        } else {
            walletView?.present(cardView: self, animated: true, completion : {iscompeletAnimation in
                if iscompeletAnimation{
                    UIView.animate(withDuration: 0.5 ,delay: 0.1, animations: {
                        self.walletView?.walletHeader?.alpha = 0.0
                    })
                    if self.walletView?.presentedCardView != nil {
                        UIView.animate(withDuration: 0.5 ,delay: 0.1, animations: {
                            (self.walletView?.presentedCardView as! SMCardView).isDefaultView?.alpha = 1
                            
                        })
                    }
                }
            })
        }
    }
    
    
    
    
    public init(frame: CGRect,isPay : Bool , card : SMCard) {
        
        
        self.isPay = isPay
        //self.amount = amount
        self.card = card
        super.init(frame: frame)
        self.isDefaultView?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func valueChanged(value: Bool) {
		self.defaultDelegate?.valueChanged(value: value)
//        if self.card.token != nil {
//            self.isDefaultView?.loading.startAnimating()
//            self.isDefaultView?.loading.isHidden = false
//            isDefaultView?.isUserInteractionEnabled = false
//            SMCard.defaultCardFromServer(self.card.token,isDefault: "\(value)", onSuccess: {
//                self.isDefaultView?.loading.stopAnimating()
//                self.isDefaultView?.loading.isHidden = true
//                self.isDefaultView?.isUserInteractionEnabled = true
//                self.defaultDelegate?.finishDefault(isPaygear: false, isCard: true)
//            }, onFailed: {err in
//                self.isDefaultView?.loading.stopAnimating()
//                self.isDefaultView?.loading.isHidden = true
//                self.isDefaultView?.isUserInteractionEnabled = true
//                self.isDefaultView?.isDefault.isOn = !(self.isDefaultView?.isDefault.isOn)!
//            })
//        }
//        else{
//
//
//        }
    }
    

    override func addSubviews(){
        
        self.backgroundColor = SMColor.lightBlue
        self.cardGradientLayer = SMCardGradient()
        self.cardGradientLayer?.backgroundColor = UIColor.white
        self.cardGradientLayer?.layer.cornerRadius = 5
        self.cardGradientLayer?.clipsToBounds = true
        self.cardGradientLayer!.translatesAutoresizingMaskIntoConstraints = false
        self.cardGradientLayer?.layer.borderWidth = 1.0
        self.cardGradientLayer?.layer.borderColor = UIColor.gray.cgColor
        
        self.addSubview(self.cardGradientLayer!)
        
        topconstraint = NSLayoutConstraint(item: self.cardGradientLayer!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        self.addConstraint(topconstraint!)
        self.addConstraint(NSLayoutConstraint(item: self.cardGradientLayer!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16))
        self.addConstraint(NSLayoutConstraint(item: self.cardGradientLayer!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -16))
        self.addConstraint(NSLayoutConstraint(item: self.cardGradientLayer!,
                                              attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self,
                                              attribute: NSLayoutConstraint.Attribute.width,
                                              multiplier: 150 / 250,
                                              constant: 0))
        let BackImage = UIImageView.init(image: UIImage.init(named: "default_card_pattern"))
        
        if let back = self.card.backgroundimage  {
            let request = WS_methods(delegate: self, failedDialog: true)
            let str = request.fs_getFileURL(back)
            
            BackImage.downloadedFrom(link: str ?? "", cashable: true, contentMode: .scaleToFill, completion: {_ in
                
                
            })
        }
        BackImage.translatesAutoresizingMaskIntoConstraints = false
        BackImage.layer.opacity = 0.7
        self.cardGradientLayer?.addSubview(BackImage)
        
        self.addConstraint(NSLayoutConstraint(item: BackImage, attribute: .top, relatedBy: .equal, toItem: cardGradientLayer, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: BackImage, attribute: .leading, relatedBy: .equal, toItem: cardGradientLayer, attribute: .leading, multiplier: 1.0, constant: 0))
        //        self.addConstraint(NSLayoutConstraint(item: BackImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250))
        self.addConstraint(NSLayoutConstraint(item: BackImage,
                                              attribute: NSLayoutConstraint.Attribute.height,
                                              relatedBy: NSLayoutConstraint.Relation.equal,
                                              toItem: self,
                                              attribute: NSLayoutConstraint.Attribute.width,
                                              multiplier: 150 / 250,
                                              constant: 0))
        self.addConstraint(NSLayoutConstraint(item: BackImage, attribute: .trailing, relatedBy: .equal, toItem: cardGradientLayer, attribute: .trailing, multiplier: 1.0, constant: 0))
        
        
        bankLogoImage = UIImageView()
        bankLogoImage?.contentMode = .scaleAspectFit
        self.bankLogoImage!.translatesAutoresizingMaskIntoConstraints = false
        self.bankLogoImage?.image = UIImage.init(named: card.bank?.logoRes ?? "")
        self.addSubview(self.bankLogoImage!)
        
        
        self.addConstraint(NSLayoutConstraint(item: self.bankLogoImage!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
        self.addConstraint(NSLayoutConstraint(item: self.bankLogoImage!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50))
        self.addConstraint(NSLayoutConstraint(item: self.bankLogoImage!, attribute: .top, relatedBy: .equal, toItem: self.cardGradientLayer, attribute: .top, multiplier: 1.0, constant: 10))
        self.addConstraint(NSLayoutConstraint(item: self.bankLogoImage!, attribute: .trailing, relatedBy: .equal, toItem: self.cardGradientLayer, attribute: .trailing, multiplier: 1.0, constant: -16))
        
        
        bankNameLabel = UILabel()
        self.bankNameLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bankNameLabel!)
        //        bankNameLabel?.isHidden = true
        self.addConstraint(NSLayoutConstraint(item: self.bankNameLabel!, attribute: .top, relatedBy: .equal, toItem: cardGradientLayer, attribute: .top, multiplier: 1.0, constant: 20))
        self.addConstraint(NSLayoutConstraint(item: self.bankNameLabel!, attribute: .trailing, relatedBy: .equal, toItem: bankLogoImage, attribute: .leading, multiplier: 1.0, constant: 0))
        
        
        ownerNameLabel = UILabel()
        self.ownerNameLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.ownerNameLabel!.textAlignment = .right
        self.addSubview(self.ownerNameLabel!)
        
        self.addConstraint(NSLayoutConstraint(item: self.ownerNameLabel!, attribute: .bottom, relatedBy: .equal, toItem: cardGradientLayer, attribute: .bottom, multiplier: 1.0, constant: -34))
        self.addConstraint(NSLayoutConstraint(item: self.ownerNameLabel!, attribute: .trailing, relatedBy: .equal, toItem: cardGradientLayer, attribute: .trailing, multiplier: 1.0, constant: -16))
        
        numberLabel = UILabel()
        self.numberLabel!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.numberLabel!)
        
        //        let panTop = 20.0
        cardNumberConstraint = NSLayoutConstraint(item: self.numberLabel!, attribute: .top, relatedBy: .equal, toItem: cardGradientLayer, attribute: .top, multiplier: 1.0, constant: 20)
        self.addConstraint(cardNumberConstraint!)
        self.addConstraint(NSLayoutConstraint(item: self.numberLabel!, attribute: .leading, relatedBy: .equal, toItem: cardGradientLayer, attribute: .leading, multiplier: 1.0, constant: 0))
        cardNumbertrainling = NSLayoutConstraint(item: self.numberLabel!, attribute: .trailing, relatedBy: .equal, toItem: bankLogoImage, attribute: .leading, multiplier: 1.0, constant: 0)
        self.addConstraint(cardNumbertrainling!)
        
        
        
        if isPay {
            
            selectCardView = SMSelectCardForPay.instanceFromNib()
            selectCardView?.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: self.selectCardView!, attribute: .top, relatedBy: .equal, toItem: cardGradientLayer, attribute: .bottom, multiplier: 1.0, constant: 16))
            self.addConstraint(NSLayoutConstraint(item: self.selectCardView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: self.selectCardView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: self.selectCardView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 2))
            selectCardView?.isUserInteractionEnabled = true
            let amountInt = Int(amount) ?? 0
            //            if amountInt < 2000000{
            //                selectCardView?.cvv2TextView.isHidden = true
            //                selectCardView?.cvv2TitleView.isHidden = true
            //            }
            
            
            
            payCardViewButton = SMBottomButton()//.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 50, width: self.frame.size.width, height: 50))
            payCardViewButton!.translatesAutoresizingMaskIntoConstraints = false
            payCardViewButton!.setTitle("pay".localized, for: .normal)
            payCardViewButton!.fromColor = UIColor.init(netHex: 0x00e676)
            payCardViewButton!.toColor = UIColor.init(netHex: 0x2ecc71)
            payCardViewButton!.layer.cornerRadius = 24
            self.addConstraint(NSLayoutConstraint(item: payCardViewButton!, attribute: .top, relatedBy: .equal, toItem: selectCardView?.secondPassTextField, attribute: .bottom, multiplier: 1.0, constant: 10))
            self.addConstraint(NSLayoutConstraint(item: payCardViewButton!, attribute: .leading, relatedBy: .equal, toItem: selectCardView, attribute: .leading, multiplier: 1.0, constant: 10))
            self.addConstraint(NSLayoutConstraint(item: payCardViewButton!, attribute: .trailing, relatedBy: .equal, toItem: selectCardView, attribute: .trailing, multiplier: 1.0, constant: -10))
            self.addConstraint(NSLayoutConstraint(item: payCardViewButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48))
            payCardViewButton!.isEnabled = true
            payCardViewButton!.isUserInteractionEnabled = true
            self.selectCardView?.addSubview(payCardViewButton!)
            self.selectCardView?.isHidden = true
            self.tapGestureRecognizer.delegate = cardGradientLayer
            cardGradientLayer?.addGestureRecognizer(self.tapGestureRecognizer)
            self.addSubview(self.selectCardView!)
            payCardViewButton!.addTarget(self, action: #selector(self.payPressed(_:)), for: .touchUpInside)
            
        }
        else{
            isDefaultView = SMIsDefaultCard.instanceFromNib()
            isDefaultView?.isDefault.tintColor = SMColor.PrimaryColor
            isDefaultView?.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraint(NSLayoutConstraint(item: self.isDefaultView!, attribute: .top, relatedBy: .equal, toItem: cardGradientLayer, attribute: .bottom, multiplier: 1.0, constant: 16))
            self.addConstraint(NSLayoutConstraint(item: self.isDefaultView!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: self.isDefaultView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: self.isDefaultView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 2))
            isDefaultView?.isUserInteractionEnabled = true
            isDefaultView?.loading.isHidden = true
            isDefaultView?.isDefault.isOn = self.card.isDefault!
            
            
            removeCardViewButton = SMBottomButton()//.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 50, width: self.frame.size.width, height: 50))
            removeCardViewButton?.translatesAutoresizingMaskIntoConstraints = false
            removeCardViewButton?.setTitle("remove".localized, for: .normal)
            removeCardViewButton?.fromColor = UIColor.init(netHex: 0xff365d)
            removeCardViewButton?.toColor = UIColor.init(netHex: 0xff365d)
            removeCardViewButton?.layer.cornerRadius = 24
            self.addConstraint(NSLayoutConstraint(item: self.removeCardViewButton!, attribute: .top, relatedBy: .equal, toItem: isDefaultView, attribute: .top, multiplier: 1.0, constant: 60))
            self.addConstraint(NSLayoutConstraint(item: self.removeCardViewButton!, attribute: .leading, relatedBy: .equal, toItem: isDefaultView, attribute: .leading, multiplier: 1.0, constant: 10))
            self.addConstraint(NSLayoutConstraint(item: self.removeCardViewButton!, attribute: .trailing, relatedBy: .equal, toItem: isDefaultView, attribute: .trailing, multiplier: 1.0, constant: -10))
            self.addConstraint(NSLayoutConstraint(item: self.removeCardViewButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48))
            removeCardViewButton?.isEnabled = true
            removeCardViewButton?.isUserInteractionEnabled = true
            self.isDefaultView?.addSubview(self.removeCardViewButton!)
            self.isDefaultView?.alpha = 0.0
            self.addSubview(self.isDefaultView!)
            
//            self.removeCardViewButton?.addTarget(self, action: #selector(self.removeCardView(_:)), for: .touchUpInside)
        }
    }
    
    override func setStyle(){
        
        super.setStyle()
        
        self.backgroundColor = UIColor.white
        self.bankNameLabel?.font = SMFonts.IranYekanBold(18)
        self.bankNameLabel?.textColor = UIColor.black
        self.bankNameLabel?.text = self.card.bank?.nameFA
        
        self.ownerNameLabel?.font = SMFonts.IranYekanLight(18)
        self.ownerNameLabel?.textColor = UIColor.black
        
        
        //        self.expMounthLabel?.font = SMFonts.IranYekanLight(16)
        //        self.expMounthLabel?.textColor = UIColor.black
        //
        //
        //        self.expDateTitleLabel?.textColor = UIColor.black
        
        
        self.numberLabel?.textAlignment = .left
        
        let panFontSize:Float = self.frame.size.width < 350 ? 21.0 : 25.0
        
        self.numberLabel?.font = SMFonts.IranYekanBold(panFontSize)
        self.numberLabel?.textColor = UIColor.black
        self.numberLabel?.layer.shadowRadius = 3.0
        self.numberLabel?.layer.shadowColor = UIColor.white.cgColor
        self.numberLabel?.layer.shadowOpacity = 1.0
        self.numberLabel?.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.numberLabel?.layer.masksToBounds = false
        
    }
    
    static func prepareCardViews(userCards : [SMCard]?,isPay : Bool)->[SMCardView]{
        
        var cardViews = [SMCardView]()
        if let cards = userCards {
            
            for card in cards {
                
                if card.type == 0{
                    let cardView = SMCardView(frame: CGRect(x: 0, y: 0, width: 340, height: 90),isPay : isPay,card: card)
                    cardView.numberLabel?.text = card.pan?.inLocalizedLanguage().printMaskedPanNumber().formatPanStringWith(char : "  ").substring(11)
                    cardView.backgroundColor = UIColor.clear
                    cardView.isUserInteractionEnabled = true
                    cardView.clipsToBounds = false
                    cardView.bankNameLabel?.text = card.bank?.nameEN?.localized
                    cardViews.append(cardView)
                    
                }
            }
        }
        //self.cardViews = cardViews
        return cardViews
    }
    
    
    
    
    @objc func payPressed(_ sender: Any){
        
        delegate?.finishPassing(card: self)
        
    }
    
    
    
//    @objc func removeCardView(_ sender: Any) {
//
//
//        SMLoading.shared.showNormalDialog(viewController: SMNavigationController.shared.viewControllers[0] , height: 180, isleftButtonEnabled: true, title: "card.remove.title".localized, message: "card.remove.message".localized, leftButtonTitle: "logout.cancel.btn".localized, rightButtonTitle:"card.remove.btn".localized , yesPressed: {obj in
//
//            let cardview = (self.walletView?.presentedCardView as? SMCardView)
//            cardview?.removeCardViewButton?.gotoLoadingState()
//            cardview?.isUserInteractionEnabled = false
//            SMCard.deleteCardFromServer(cardview?.card.token, onSuccess: {
//
//                self.walletView?.dismissPresentedCardView(animated: true)
//                self.walletView?.remove(cardView: cardview!, animated: true, completion : {
//                    if self.walletView?.insertedCardViews.count == 0  {
//                        self.defaultDelegate?.finishDefault(isPaygear: false,isCard: true)
//                    }
//                })
//            }, onFailed: { err in
//                cardview?.removeCardViewButton?.gotoButtonState()
//                cardview?.isUserInteractionEnabled = true
//                if SMValidation.showConnectionErrorToast(err) {
//                SMLoading.showToast(viewcontroller: SMNavigationController.shared.viewControllers[0], text: "serverDown".localized)
//                }
//
//            })
//        })
//    }
//
	
    
    
    override var presented: Bool { didSet { presentedDidUpdate() } }
    
    func presentedDidUpdate() {
        
        removeCardViewButton?.isHidden = !presented
        //self.backgroundColor = presented ? presentedCardViewColor : depresentedCardViewColor
        self.addTransitionFade()
        
    }
    
    
}
