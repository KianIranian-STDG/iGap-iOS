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

typealias MessageCalculatedSize = (bubbleSize: CGSize, messageAttachmentHeight: CGFloat)

class CellSizeCalculator: NSObject {
    
    struct ConstantSizes {
        struct Bubble {
            struct Height {
                struct Minimum {
                    static let Attachment: CGFloat = 50.0
                }
                struct Maximum {
                    static let Attachment: CGFloat = 400.0
                }
            }
            struct Width {
                struct Minimum {
                    static let Text:       CGFloat = 80.0
                    static let Attachment: CGFloat = 80.0
                }
                struct Maximum {
                    static let Text:        CGFloat = 300.0
                    static let Attachment:  CGFloat = 300.0
                }
            }
        }
        
        struct Text {
            static let Height: CGFloat = 30.0
        }
        
        struct Media { // pictural file --> image, video, gif
            static let ExtraHeight: CGFloat = 50.0
            static let ExtraHeightWithText: CGFloat = 25.0
        }
        
        struct Audio {
            static let Width: CGFloat = 250.0
            static let Height: CGFloat = 95.0
        }
        
        struct Voice {
            static let Width: CGFloat = 230.0
            static let Height: CGFloat = 80.0
        }
        
        struct File {
            static let Width: CGFloat = 250.0
            static let Height: CGFloat = 70.0
        }
        
        struct Location {
            static let Width: CGFloat = 230.0
            static let Height: CGFloat = 130.0
        }
        
        struct Contact {
            static let Width: CGFloat = 230.0
            static let Height: CGFloat = 70.0
        }
        
        struct Log {
            static let Height: CGFloat = 30.0
        }
    }
    
    var cache : NSCache<NSString, AnyObject>
    private static let EXTRA_HEIGHT_RTL = 20
    internal static let RTL_OFFSET = -(EXTRA_HEIGHT_RTL - 7)
    
    static let sharedCalculator = CellSizeCalculator()
    
    private override init() {
        cache = NSCache()
        cache.countLimit = 200
        cache.name = "im.igap.cache.CellSizeCalculator"
    }
    
    class func messageBodyTextViewFont() -> UIFont {
        return UIFont.igFont(ofSize: 15.0)
    }
    
    func mainBubbleCountainerSize(for message:IGRoomMessage) -> MessageCalculatedSize {
        
        let cacheKey = "\(String(describing: message.primaryKeyId))_\(message.messageVersion)" as NSString
        let cachedSize = cache.object(forKey: cacheKey)
        if cachedSize != nil {
            return cachedSize as! MessageCalculatedSize
        }

        var finalSize = CGSize.zero
        var messageAttachmentHeight: CGFloat = 0.0
        
        var finalMessage = message
        if let forward = message.forwardedFrom {
            finalMessage = forward
            finalSize.height += 30
        } else if message.repliedTo != nil {
            finalSize.height += 54
        }
        
        let text = finalMessage.message as NSString?
        
        if finalMessage.attachment != nil {
            let attachmentFrame = mediaFrame(media: finalMessage.attachment!,
                                             maxWidth:  ConstantSizes.Bubble.Width.Maximum.Attachment,
                                             maxHeight: ConstantSizes.Bubble.Height.Maximum.Attachment,
                                             minWidth:  ConstantSizes.Bubble.Width.Minimum.Attachment,
                                             minHeight: ConstantSizes.Bubble.Height.Minimum.Attachment)
            
            switch finalMessage.type {
            case .image, .imageAndText, .video, .videoAndText, .gif, .gifAndText:
                messageAttachmentHeight = attachmentFrame.height
                if text != nil && text != "" {
                    finalSize.height += ConstantSizes.Media.ExtraHeightWithText
                } else {
                    finalSize.height += ConstantSizes.Media.ExtraHeight
                }
                
                finalSize.height += attachmentFrame.height
                finalSize.width = attachmentFrame.width
                break
                
            case .audio, .audioAndText:
                finalSize.width = ConstantSizes.Audio.Width
                finalSize.height += ConstantSizes.Audio.Height
                break
                
            case .voice:
                finalSize.width = ConstantSizes.Voice.Width
                finalSize.height += ConstantSizes.Voice.Height
                break
                
            case .file, .fileAndText:
                finalSize.width = ConstantSizes.Voice.Width
                finalSize.height += ConstantSizes.File.Height
                break
                
            case .location: break
            case .log: break
            case .contact: break
            case .text: break
            case .unknown: break
            }
            
            if text != nil && text != "" {
                let stringRect = CellSizeCalculator.bodyRect(text: text!, isEdited: finalMessage.isEdited)
                finalSize.height += stringRect.height
            }
            
        } else if finalMessage.type == .log {
            finalSize.height = ConstantSizes.Log.Height
            
        } else if finalMessage.type == .contact {
            let contactHeight = ContactCell.getContactHeight(finalMessage.contact!)
            finalSize.width = ConstantSizes.Contact.Width
            finalSize.height += ConstantSizes.Contact.Height
            finalSize.height += contactHeight
            
        } else if finalMessage.type == .location {
            finalSize.width = ConstantSizes.Location.Width
            finalSize.height += ConstantSizes.Location.Height
            messageAttachmentHeight = finalSize.height
            
        } else { // Text Message
            if text != nil && text != "" {
                let stringRect = CellSizeCalculator.bodyRect(text: text!, isEdited: finalMessage.isEdited)
                finalSize.height += ConstantSizes.Text.Height
                finalSize.height += stringRect.height
                if stringRect.width < ConstantSizes.Bubble.Width.Minimum.Text {
                    finalSize.width = ConstantSizes.Bubble.Width.Minimum.Text
                } else {
                    finalSize.width = stringRect.width
                }
            }
        }
        
        let result = (finalSize, messageAttachmentHeight)
        cache.setObject(result as AnyObject, forKey: cacheKey)
        return result
    }
    
    
    class func getStringStyle() -> [String: Any]{
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        return [NSFontAttributeName: messageBodyTextViewFont(), NSParagraphStyleAttributeName: paragraph]
    }
    
    class func bodyRect(text: NSString, isEdited: Bool) -> CGSize {
        
        var textWithTime = text as String
        if textWithTime.isRTL() {
            textWithTime = textWithTime.appending("xxx")
        } else {
            if isEdited {
                textWithTime = textWithTime.appending("xxxxxxxxxxxxxxxxxxx") // e.g. 12:00 edited
            } else {
                textWithTime = textWithTime.appending("xxxxxxxxxx") // e.g. 12:00
            }
        }
        
        var stringRect = textWithTime.boundingRect(
            with: CGSize(width: ConstantSizes.Bubble.Width.Maximum.Text, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: getStringStyle(), context: nil)
        
        if textWithTime.isRTL() {
            stringRect.size.height = stringRect.height + CGFloat(EXTRA_HEIGHT_RTL)
        }
        
        return stringRect.size
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
