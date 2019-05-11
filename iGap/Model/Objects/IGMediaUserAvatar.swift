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
///import INSPhotoGallery
import IGProtoBuff

class IGMediaUserAvatar: INSPhotoViewable, Equatable {
    enum MediaType {
        case video
        case audio
    }
    
    var image: UIImage?
    var thumbnailImage: UIImage?
    var attributedTitle: NSAttributedString?
    var file: IGFile?
    var isDeletable : Bool {
        get {
            return true
            
        }
    }
    
    init(message: IGRoomMessage, forwardedMedia: Bool) {
        
        let roomMessage = message.forwardedFrom != nil ? message.forwardedFrom : message
        if let attachment = roomMessage?.attachment {
            file = attachment
            image = UIImage.originalImage(for: attachment)
            thumbnailImage = UIImage.thumbnail(for: attachment)
            if let text = roomMessage?.message {
                attributedTitle = NSAttributedString(string: text, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.white, convertFromNSAttributedStringKey(NSAttributedString.Key.backgroundColor): UIColor.black.withAlphaComponent(0.5)]))
            }
        }
    }
    
    
    init(avatar: IGAvatar) {
        if let file = avatar.file {
            self.file = file
            image = UIImage.originalImage(for: file)
            thumbnailImage = UIImage.thumbnail(for: file)
        }
    }
    
    func loadImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let image = image {
            completion(image, nil)
            return
        }
        self.image = UIImage.thumbnail(for: file!)
        IGDownloadManager.sharedManager.download(file: file!, previewType:.originalFile, completion: { (attachment) -> Void in
            self.image = UIImage.originalImage(for: attachment)
            completion(self.image, nil)
        }, failure: {})
    }
    
    
    func loadThumbnailImageWithCompletionHandler(_ completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        if let thumbnailImage = thumbnailImage {
            completion(thumbnailImage, nil)
            return
        }
        
        var finalFile: IGFile!
        var previewType: IGFile.PreviewType!
        
        if let file = file?.smallThumbnail {
            finalFile = file
            previewType = IGFile.PreviewType.smallThumbnail
        } else if let file = file?.largeThumbnail {
            finalFile = file
            previewType = IGFile.PreviewType.largeThumbnail
        } else if file != nil {
            finalFile = file
            previewType = IGFile.PreviewType.originalFile
        }
        
        if finalFile == nil { return }
        
        IGDownloadManager.sharedManager.download(file: finalFile!, previewType: previewType, completion: { (attachment) -> Void in
            self.thumbnailImage = UIImage.thumbnail(for: attachment)
            completion(self.thumbnailImage, nil)
        }, failure: {})
    }
}

func ==<T: IGMediaUserAvatar>(lhs: T, rhs: T) -> Bool {
    return lhs === rhs
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
