/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import AsyncDisplayKit

class IGCardToCardReceiptNode: AbstractNode {
    private var txtTypeIcon: ASTextNode = {
        let node = ASTextNode()
        return node
    }()
    private var txtTypeTitle = ASTextNode()
    private var txtAmount = ASTextNode()
    private var testNode = ASDisplayNode()
    private var hasShownMore : Bool = false
    // Date and Time
    private var txtTTLDate = ASTextNode()
    private var txtVALUEDate = ASTextNode()
    // Source Card Number
    private var txtTTLSourceCardNumber = ASTextNode()
    private var txtVALUESourceCardNumber = ASTextNode()
    // Destination Card Number
    private var txtTTLDestinationCardNumber = ASTextNode()
    private var txtVALUEDestinationCardNumber = ASTextNode()
    // Destination Bank Name
    private var txtTTLDestinationBankName = ASTextNode()
    private var txtVALUEDestinationBankName = ASTextNode()
    // Card Owner Name
    private var txtTTLCardOwnerName = ASTextNode()
    private var txtVALUECardOwnerName = ASTextNode()
    // Trace Number
    private var txtTTLTraceNumber = ASTextNode()
    private var txtVALUETraceNumber = ASTextNode()
    // Refrence Number
    private var txtTTLRefrenceNumber = ASTextNode()
    private var txtVALUERefrenceNumber = ASTextNode()
    private var viewSepratorCardNum = ASDisplayNode()
    private var viewSepratorDesCardNum = ASDisplayNode()
    private var viewSepratorDesBankName = ASDisplayNode()
    private var viewSepratorOwnerName = ASDisplayNode()
    private var viewSepratorTraceNum = ASDisplayNode()
    private var viewSepratorTop = ASDisplayNode()
    private var viewSepratorDate = ASDisplayNode()

    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func setupView() {
        super.setupView()
        
        IGGlobal.makeText(for: txtTypeIcon, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 40, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeText(for: txtTypeTitle, with: IGStringsManager.CardMoneyTransfer.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        if let amount = (message.wallet?.cardToCard?.amount) {
            
            IGGlobal.makeText(for: txtAmount, with: String(amount).inRialFormat() + " " + IGStringsManager.Currency.rawValue.localized
           , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        }
        else{
            
           IGGlobal.makeText(for: txtAmount, with: "..." , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }

        viewSepratorCardNum.style.height = ASDimensionMake(.points, 0)
        viewSepratorTraceNum.style.height = ASDimensionMake(.points, 0)
        viewSepratorOwnerName.style.height = ASDimensionMake(.points, 0)
        viewSepratorDesCardNum.style.height = ASDimensionMake(.points, 0)
        viewSepratorDesBankName.style.height = ASDimensionMake(.points, 0)
        viewSepratorTop.style.height = ASDimensionMake(.points, 0)
        viewSepratorDate.style.height = ASDimensionMake(.points, 0)

        viewSepratorCardNum.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTraceNum.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorOwnerName.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorDesCardNum.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorDesBankName.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTop.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorDate.backgroundColor = ThemeManager.currentTheme.LabelColor

        btnShowMore.style.height = ASDimensionMake(.points, 50)
        btnShowMore.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)

        
        addSubnode(txtTypeIcon)
        addSubnode(txtTypeTitle)
        addSubnode(txtAmount)
        //Datas
        addSubnode(txtTTLSourceCardNumber)
        addSubnode(txtVALUESourceCardNumber)
        addSubnode(txtTTLDestinationCardNumber)
        addSubnode(txtVALUEDestinationCardNumber)
        addSubnode(txtTTLDestinationBankName)
        addSubnode(txtVALUEDestinationBankName)
        addSubnode(txtTTLCardOwnerName)
        addSubnode(txtVALUECardOwnerName)
        addSubnode(txtTTLTraceNumber)
        addSubnode(txtVALUETraceNumber)
        addSubnode(txtTTLRefrenceNumber)
        addSubnode(txtVALUERefrenceNumber)
        addSubnode(txtTTLDate)
        addSubnode(txtVALUEDate)

        addSubnode(viewSepratorCardNum)
        addSubnode(viewSepratorTraceNum)
        addSubnode(viewSepratorOwnerName)
        addSubnode(viewSepratorDesCardNum)
        addSubnode(viewSepratorDesBankName)
        addSubnode(viewSepratorDate)
        addSubnode(viewSepratorTop)

        let elemArray : [ASLayoutElement] = [txtTTLDate,txtVALUEDate,txtTTLSourceCardNumber,txtVALUESourceCardNumber,txtTTLDestinationCardNumber,txtVALUEDestinationCardNumber,txtTTLDestinationBankName,txtVALUEDestinationBankName,txtTTLCardOwnerName,txtVALUECardOwnerName,txtTTLTraceNumber,txtVALUETraceNumber,txtTTLRefrenceNumber,txtVALUERefrenceNumber]
        for elemnt in elemArray {
            elemnt.style.preferredSize = CGSize.zero
        }
        addSubnode(btnShowMore)
        btnShowMore.backgroundColor = ThemeManager.currentTheme.NavigationSecondColor
        btnShowMore.layer.cornerRadius = 10.0
        btnShowMore.addTarget(self, action: #selector(handleUserTap), forControlEvents: ASControlNodeEvent.touchUpInside)

        setData()
    }
    
    func setData() {
        //TITLES SET DATA
        IGGlobal.makeText(for: self.txtTTLDate, with: IGStringsManager.DateTime.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLSourceCardNumber, with: IGStringsManager.CardNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLDestinationCardNumber, with: IGStringsManager.DestinationCard.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLDestinationBankName, with: IGStringsManager.DestinationBank.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLCardOwnerName, with: IGStringsManager.AccountOwnerName.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLTraceNumber, with: IGStringsManager.TraceNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLRefrenceNumber, with: IGStringsManager.RefrenceNum.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        //VALUES SET DATA
        if let time = TimeInterval(exactly: (message.wallet?.cardToCard!.requestTime)!) {

            IGGlobal.makeText(for: self.txtVALUEDate, with: Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        }
        IGGlobal.makeText(for: self.txtVALUESourceCardNumber, with: (message.wallet?.cardToCard!.sourceCardNumber)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtVALUEDestinationCardNumber, with: (message.wallet?.cardToCard!.destCardNumber)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtVALUEDestinationBankName, with: (message.wallet?.cardToCard!.destBankName)!, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtVALUECardOwnerName, with: (message.wallet?.cardToCard!.cardOwnerName)!, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtVALUETraceNumber, with: (message.wallet?.cardToCard!.traceNumber)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtVALUERefrenceNumber, with: (message.wallet?.cardToCard!.rrn)!.inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

    }
    
    //- Hint : Check tap on  showmore
    @objc func handleUserTap() {
        
        self.setNeedsLayout()
        self.transitionLayout(withAnimation: true, shouldMeasureAsync: true, measurementCompletion: nil)
    }
    
    override func transitionLayout(withAnimation animated: Bool, shouldMeasureAsync: Bool, measurementCompletion completion: (() -> Void)? = nil) {
        
                if self.hasShownMore {
                 self.testNode.layoutIfNeeded()
                    btnShowMore.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)

                    viewSepratorCardNum.style.height = ASDimensionMake(.points, 0)
                    viewSepratorTraceNum.style.height = ASDimensionMake(.points, 0)
                    viewSepratorOwnerName.style.height = ASDimensionMake(.points, 0)
                    viewSepratorDesCardNum.style.height = ASDimensionMake(.points, 0)
                    viewSepratorDesBankName.style.height = ASDimensionMake(.points, 0)
                    viewSepratorDate.style.height = ASDimensionMake(.points, 0)
                    viewSepratorTop.style.height = ASDimensionMake(.points, 0)


                    let elemArray : [ASLayoutElement] = [txtTTLDate,txtVALUEDate,txtTTLSourceCardNumber,txtVALUESourceCardNumber,txtTTLDestinationCardNumber,txtVALUEDestinationCardNumber,txtTTLDestinationBankName,txtVALUEDestinationBankName,txtTTLCardOwnerName,txtVALUECardOwnerName,txtTTLTraceNumber,txtVALUETraceNumber,txtTTLRefrenceNumber,txtVALUERefrenceNumber]
                    for elemnt in elemArray {
                        elemnt.style.preferredSize = CGSize.zero
                    }
                 UIView.animate(withDuration: 1.0, animations: {
                      self.testNode.layoutIfNeeded()
                 })


             } else {
                 self.testNode.layoutIfNeeded()
                    btnShowMore.setTitle(IGStringsManager.GlobalClose.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)

                    viewSepratorCardNum.style.height = ASDimensionMake(.points, 1)
                    viewSepratorTraceNum.style.height = ASDimensionMake(.points, 1)
                    viewSepratorOwnerName.style.height = ASDimensionMake(.points, 1)
                    viewSepratorDesCardNum.style.height = ASDimensionMake(.points, 1)
                    viewSepratorDesBankName.style.height = ASDimensionMake(.points, 1)
                    viewSepratorDate.style.height = ASDimensionMake(.points, 1)
                    viewSepratorTop.style.height = ASDimensionMake(.points, 1)
                    let elemArray : [ASLayoutElement] = [txtTTLDate,txtVALUEDate,txtTTLSourceCardNumber,txtVALUESourceCardNumber,txtTTLDestinationCardNumber,txtVALUEDestinationCardNumber,txtTTLDestinationBankName,txtVALUEDestinationBankName,txtTTLCardOwnerName,txtVALUECardOwnerName,txtTTLTraceNumber,txtVALUETraceNumber,txtTTLRefrenceNumber,txtVALUERefrenceNumber]
                    for elemnt in elemArray {
                        elemnt.style.height = ASDimensionMake(.points, 25)
                    }
                    
                 UIView.animate(withDuration: 1.0, animations: {
                      self.testNode.layoutIfNeeded()
                 })
             }
        
             self.hasShownMore = !self.hasShownMore

    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtTypeTitle, txtAmount]
        

        let profileBox = ASStackLayoutSpec.horizontal()
        profileBox.spacing = 10
        profileBox.children = [txtTypeIcon, textBox]
        
        let mainBox = ASStackLayoutSpec.vertical()
        mainBox.justifyContent = .spaceAround
        mainBox.children = [profileBox]
        let elemArray : [ASLayoutElement] = [viewSepratorTop,txtTTLDate,txtVALUEDate,viewSepratorDate,txtTTLSourceCardNumber,txtVALUESourceCardNumber,viewSepratorCardNum,txtTTLDestinationCardNumber,txtVALUEDestinationCardNumber,viewSepratorDesCardNum,txtTTLDestinationBankName,txtVALUEDestinationBankName,viewSepratorDesBankName,txtTTLCardOwnerName,txtVALUECardOwnerName,viewSepratorOwnerName,txtTTLTraceNumber,txtVALUETraceNumber,viewSepratorTraceNum,txtTTLRefrenceNumber,txtVALUERefrenceNumber]

        for elemnt in elemArray {
            mainBox.children?.append(elemnt)
        }
        mainBox.children?.append(btnShowMore)

        // Apply text truncation
        let elems: [ASLayoutElement] = [txtTypeTitle, txtAmount,txtTypeIcon,btnShowMore, textBox, profileBox, mainBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
      
        
        return mainBox

        
    }
    
    
}

