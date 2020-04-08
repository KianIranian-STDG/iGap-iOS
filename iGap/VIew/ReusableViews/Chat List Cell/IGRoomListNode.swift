//
//  PhotoTableNodeCell.swift
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

import Foundation
import AsyncDisplayKit

class IGRoomListNode: ASCellNode {

    // MARK: Properties
    let bgPin : ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .scaleAspectFill
        node.cornerRadius = 10
        node.backgroundColor = .lightGray
        node.style.width = ASDimensionMake(.points, UIScreen.main.bounds.width)
        node.style.height = ASDimensionMake(.points, 100)

        return node
    }()
    let fakedisplay : ASDisplayNode = {
        let node = ASDisplayNode()


        node.backgroundColor = .red
        node.style.width = ASDimensionMake(.points, (UIScreen.main.bounds.width) - 100)
        node.style.height = ASDimensionMake(.points, 80)

        return node

    } ()
//    let usernameLabel = ASTextNode()
//    let timeIntervalLabel = ASTextNode()
//    let photoLikesLabel = ASTextNode()
//    let photoDescriptionLabel = ASTextNode()
    
    let avatarImageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.contentMode = .scaleAspectFill
        node.style.width = ASDimensionMake(.points, 80)
        node.style.height = ASDimensionMake(.points, 80)
        // Set the imageModificationBlock for a rounded avatar
        node.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
        return node
    }()
    
    
    // MARK: Lifecycle
    
    init(photoModel: UIImage) {
        super.init()

        automaticallyManagesSubnodes = true
//        photoImageNode.url = URL(string: photoModel.url)
        avatarImageNode.image = photoModel
//        usernameLabel.attributedText = photoModel.attributedStringForUserName(withSize: Constants.CellLayout.FontSize)
//        timeIntervalLabel.attributedText = photoModel.attributedStringForTimeSinceString(withSize: Constants.CellLayout.FontSize)
//        photoLikesLabel.attributedText = photoModel.attributedStringLikes(withSize: Constants.CellLayout.FontSize)
//        photoDescriptionLabel.attributedText = photoModel.attributedStringForDescription(withSize: Constants.CellLayout.FontSize)
    }
    
    // MARK: ASDisplayNode
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        // Header Stack
        
//        var headerChildren: [ASLayoutElement] = []
//
//        let headerStack = ASStackLayoutSpec.horizontal()
//        headerStack.alignItems = .center
//        avatarImageNode.style.preferredSize = CGSize(
//            width: Constants.CellLayout.UserImageHeight,
//            height: Constants.CellLayout.UserImageHeight
//        )
//        headerChildren.append(ASInsetLayoutSpec(insets: Constants.CellLayout.InsetForAvatar, child: avatarImageNode))
//
//        usernameLabel.style.flexShrink = 1.0
//        headerChildren.append(usernameLabel)
//
//        let spacer = ASLayoutSpec()
//        spacer.style.flexGrow = 1.0
//        headerChildren.append(spacer)
//
//        timeIntervalLabel.style.spacingBefore = Constants.CellLayout.HorizontalBuffer
//        headerChildren.append(timeIntervalLabel)
//
//        let footerStack = ASStackLayoutSpec.vertical()
//        footerStack.spacing = Constants.CellLayout.VerticalBuffer
//        footerStack.children = [photoLikesLabel, photoDescriptionLabel]
//        headerStack.children = headerChildren
//
//        let verticalStack = ASStackLayoutSpec.vertical()
//        verticalStack.children = [
//            ASInsetLayoutSpec(insets: Constants.CellLayout.InsetForHeader, child: headerStack),
//            ASRatioLayoutSpec(ratio: 1.0, child: photoImageNode),
//            ASInsetLayoutSpec(insets: Constants.CellLayout.InsetForFooter, child: footerStack)
//        ]
        

        
        let horizentalStackOne = ASStackLayoutSpec()
        horizentalStackOne.alignContent = .start
        horizentalStackOne.justifyContent = .center
        horizentalStackOne.verticalAlignment = .center
        horizentalStackOne.children = [fakedisplay,avatarImageNode]
        
        let pinBGStack = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50), child: bgPin)
        let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .center, flexWrap: .noWrap, alignContent: .center, lineSpacing: 0, children: [pinBGStack])
        
        let overlayStack = ASOverlayLayoutSpec(child: verticalStack, overlay: horizentalStackOne)

        return overlayStack
    }
}
