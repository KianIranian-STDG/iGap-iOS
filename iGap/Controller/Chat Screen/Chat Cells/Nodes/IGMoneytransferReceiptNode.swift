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

class IGMoneytransferReceiptNode: AbstractNode {
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
    // Sender Name
    private var txtTTLSenderName = ASTextNode()
    private var txtVALUESenderName = ASTextNode()
    // Receiver Name
    private var txtTTLReciever = ASTextNode()
    private var txtVALUEReciever = ASTextNode()
    // Trace Number
    private var txtTTLTraceNumber = ASTextNode()
    private var txtVALUETraceNumber = ASTextNode()
    // Invoice Number
    private var txtTTLRefrenceNumber = ASTextNode()
    private var txtVALUERefrenceNumber = ASTextNode()
    // Description
    private var txtTTLDesc = ASTextNode()
    private var txtVALUEDesc = ASTextNode()

    private var viewSepratorThree = ASDisplayNode()
    private var viewSepratorFour = ASDisplayNode()
    private var viewSepratorFive = ASDisplayNode()
    private var viewSepratorSix = ASDisplayNode()
    private var viewSepratorSeven = ASDisplayNode()
    private var viewSepratorOne = ASDisplayNode()
    private var viewSepratorTwo = ASDisplayNode()

    
    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    override func setupView() {
        super.setupView()
        
        IGGlobal.makeText(for: txtTypeIcon, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 40, numberOfLines: 1, font: .fontIcon, alignment: .center)
        IGGlobal.makeText(for: txtTypeTitle, with: IGStringsManager.CardMoneyTransfer.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        if let amount = (message.wallet?.moneyTrasfer?.amount) {
            
            IGGlobal.makeText(for: txtAmount, with: String(amount).inRialFormat() + " " + IGStringsManager.Currency.rawValue.localized
           , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .left)
        }
        else{
            
           IGGlobal.makeText(for: txtAmount, with: "..." , textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }

        viewSepratorOne.style.height = ASDimensionMake(.points, 0)
        viewSepratorTwo.style.height = ASDimensionMake(.points, 0)
        viewSepratorThree.style.height = ASDimensionMake(.points, 0)
        viewSepratorFour.style.height = ASDimensionMake(.points, 0)
        viewSepratorFive.style.height = ASDimensionMake(.points, 0)
        viewSepratorSix.style.height = ASDimensionMake(.points, 0)
        viewSepratorSeven.style.height = ASDimensionMake(.points, 0)

        viewSepratorOne.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorTwo.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorThree.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFour.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorFive.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSix.backgroundColor = ThemeManager.currentTheme.LabelColor
        viewSepratorSeven.backgroundColor = ThemeManager.currentTheme.LabelColor

        btnShowMore.style.height = ASDimensionMake(.points, 50)
        btnShowMore.setTitle(IGStringsManager.MoreDetails.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)

        
        addSubnode(txtTypeIcon)
        addSubnode(txtTypeTitle)
        addSubnode(txtAmount)
        //Datas
        addSubnode(txtTTLSenderName)
        addSubnode(txtVALUESenderName)
        addSubnode(txtTTLReciever)
        addSubnode(txtVALUEReciever)
        addSubnode(txtTTLDesc)
        addSubnode(txtVALUEDesc)
        addSubnode(txtTTLTraceNumber)
        addSubnode(txtVALUETraceNumber)
        addSubnode(txtTTLRefrenceNumber)
        addSubnode(txtVALUERefrenceNumber)
        addSubnode(txtTTLDate)
        addSubnode(txtVALUEDate)

        addSubnode(viewSepratorOne)
        addSubnode(viewSepratorTwo)
        addSubnode(viewSepratorThree)
        addSubnode(viewSepratorFour)
        addSubnode(viewSepratorFive)
        addSubnode(viewSepratorSix)
        addSubnode(viewSepratorSeven)

        let elemArray : [ASLayoutElement] = [txtTTLDate,txtVALUEDate,txtTTLSenderName,txtVALUESenderName,txtTTLReciever,txtVALUEReciever,txtTTLTraceNumber,txtVALUETraceNumber,txtTTLRefrenceNumber,txtVALUERefrenceNumber,txtTTLDesc,txtVALUEDesc]
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
        IGGlobal.makeText(for: self.txtTTLSenderName, with: IGStringsManager.From.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLReciever, with: IGStringsManager.Reciever.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLTraceNumber, with: IGStringsManager.TraceNumber.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLRefrenceNumber, with: IGStringsManager.RefrenceNum.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        IGGlobal.makeText(for: self.txtTTLDesc, with: IGStringsManager.Desc.rawValue.localized, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        //VALUES SET DATA
        if let time = TimeInterval(exactly: (message.wallet?.cardToCard!.requestTime)!) {

            IGGlobal.makeText(for: self.txtVALUEDate, with: Date(timeIntervalSince1970: time).completeHumanReadableTime(showHour: true).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        }
        if let senderUser = IGRegisteredUser.getUserInfo(id: (message.wallet?.moneyTrasfer!.fromUserId)!) {
            IGGlobal.makeText(for: self.txtVALUESenderName, with: senderUser.displayName, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let receiverUser = IGRegisteredUser.getUserInfo(id: (message.wallet?.moneyTrasfer!.toUserId)!) {
            IGGlobal.makeText(for: self.txtVALUEReciever, with: receiverUser.displayName, textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)
        }
        if let traceNum = (message.wallet?.moneyTrasfer!.traceNumber) {
            IGGlobal.makeText(for: self.txtVALUETraceNumber, with: String(traceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        }
        if let invoiceNum = (message.wallet?.moneyTrasfer!.invoiceNumber) {
            IGGlobal.makeText(for: self.txtVALUETraceNumber, with: String(invoiceNum).inLocalizedLanguage(), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        }
        if (message.wallet?.moneyTrasfer!.walletDescription)!.isEmpty  || (message.wallet?.moneyTrasfer!.walletDescription) == nil || (message.wallet?.moneyTrasfer!.description) == ""{
            IGGlobal.makeText(for: self.txtVALUETraceNumber, with: "", textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        } else {
            IGGlobal.makeText(for: self.txtVALUETraceNumber, with: ((message.wallet?.moneyTrasfer!.walletDescription)!), textColor: ThemeManager.currentTheme.LabelColor, size: 15, numberOfLines: 1, font: .igapFont, alignment: .center)

        }

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

                    viewSepratorOne.style.height = ASDimensionMake(.points, 0)
                    viewSepratorTwo.style.height = ASDimensionMake(.points, 0)
                    viewSepratorThree.style.height = ASDimensionMake(.points, 0)
                    viewSepratorFive.style.height = ASDimensionMake(.points, 0)
                    viewSepratorFour.style.height = ASDimensionMake(.points, 0)
                    viewSepratorSix.style.height = ASDimensionMake(.points, 0)
                    viewSepratorSeven.style.height = ASDimensionMake(.points, 0)


                    let elemArray : [ASLayoutElement] = [txtTTLDate,txtVALUEDate,txtTTLSenderName,txtVALUESenderName,txtTTLReciever,txtVALUEReciever,txtTTLTraceNumber,txtVALUETraceNumber,txtTTLRefrenceNumber,txtVALUERefrenceNumber,txtTTLDesc,txtVALUEDesc]
                    for elemnt in elemArray {
                        elemnt.style.preferredSize = CGSize.zero
                    }
                 UIView.animate(withDuration: 1.0, animations: {
                      self.testNode.layoutIfNeeded()
                 })


             } else {
                 self.testNode.layoutIfNeeded()
                    btnShowMore.setTitle(IGStringsManager.GlobalClose.rawValue.localized, with: UIFont.igFont(ofSize: 20), with: .black, for: .normal)

                    viewSepratorOne.style.height = ASDimensionMake(.points, 1)
                    viewSepratorTwo.style.height = ASDimensionMake(.points, 1)
                    viewSepratorThree.style.height = ASDimensionMake(.points, 1)
                    viewSepratorFive.style.height = ASDimensionMake(.points, 1)
                    viewSepratorFour.style.height = ASDimensionMake(.points, 1)
                    viewSepratorSix.style.height = ASDimensionMake(.points, 1)
                    viewSepratorSeven.style.height = ASDimensionMake(.points, 1)
                    let elemArray : [ASLayoutElement] = [txtTTLDate,txtVALUEDate,txtTTLSenderName,txtVALUESenderName,txtTTLReciever,txtVALUEReciever,txtTTLTraceNumber,txtVALUETraceNumber,txtTTLRefrenceNumber,txtVALUERefrenceNumber,txtTTLDesc,txtVALUEDesc]
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
        let elemArray : [ASLayoutElement] = [viewSepratorOne,txtTTLDate,txtVALUEDate,viewSepratorTwo,txtTTLSenderName,txtVALUESenderName,viewSepratorThree,txtTTLReciever,txtVALUEReciever,viewSepratorFour,txtTTLTraceNumber,txtVALUETraceNumber,viewSepratorFive,txtTTLRefrenceNumber,txtVALUERefrenceNumber,viewSepratorSix,txtTTLDesc,txtVALUEDesc]

        for elemnt in elemArray {
            mainBox.children?.append(elemnt)
        }
        mainBox.children?.append(btnShowMore)

        // Apply text truncation
        let elems: [ASLayoutElement] = [viewSepratorOne,txtTTLDate,txtVALUEDate,viewSepratorTwo,txtTTLSenderName,txtVALUESenderName,viewSepratorThree,txtTTLReciever,txtVALUEReciever,viewSepratorFour,txtTTLTraceNumber,txtVALUETraceNumber,viewSepratorFive,txtTTLRefrenceNumber,txtVALUERefrenceNumber,viewSepratorSix,txtTTLDesc,txtVALUEDesc, textBox, profileBox, mainBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
      
        
        return mainBox

        
    }
    
    
}

