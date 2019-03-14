/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */


class CellSizeLimit: NSObject {
    
    /* update box values size in chat */
    static func updateValues(roomId: Int64 = -1) {
        let _ = CellSizeLimit(roomId: roomId)
    }
    
    private init(roomId: Int64 = -1) {
        
        let width = IGGlobal.fetchUIScreen().width
        
        let maximumTextWidth = ConstantSizes.Bubble.Width.Maximum.Text + 50
        let maximumAttachmentWidth = ConstantSizes.Bubble.Width.Maximum.Attachment + 50
        let maximumStickerWidth = ConstantSizes.Bubble.Width.Maximum.Sticker + 50
        
        if maximumTextWidth >= width {
            ConstantSizes.Bubble.Width.Maximum.Text = width - 50
        }
        if maximumAttachmentWidth >= width {
            ConstantSizes.Bubble.Width.Maximum.Attachment = width - 50
        }
        if maximumStickerWidth >= width {
            ConstantSizes.Bubble.Width.Maximum.Sticker = width - 50
        }
        
        if let room = IGRoom.getRoomInfo(roomId: roomId), room.type == .channel {
            ConstantSizes.Bubble.Width.Minimum.Text = ChannelConstantSizes.Width.Minimum.Text
            ConstantSizes.Bubble.Width.Minimum.Attachment = ChannelConstantSizes.Width.Minimum.Attachment
        } else {
            ConstantSizes.Bubble.Width.Minimum.Text = 80
            ConstantSizes.Bubble.Width.Minimum.Attachment = 80
        }
    }
    
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
                    static var Text:       CGFloat = 80.0
                    static let Additional: CGFloat = 200.0
                    static var Attachment: CGFloat = 80.0
                    static var Sticker:    CGFloat = 80.0
                }
                struct Maximum {
                    static var Text:        CGFloat = 300.0
                    static var Attachment:  CGFloat = 300.0
                    static var Sticker:     CGFloat = 150.0
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
        
        struct Wallet {
            static let Width: CGFloat = 220.0
            static let Height: CGFloat = 300.0
        }
    }
    
    private struct ChannelConstantSizes {
        struct Width {
            struct Minimum {
                static let Text:       CGFloat = 250.0
                static let Attachment: CGFloat = 250.0
                static let Sticker:    CGFloat = 250.0
            }
        }
    }
}