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

typealias MessageCalculatedSize = (bubbleSize: CGSize,
    forwardedMessageBodyHeight: CGFloat,
    forwardedMessageAttachmentHeight: CGFloat,
    messageBodyHeight: CGFloat,
    MessageAttachmentHeight: CGFloat)

class CellSizeCalculator: NSObject {
    
    var cache : NSCache<NSString, AnyObject>
    
    static let sharedCalculator = CellSizeCalculator()
    
    private override init() {
        cache = NSCache()
        cache.countLimit = 200
        cache.name = "im.igap.cache.IGMessageCollectionViewCellSizeCalculator"
    }
    
    //min image=> 50 x 50
    
    func mainBubbleCountainerSize(for message:IGRoomMessage) -> RoomMessageCalculatedSize {
        
        let cacheKey = "\(String(describing: message.primaryKeyId))_\(message.messageVersion)" as NSString
        let cachedSize = cache.object(forKey: cacheKey)
        if cachedSize != nil {
            return cachedSize as! RoomMessageCalculatedSize
        }
        
        var maximumWidth: CGFloat = 0.0
        if message.authorRoom != nil { //channel
            maximumWidth = IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.MaximumForChannels
        } else {
            maximumWidth = IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum
        }
        
        var finalSize = CGSize.zero
        var messageBodyHeight: CGFloat = 0.0
        var messageAttachmentHeight: CGFloat = 0.0
        
        var finalMessage = message
        if let forward = message.forwardedFrom {
            finalMessage = forward
            finalSize.height += 30
        } else if message.repliedTo != nil {
            finalSize.height += 54
        }
        
        if finalMessage.attachment != nil {
            let attachmentFrame = mediaFrame(media: finalMessage.attachment!,
                                             maxWidth:  maximumWidth,
                                             maxHeight: IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Maximum.AttachmentFiled,
                                             minWidth:  IGMessageCollectionViewCell.ConstantSizes.Bubble.Width.Maximum,
                                             minHeight: IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Minimum.WithAttachment)
            
            switch finalMessage.type {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                messageAttachmentHeight = attachmentFrame.height
                finalSize.height += attachmentFrame.height
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                break
                
            case .audio:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 50
                break
                
            case .audioAndText:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 70
                break
                
            case .voice:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 40.0
                break
                
            case .file:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 20.0
                break
                
            case .fileAndText:
                finalSize.width = max(finalSize.width, attachmentFrame.width)
                finalSize.width = min(finalSize.width, maximumWidth)
                finalSize.height += 40.0
                break
                
            case .location: break
            case .log:
                finalSize.height = 30.0
                break
            case .contact: break
            case .text: break
            case .unknown: break
            }
        }
        
        let text = finalMessage.message as NSString?
        if text != nil && text != "" {
            let stringRect = IGMessageCollectionViewCell.bodyRect(text: text!, isEdited: finalMessage.isEdited, addArbitraryTexts: true)
            finalSize.height += stringRect.height
            finalSize.width = max(finalSize.width, stringRect.width + 20)
            finalSize.width = min(finalSize.width, maximumWidth)
            messageBodyHeight = stringRect.height
        } else {
            finalSize.height += 40.0
        }
        
        if finalMessage.type == .log {
            finalSize.height = 30
        } else if finalMessage.type == .contact {
            let contactSize = IGContactInMessageCellView.sizeForContact(finalMessage.contact!)
            if (finalSize.height == 0) { // use this block for avoid from contact small show (bad view) before when message is in sending state
                finalSize.height = 40
            }
            finalSize.width = contactSize.width
            finalSize.height += contactSize.height
            
        } else if finalMessage.type == .location {
            let locationSize = LocationCell.sizeForLocation()
            finalSize.width = locationSize.width
            finalSize.height += locationSize.height
            messageAttachmentHeight = locationSize.height
            
        } else {
            finalSize.height = max(IGMessageCollectionViewCell.ConstantSizes.Bubble.Height.Minimum.TextOnly + 6, finalSize.height)
        }
        
        finalSize.height += 7.5
        
        let result = (finalSize,
                      messageBodyHeight,
                      messageAttachmentHeight,
                      messageBodyHeight,
                      messageAttachmentHeight)
        
        cache.setObject(result as AnyObject, forKey: cacheKey)
        
        return result
    }
    
    func mediaFrame(media: IGFile, maxWidth: CGFloat, maxHeight: CGFloat, minWidth: CGFloat, minHeight: CGFloat) -> CGSize {
        if media.width != 0 && media.height != 0 {
            var width = CGFloat(media.width)
            var height = CGFloat(media.height)
            if width > maxWidth && height > maxHeight {
                if width/maxWidth > height/maxHeight {
                    height = height * maxWidth/width
                    width = maxWidth
                } else {
                    width = width * maxHeight/height
                    height = maxHeight
                }
            } else if width > maxWidth {
                height = height * maxWidth/width
                width = maxWidth
            } else if height > maxHeight {
                width = width * maxHeight/height
                height = maxHeight
            }
            width  = max(width, minWidth)
            height = max(height, minHeight)
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: minWidth, height: minHeight)
        }
    }
    
}
