//
//  SMCardCarosalView.swift
//  PayGear
//
//  Created by a on 4/10/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import iCarousel

class SMCardCarouselView: iCarousel, iCarouselDataSource, iCarouselDelegate {
    
    var service: String?
    var userCards: [SMCard] = [SMCard(),SMCard(),SMCard(),SMCard(),SMCard(),SMCard(),SMCard(),SMCard()]
    public var onItemSeleceted:((SMCard)->())?
    public var onItemChanged:(()->())?
    
   
    
    var cardScale = CGFloat(1.0)
    var cardGap = CGFloat(1.04)
    var cardWidth = CGFloat(0.0)
    
    @IBInspectable
    public var gradientBackground:Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var showNewCard:Bool = false{
        didSet{
            
           
            self.reloadData()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.onCreate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.onCreate()
    }
    
   
    
    func onCreate(){
        
        self.cardWidth = UIScreen.main.bounds.width - CGFloat(50)
        self.cardWidth = self.cardWidth > 332 ? 332 : self.cardWidth
        
        
        self.type = .linear
        
        self.dataSource = self
        self.delegate = self
        self.decelerationRate = 0.84
        self.bounceDistance = 0.3
        //self.contentOffset = CGSize(width: 0, height: topGap)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCardsFromDB), name: NSNotification.Name(rawValue: "NEW_CARD_SYNC_NOTIFICATION"), object: nil)
        
//       self.currentItemIndex = 0
//       self.type = .timeMachine
         self.isVertical = true
         self.clipsToBounds = true
      
        self.reloadCardsFromDB()
    }
    
    

    
    
    
    func reloadCardsFromDB(){
        
       // self.userCards = [SMCard(),SMCard()]
        
//        for card in userCards {
//                let index = userCards.index(of: card)
//                userCards.remove(at: index!)
//        }
        
        self.reloadData()
        
        
        
    }
    
    
    var currentCard:SMCard?{
        
        if self.showNewCard && self.currentItemIndex == 0 {
            return nil
        }
        
        return (self.showNewCard ? self.userCards[self.currentItemIndex - 1] : self.userCards[self.currentItemIndex])
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        
        var itemCount = self.userCards.count
        
        if self.showNewCard {
            itemCount += 1
        }
        
        return itemCount
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let cardHeight = self.cardWidth * CGFloat(0.6214)
        
        let cardTopOffset = CGFloat(36.0)
        let cardHolderHeight = cardHeight + cardTopOffset
        
        let cardHolder = UIView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHolderHeight))
        
        let cardTitle = UILabel()
        cardTitle.translatesAutoresizingMaskIntoConstraints = false
        cardHolder.addConstraint(NSLayoutConstraint(item: cardTitle, attribute: .centerX, relatedBy: .equal, toItem: cardHolder, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        cardHolder.addConstraint(NSLayoutConstraint(item: cardTitle, attribute: .top, relatedBy: .equal, toItem: cardHolder, attribute: .top, multiplier: 1.0, constant: 0.0))
        cardTitle.addConstraint(NSLayoutConstraint(item: cardTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: cardTopOffset))
        
        cardTitle.textAlignment = .center
        cardTitle.textColor = UIColor.brown
        cardTitle.font = SMFonts.IranYekanLight(15)
        cardHolder.clipsToBounds = false
        cardHolder.addSubview(cardTitle)
        
        let newCard = self.userCards[index]
        
        let cardView = SMCardView(frame: CGRect(x: 0, y: cardTopOffset, width: cardWidth, height: cardHeight),bank: newCard.bank)
        
        //newCard.pan = newCard.pan
        let expDate = newCard.exp_m ?? ""
        
        cardView.numberLabel?.text = "65645645645"
        
        
        cardView.expDateLabel?.text = expDate
        //cardView.ownerNameLabel?.text = newCard.ownerNameFa
        
        //cardTitle.text = newCard.title
    
        
        
        cardView.clipsToBounds = false
        cardView.layer.shadowRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.9
        cardView.layer.shadowOffset = CGSize(width: 0, height: 12)
        
        cardHolder.addSubview(cardView)
        cardHolder.transform = CGAffineTransform(scaleX: self.cardScale, y: self.cardScale)
        
        return cardHolder
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * self.cardGap
        }
        return value
    }
    
    
    func carouselTick() {
        if #available(iOS 10.0, *) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        
        
        self.onItemChanged?()
        
        if let currentCard = self.currentCard{
            
           // SMCard.setDefaultCard(card: currentCard)
        }
        
    }
    
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if self.showNewCard {
            if index != 0 {
                self.onItemSeleceted?(self.userCards[index - 1])
            }
        } else {
            self.onItemSeleceted?(self.userCards[index])
        }
        
        
    }
    
    
    //    //Just adding the background gradient
    override func draw(_ rect: CGRect) {
        
        
        if self.gradientBackground{
            
            let ctx = UIGraphicsGetCurrentContext()!
            
            let cgColors = [UIColor.black.cgColor]
            
            let opt = CGGradientDrawingOptions(rawValue: 0)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let locations: [CGFloat] = [0.0, 1.0]
            
            
            let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations)!
            
            
            ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: rect.height), options: opt)
        }
        
        super.draw(rect)
        
    }
    
    
}
