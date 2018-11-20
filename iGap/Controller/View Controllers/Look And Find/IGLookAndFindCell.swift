/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import IGProtoBuff

class IGLookAndFindCell: UITableViewCell {

    @IBOutlet weak var avatarView: IGAvatarView!
    @IBOutlet weak var txtIcon: UILabel!
    @IBOutlet weak var txtResultName: UILabel!
    @IBOutlet weak var txtResultUsername: UILabel!
    @IBOutlet weak var txtHeader: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setSearchResult(result: IGLookAndFindStruct){
        if result.type == .room {
            setRoom(room: result.room)
        } else if result.type == .user {
            setUser(user: result.user)
        } else if result.type == .message || result.type == .hashtag {
            setMessage(message: result.message)
        }
    }
    
    func setHeader(type: IGSearchType){
        if type == .room {
            txtHeader.text = "Rooms"
        } else if type == .user {
            txtHeader.text = "Contacts"
        } else if type == .message {
            txtHeader.text = "Messages"
        } else if type == .hashtag {
            txtHeader.text = "Hashtag"
        }
    }
    
    private func setRoom(room: IGRoom, message: String? = nil) {
        txtResultName.text = room.title
        
        if message != nil {
            txtResultUsername.text = message
            if room.type == .chat {
                txtIcon.text = ""
            } else if room.type == .group {
                txtIcon.text = ""
            } else if room.type == .channel {
                txtIcon.text = ""
            }
        } else {
            if room.type == IGRoom.IGType.group {
                txtResultUsername.text = room.groupRoom?.publicExtra?.username
                txtIcon.text = ""
            } else {
                txtResultUsername.text = room.channelRoom?.publicExtra?.username
                txtIcon.text = ""
            }
        }
        
        avatarView.setRoom(room)
    }
    
    private func setUser(user: IGRegisteredUser, message: String? = nil) {
        txtResultName.text = user.displayName
        if message != nil {
            txtResultUsername.text = message
        } else {
            txtResultUsername.text = user.username
        }
        txtIcon.text = ""
        
        avatarView.setUser(user)
    }
    
    private func setMessage(message: IGRoomMessage){
        setRoom(room: IGRoom.getRoomInfo(roomId: message.roomId), message: message.message)
    }
}
