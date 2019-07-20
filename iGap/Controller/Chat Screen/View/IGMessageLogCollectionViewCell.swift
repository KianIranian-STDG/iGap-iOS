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

class IGMessageLogCollectionViewCell: IGMessageGeneralCollectionViewCell {

    
    
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var labelBackgrondView: UIView!
    @IBOutlet weak var labelBackgroundViewWidth: NSLayoutConstraint!
    
    
    //MARK: - Class Methods
    class func nib() -> UINib {
        return UINib(nibName: "IGMessageLogCollectionViewCell", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    //MARK: - Instance Method
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.cellMessage = nil
        self.delegate = nil
        
        self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
    }
    
    deinit {
        print (#function)
    }

    override func prepareForReuse() {
        labelBackgroundViewWidth.constant = 15
    }
    
    
    override func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {
        self.cellMessage = message
        self.logLabel.textColor = UIColor.white
        if message.log?.type == .pinnedMessage {
            self.logLabel.text = IGRoomMessage.detectPinMessage(message: message)
        } else {
            self.logLabel.text = IGRoomMessageLog.textForLogMessage(message)
        }
        self.labelBackgrondView.layer.cornerRadius = 12.0
        self.labelBackgrondView.backgroundColor = UIColor.logBackground()
    }
    
    func setUnreadMessage(_ message: IGRoomMessage){
        self.logLabel.textColor = UIColor.white
        self.logLabel.text = message.message
        self.labelBackgrondView.layer.cornerRadius = 12.0
        self.labelBackgrondView.backgroundColor = UIColor.iGapMainColor()
        self.labelBackgroundViewWidth.constant = 210
    }
    
    func setUnknownMessage(){
        self.logLabel.textColor = UIColor.white
        self.logLabel.text = "unknown message"
        self.labelBackgrondView.layer.cornerRadius = 12.0
        self.labelBackgrondView.backgroundColor = UIColor.logBackground()
    }
    
    
    func setText(_ text: String) {
        self.logLabel.textColor = UIColor.white
        self.logLabel.text = text
        self.labelBackgrondView.layer.cornerRadius = 12.0
        self.labelBackgrondView.backgroundColor = UIColor.logBackground()
    }
    
    func setTime(_ time: String) {
        self.logLabel.textColor = UIColor.white
        self.logLabel.text = time
        self.labelBackgrondView.layer.cornerRadius = 12.0
        self.labelBackgrondView.backgroundColor = UIColor.logBackground()
    }
}
