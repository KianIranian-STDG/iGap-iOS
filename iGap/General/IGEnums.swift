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
import IGProtoBuff
import SwiftProtobuf

enum AppStoryboard : String {
    
    case Main = "Main"
    case Profile = "profile"
    case EditProfile = "EditProfileChannelAndGroup"
    case CreateRoom = "CreateRoom"
    case Search = "Search"
    case Register = "Register"
    case Setting = "IGSettingStoryboard"
    case ElectroBill = "ElectroBill"
    case PhoneBook = "PhoneBook"
    case FinancialHistory = "FinancialHistory"
    case Wallet = "wallet"
    case InternetPackage = "InternetPackage"
    case Message = "Message"
    case News = "News"
    case MemoryTest = "MemoryTest"

    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: nil)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
    
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}

enum IGGender: Int {
    case unknown = 0
    case male
    case female
    
}

enum IGDevice: Int {
    case unknown = 0
    case desktop
    case tablet
    case mobile
}

enum IGPlatform: Int {
    case unknown = 0
    case android
    case iOS
    case macOS
    case windows
    case linux
    case blackberry
}

enum IGLanguage: Int {
    case en_us
    case fa_ir
}

enum AlertState: Int {
    case Ok
    case No
}

enum IGRoomMessageStatus: Int {
    case unknown = -1
    case failed
    case sending
    case sent
    case delivered
    case seen
    case listened
    
    static func fromIGP(status: IGPRoomMessageStatus) -> IGRoomMessageStatus {
        switch status {
        case .failed:
            return .failed
        case .sending:
            return .sending
        case .sent:
            return .sent
        case .delivered:
            return .delivered
        case .seen:
            return .seen
        case .listened:
            return .listened
        default:
            return .unknown
        }
    }
    
    //TODO - find value from enum and don't use from switch case if is possible
    static func fetchIGPValue(_ status: IGPRoomMessageStatus) -> Int {
        switch status {
        case .failed:
            return 0
        case .sending:
            return 1
        case .sent:
            return 2
        case .delivered:
            return 3
        case .seen:
            return 4
        case .listened:
            return 5
        default:
            return -1
        }
    }
    
    //TODO - find value from enum and don't use from switch case if is possible
    static func fetchIGValue(_ status: IGRoomMessageStatus) -> Int {
        switch status {
        case .failed:
            return 0
        case .sending:
            return 1
        case .sent:
            return 2
        case .delivered:
            return 3
        case .seen:
            return 4
        case .listened:
            return 5
        default:
            return -1
        }
    }
}

public enum IGRoomMessageType: Int {
    case unknown = -1
    case text
    case image
    case imageAndText
    case video
    case videoAndText
    case audio
    case audioAndText
    case voice
    case gif
    case file
    case fileAndText
    case location
    case log
    case contact
    case gifAndText
    case sticker
    case wallet
    case unread
    case time
    case progress
    
    func toIGP() -> IGPRoomMessageType {
        switch self {
        case .unknown, .text:
            return .text
        case .image:
            return .image
        case .imageAndText:
            return .imageText
        case .video:
            return .video
        case .videoAndText:
            return .videoText
        case .audio:
            return .audio
        case .audioAndText:
            return .audioText
        case .voice:
            return .voice
        case .gif:
            return .gif
        case .file:
            return .file
        case .fileAndText:
            return .fileText
        case .location:
            return .location
        case .log:
            return .log
        case .contact:
            return .contact
        case .gifAndText:
            return .gifText
        case .sticker:
            return .sticker
        case .wallet:
            return .wallet
        case .unread, .time, .progress:
            return .UNRECOGNIZED(-10)
        }
    }
    
    func fromIGP(_ igpType:IGPRoomMessageType, igpRoomMessage:IGPRoomMessage? = nil) -> IGRoomMessageType{
        
        /* check additional type */
        /*
        if let additionalType = igpRoomMessage?.igpAdditionalType {
            if additionalType == AdditionalType.STICKER.rawValue {
                return .sticker
            }
        }
        */
        
        switch igpType {
        case .text:
            return .text
        case .image:
            return .image
        case .imageText:
            return .imageAndText
        case .video:
            return .video
        case .videoText:
            return .videoAndText
        case .audio:
            return .audio
        case .audioText:
            return .audioAndText
        case .voice:
            return .voice
        case .gif:
            return .gif
        case .file:
            return .file
        case .fileText:
            return .fileAndText
        case .location:
            return .location
        case .log:
            return .log
        case .contact:
            return .contact
        case .gifText:
            return .gifAndText
        case .sticker:
            return .sticker
        case .wallet:
            return .wallet
        default:
            return .text
        }
    }
}

enum IGClientAction: Int {
    case cancel
    case typing
    case sendingImage
    case capturingImage
    case sendingVideo
    case capturingVideo
    case sendingAudio
    case recordingVoice
    case sendingVoice
    case sendingDocument
    case sendingGif
    case sendingFile
    case sendingLocation
    case choosingContact
    case painting
    
    func toIGP() -> IGPClientAction {
        switch self {
        case .cancel:
            return .cancel
        case .typing:
            return .typing
        case .sendingImage:
            return .sendingImage
        case .capturingImage:
            return .capturingImage
        case .sendingVideo:
            return .sendingVideo
        case .capturingVideo:
            return .capturingVideo
        case .sendingAudio:
            return .sendingAudio
        case .recordingVoice:
            return .recordingVoice
        case .sendingVoice:
            return .sendingVoice
        case .sendingDocument:
            return .sendingDocument
        case .sendingGif:
            return .sendingGif
        case .sendingFile:
            return .sendingFile
        case .sendingLocation:
            return .sendingLocation
        case .choosingContact:
            return .choosingContact
        case .painting:
            return .painting
        }
    }
    
    func fromIGP(_ igpAction: IGPClientAction) -> IGClientAction {
        switch igpAction {
        case .typing:
            return .typing
        case .cancel:
            return .cancel
        case .sendingImage:
            return .sendingImage
        case .capturingImage:
            return .capturingImage
        case .sendingVideo:
            return .sendingVideo
        case .capturingVideo:
            return .capturingVideo
        case .sendingAudio:
            return .sendingAudio
        case .recordingVoice:
            return .recordingVoice
        case .sendingVoice:
            return .sendingVoice
        case .sendingDocument:
            return .sendingDocument
        case .sendingGif:
            return .sendingGif
        case .sendingFile:
            return .sendingFile
        case .sendingLocation:
            return .sendingLocation
        case .choosingContact:
            return .choosingContact
        case .painting:
            return .painting
        default:
            return .cancel
        }
    }
}

enum IGProgressType {
    case download
    case upload
}

enum IGDeleteReasen: Int {
    case other
    
}

enum IGCheckUsernameStatus: Int {
    case invalid
    case taken
    case available
    case needsValidation
}

enum IGPassCodeViewMode: Int {
    case locked
    case turnOnPassCode
    case changePassCode
}

enum IGMemberRole: Int {
    case all
    case member
    case admin
    case moderator
}

enum IGSharedMediaFilter: Int {
    case image
    case video
    case audio
    case voice
    case gif
    case file
    case url
    
}

enum IGClientResolveUsernameType: Int {
    case user
    case room
}

enum IGPrivacyType: Int {
    case userStatus
    case avatar
    case groupInvite
    case channelInvite
    case voiceCalling
    case videoCalling
    case screenSharing
    case secretChat
}

enum IGPrivacyLevel: Int {
    case allowAll
    case denyAll
    case allowContacts
    
    func fromIGP(_ igpPrivacyLevel: IGPPrivacyLevel) -> IGPrivacyLevel {
        switch igpPrivacyLevel {
        case .allowAll:
            return .allowAll
        case .allowContacts:
            return .allowContacts
        case .denyAll:
            return . denyAll
        default:
            return . denyAll
        }
    }

}

enum IGTwoStepQuestion: Int {
    case changeRecoveryQuestion
    case questionRecoveryPassword
}

enum IGTwoStepEmail: Int {
    case verifyEmail
    case recoverPassword
}

enum IGOperator: Int {
    case irancell
    case mci
    case rightel
}

enum CommandState {
    case Odd
    case Even
}

enum ButtonState {
    case First
    case Second
}

enum BarcodeScanner {
    case Verify
    case IVandScore
    case BillBarcode
}

enum AdditionalType: Int32 {
    case NONE = 0
    case UNDER_KEYBOARD_BUTTON = 1
    case UNDER_MESSAGE_BUTTON = 2
    case BUTTON_CLICK_ACTION = 3
    case STICKER = 4
    case GIF = 5
    case STREAM_TYPE = 6
    case KEYBOARD_TYPE = 7
    case FORM_BUILDER = 8
    case WEBVIEW_SHOW = 9
    case CARD_TO_CARD_PAY = 12
}

enum StickerPageType: Int {
    case MAIN = 0 // for send sticker state in chat page
    case CATEGORY = 1 // category state for get categories from server and show latest list of sticker packages
    case PREVIEW = 2 // preview sticker for see all stickers for a package
}

enum ClearCache: Int {
    case IMAGES = 0
    case GIFS = 1
    case VIDEOS = 2
    case AUDIOS = 3
    case VOICES = 4
    case DOCUMENTS = 5
    case STICKERS = 6
}

enum CheckItem: Int {
    case CHECK = 0
    case UNCHECK = 1
}

enum TextViewOldState: Int {
    case EMPTY = 0
    case FULL = 1
}

enum AvatarType: Int {
    case user = 0
    case group = 1
    case channel = 2
    
    static func fromIG(_ type: IGRoom.IGType) -> AvatarType {
        switch type {
        case .chat:
            return .user
        case .group:
            return .group
        case .channel:
            return .channel
        }
    }
}

enum ContactExchangeLevel {
    case importing(percent: Double)
    case gettingList(percent: Double)
    case completed
}

enum ProgressState {
    case SHOW
    case HIDE
}

enum MediaPagerType {
    case avatar
    case image
    case video
    case imageAndVideo
}

enum GroupCreateMode {
    case newGroup
    case convertChatToGroup
}

enum ChatMessageAction {
    case receive
    case edit
    case delete
    case update
    case updateStatus
    case locallyUpdateStatus
    case channelGetMessageState
    case userInfo
    case addProgress
    case removeProgress
}

enum BaseFilePathType: Int {
    case document = 0 // main directory for store downloaded media
    case cache // auto downloadable files (thumnail, avatar, background, sticker)
    case temp // temp directory for store file at download levels
}

enum FilePathType {
    /***** Document Folder *****/
    case image
    case video
    case audio
    case voice
    case gif
    case file
    /***** Cache Folder *****/
    case avatar
    case sticker
    case background
    case thumb
    /***** Temp Folder *****/
    case temp
    
    case unknown
}

enum Status {
    case unknown
    
    case readyToDownload // also for 'downloadFailed' & 'downloadPause' use 'readyToDownload' enum
    case downloading
    
    case uploadFailed
    case uploading
    
    case ready
}

enum PreviewType: Int {
    case originalFile = 0
    case smallThumbnail
    case largeThumbnail
    case waveformThumbnail
}

enum FileType: Int {
    case image = 0
    case gif
    case video
    case audio
    case voice
    case file
    case sticker
    
    static func convertToFileType(messageType: IGRoomMessageType) -> FileType {
        switch messageType {
        case .audio, .audioAndText:
            return .audio
            
        case .image, .imageAndText:
            return .image
            
        case .video, .videoAndText:
            return .video
            
        case .voice:
            return .voice
            
        case .gif, .gifAndText:
            return .gif
            
        case .file, .fileAndText:
            return .file
            
        case .sticker:
            return .sticker
            
        default:
            return .image
        }
    }
}

enum FileTypeBasedOnNameExtension {
    case generic
    case docx
    case exe
    case pdf
    case txt
}
