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


protocol IGMessageGeneralCollectionViewCellDelegate: AnyObject { // Using AnyObject you say that only classes can conform to this protocol, whereas structs or enums can't.
    func didTapAndHoldOnMessage(cellMessage: IGRoomMessage,index: IndexPath)
    func swipToReply(cellMessage: IGRoomMessage)
    func didTapOnAttachment(cellMessage: IGRoomMessage)
    func didTapOnForwardedAttachment(cellMessage: IGRoomMessage)
    func didTapOnSenderAvatar(cellMessage: IGRoomMessage)
    func didTapOnReply(cellMessage: IGRoomMessage)
    func didTapOnForward(cellMessage: IGRoomMessage)
    func didTapOnMultiForward(cellMessage: IGRoomMessage, isFromCloud: Bool)
    func didTapOnFailedStatus(cellMessage: IGRoomMessage)
    func didTapOnReturnToMessage()
    func didTapOnHashtag(hashtagText: String)
    func didTapOnMention(mentionText: String)
    func didTapOnEmail(email: String)
    func didTapOnURl(url: URL)
    func didTapOnDeepLink(url: URL)
    func didTapOnRoomLink(link:String)
    func didTapOnBotAction(action:String)
}


class IGMessageGeneralCollectionViewCell: UICollectionViewCell {
    var cellMessage: IGRoomMessage?
    var attachment: IGFile?
    weak var delegate: IGMessageGeneralCollectionViewCellDelegate?
    func setMessage(_ message: IGRoomMessage, room: IGRoom, isIncommingMessage: Bool, shouldShowAvatar: Bool, messageSizes: MessageCalculatedSize, isPreviousMessageFromSameSender: Bool, isNextMessageFromSameSender: Bool) {}
}
