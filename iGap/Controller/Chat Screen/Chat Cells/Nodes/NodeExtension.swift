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


class NodeExtension {

    static func fetchMediaFrame(media: IGFile) -> CGSize {
        return mediaFrame(media: media,
                          maxWidth:  CellSizeLimit.ConstantSizes.Bubble.Width.Maximum.Attachment,
                          maxHeight: CellSizeLimit.ConstantSizes.Bubble.Height.Maximum.Attachment,
                          minWidth:  CellSizeLimit.ConstantSizes.Bubble.Width.Minimum.Attachment,
                          minHeight: CellSizeLimit.ConstantSizes.Bubble.Height.Minimum.Attachment)
        
    }
    
    private static func mediaFrame(media: IGFile, maxWidth: CGFloat, maxHeight: CGFloat, minWidth: CGFloat, minHeight: CGFloat) -> CGSize {
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
    
    
//    static func fetchMediaFrame(image: UIImage) -> CGSize {
//        return mediaFrame(image: image,
//                          maxWidth:  CellSizeLimit.ConstantSizes.Bubble.Width.Maximum.Attachment,
//                          maxHeight: CellSizeLimit.ConstantSizes.Bubble.Height.Maximum.Attachment,
//                          minWidth:  CellSizeLimit.ConstantSizes.Bubble.Width.Minimum.Attachment,
//                          minHeight: CellSizeLimit.ConstantSizes.Bubble.Height.Minimum.Attachment)
//
//    }
//
//    fileprivate static func mediaFrame(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat, minWidth: CGFloat, minHeight: CGFloat) -> CGSize {
//        if image.size.width != 0 && image.size.height != 0 {
//            var width = CGFloat(image.size.width)
//            var height = CGFloat(image.size.height)
//            if width > maxWidth && height > maxHeight {
//                if width/maxWidth > height/maxHeight {
//                    height = height * maxWidth/width
//                    width = maxWidth
//                } else {
//                    width = width * maxHeight/height
//                    height = maxHeight
//                }
//            } else if width > maxWidth {
//                height = height * maxWidth/width
//                width = maxWidth
//            } else if height > maxHeight {
//                width = width * maxHeight/height
//                height = maxHeight
//            }
//            width  = max(width, minWidth)
//            height = max(height, minHeight)
//            return CGSize(width: width, height: height)
//        } else {
//            return CGSize(width: minWidth, height: minHeight)
//        }
//    }

}
