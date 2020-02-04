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
import SnapKit
import SwiftEventBus

class IGMusicNode: AbstractNode {
    private var txtMusicName = ASTextNode()
    private var txtMusicArtist = ASTextNode()
    private var imgDefaultCover = ASNetworkImageNode()
    private var imgMusicAvatar = ASNetworkImageNode()
    private var testView = ASDisplayNode()

    override init(message: IGRoomMessage, isIncomming: Bool, isTextMessageNode: Bool = false,finalRoomType : IGRoom.IGType,finalRoom : IGRoom) {
        super.init(message: message, isIncomming: isIncomming, isTextMessageNode: isTextMessageNode,finalRoomType : finalRoomType, finalRoom: finalRoom)
        setupView()
    }
    
    
    override func setupView() {
        super.setupView()
        
        imgDefaultCover.style.preferredSize = CGSize(width: 50, height: 50)
        imgDefaultCover.layer.cornerRadius = 25
        imgDefaultCover.image = UIImage(named: "igap_default_music")
        IGGlobal.makeAsyncText(for: txtMusicArtist, with: "Siavash Ghomeishi", textColor: .darkGray, size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)

        imgMusicAvatar.style.preferredSize = CGSize(width: 50, height: 50)
        imgMusicAvatar.layer.cornerRadius = 25
        //        btnStateNode.layer.cornerRadius = 25
        
        //make current time text
//        IGGlobal.makeText(for: self.txtCurrentTimeNode, with: "00:00".inLocalizedLanguage(), textColor: .lightGray, size: 12, numberOfLines: 1, font: .igapFont,alignment: .left)
        //        msgTextNode.isUserInteractionEnabled = true

        addSubnode(txtMusicName)
        addSubnode(txtMusicArtist)
        addSubnode(imgDefaultCover)
        addSubnode(imgMusicAvatar)
//        addSubnode(btnStateNode)
        addSubnode(indicatorViewAbs)
//        checkButtonState(btn: btnStateNode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.getMetadata(file: self.message.attachment)
        }

        
    }
    
    
    func checkButtonState(btn : ASButtonNode) {
        if IGGlobal.isFileExist(path: message.attachment!.path(), fileSize: message.attachment!.size) {
            indicatorViewAbs.isHidden = true
            indicatorViewAbs.style.preferredSize = CGSize.zero
            btnStateNode.style.preferredSize = CGSize(width: 50, height: 50)
            btnStateNode.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 35), with: .black, for: .normal)
            
        } else {
            indicatorViewAbs.isHidden = false
            indicatorViewAbs.style.preferredSize = CGSize(width: 50, height: 50)
            btnStateNode.style.preferredSize = CGSize.zero
            btnStateNode.style.preferredSize = CGSize(width: 50, height: 50)
            btnStateNode.setTitle("🎗", with: UIFont.iGapFonticon(ofSize: 35), with: .black, for: .normal)

        }
        
        
    }
    

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let textBox = ASStackLayoutSpec.vertical()
        textBox.justifyContent = .spaceAround
        textBox.children = [txtMusicName,txtMusicArtist]
        textBox.spacing = 0
        
        let overlayBox = ASOverlayLayoutSpec(child: imgMusicAvatar, overlay: indicatorViewAbs)
        let defaultBox = ASOverlayLayoutSpec(child: imgDefaultCover, overlay: overlayBox)

        let attachmentBox = ASStackLayoutSpec.horizontal()
        attachmentBox.spacing = 10
        attachmentBox.children = [defaultBox, textBox]
        
        
        // Apply text truncation
        let elems: [ASLayoutElement] = [txtMusicArtist,txtMusicName,overlayBox, textBox, attachmentBox]
        for elem in elems {
            elem.style.flexShrink = 1
        }
        
        let insetBox = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: attachmentBox
        )
        
        return insetBox
        
        
    }
    
    
    func getMetadata(file : IGFile!) {
        let path = attachment!.path()
        let asset = AVURLAsset(url: path!)
        let playerItem = AVPlayerItem(asset: asset)
        let metadataList = playerItem.asset.commonMetadata
        var hasSingerName : Bool = false
        var hasSongName : Bool = false
        var hasArtwork : Bool = false
        
        for item in metadataList {
            if item.commonKey!.rawValue == "title" {
                let songName = item.stringValue!
                hasSongName = true
                IGGlobal.makeAsyncText(for: txtMusicName, with: songName, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)


            }
            if item.commonKey!.rawValue == "artist" {
                let singerName = item.stringValue!
                hasSingerName = true
                IGGlobal.makeAsyncText(for: txtMusicArtist, with: singerName, textColor: .darkGray, size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)

            }
            if item.commonKey!.rawValue == "artwork" {
                hasArtwork = true

                                if let imageData = item.dataValue {
                                    DispatchQueue.global(qos: .userInteractive).async {
                                        let image = UIImage(data: imageData)
                                        DispatchQueue.main.async {
                                            self.imgMusicAvatar.image = image
                                        }
                                    }
                                }
            }

        }
        if !hasArtwork {
            imgMusicAvatar.setThumbnail(for: file)

        }
        if !hasSingerName {
            let singerName = IGStringsManager.UnknownArtist.rawValue.localized
            IGGlobal.makeAsyncText(for: txtMusicArtist, with: singerName, textColor: .darkGray, size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)

            

        }
        if !hasSongName {
            if let sn =  attachment?.name {
                let songName = sn
                IGGlobal.makeAsyncText(for: txtMusicName, with: songName, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)

            } else {
                let songName = IGStringsManager.UnknownAudio.rawValue.localized
                IGGlobal.makeAsyncText(for: txtMusicName, with: songName, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)

                
            }
        }

        
//            if let artworkItem = artworkItems.first {
//                // Coerce the value to an NSData using its dataValue property
//                if let imageData = artworkItem.dataValue {
//                    DispatchQueue.global(qos: .userInteractive).async {
//                        let image = UIImage(data: imageData)
//                        DispatchQueue.main.async {
//                            self.imgMusicAvatar.image = image
//                        }
//                    }
//                }
                
// //                process image
//            } else {
//                let avatarView : ASNetworkImageNode = ASNetworkImageNode()
//                avatarView.setThumbnail(for: file)
//                if message.attachment!.name!.contains(".mp3") {
//                    let name = message.attachment!.name!.replacingOccurrences(of: ".mp3", with: "")
//                    IGGlobal.makeAsyncText(for: txtMusicName, with: name, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
//
//
//                } else {
//                    IGGlobal.makeAsyncText(for: txtMusicName, with: message.attachment!.name!, textColor: .black, size: 14,weight: .bold, numberOfLines: 1, font: .igapFont, alignment: .left)
//
//                }
//                IGGlobal.makeAsyncText(for: txtMusicArtist, with: IGStringsManager.UnknownArtist.rawValue.localized, textColor: .darkGray, size: 14, numberOfLines: 1, font: .igapFont, alignment: .left)
//
//                if let image = avatarView.image {
//                    self.imgMusicAvatar.image = image
//                }
//            }
        }

    
    
}


