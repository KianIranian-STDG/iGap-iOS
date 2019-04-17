//
//  SMDefaultCard.swift
//  PayGear
//
//  Created by amir soltani on 5/15/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import Wallet

class SMDefaultCard: CardView {
    
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func instanceFromNib() -> SMDefaultCard {
        return UINib(nibName: "DefaultCard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SMDefaultCard
    }
    
    
    static func prepareDefaultCard()->[SMDefaultCard]{
        var cardViews = [SMDefaultCard]()
        let cardView = SMDefaultCard.instanceFromNib()
        cardView.frame = CGRect(x: 0, y: -40, width: 340, height: 90)
        cardView.backgroundColor = UIColor.clear
        cardView.isUserInteractionEnabled = true
        cardView.clipsToBounds = false
        cardView.isDefault = true
        cardViews.append(cardView)
        return cardViews
        
        
    }
    

    var hasShadow = false
    
    
    func setStyle(){
        if self.hasShadow == false {
            backgroundColor = UIColor.clear
            contentView.layer.cornerRadius = 5
            contentView.layer.shadowRadius = 10
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOffset = CGSize(width: 3, height: 8)
            contentView.layer.shadowOpacity = 0.5
            self.clipsToBounds = true
            self.hasShadow = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setStyle()
        addCardButton.setTitle("add.card.title".localized, for: .normal)
        
    }
    
}
