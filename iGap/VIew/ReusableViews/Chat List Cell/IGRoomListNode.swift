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
        node.clipsToBounds = true
        return node
    }()
    let fakedisplay : ASDisplayNode = {
        let node = ASDisplayNode()


        node.backgroundColor = .red
        node.style.width = ASDimensionMake(.points, 200)
        node.style.height = ASDimensionMake(.points, 80)

        return node

    } ()
    let fakedisplayOne : ASDisplayNode = {
        let node = ASDisplayNode()


        node.backgroundColor = .red
        node.style.width = ASDimensionMake(.points, 20)
        node.style.height = ASDimensionMake(.points, 20)

        return node

    } ()
    let fakedisplayTwo : ASDisplayNode = {
        let node = ASDisplayNode()


        node.backgroundColor = .red
        node.style.width = ASDimensionMake(.points, 300)
        node.style.height = ASDimensionMake(.points, 20)

        return node

    } ()
    let fakedisplayThree : ASDisplayNode = {
        let node = ASDisplayNode()


        node.backgroundColor = .red
        node.style.width = ASDimensionMake(.points, 300)
        node.style.height = ASDimensionMake(.points, 20)

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
        
        


        let horizentalStackOne = ASStackLayoutSpec()
        horizentalStackOne.alignContent = .start
        horizentalStackOne.justifyContent = .end
        horizentalStackOne.verticalAlignment = .center
        horizentalStackOne.children = [fakedisplay,avatarImageNode]
        horizentalStackOne.spacing = 10
        
        let insetMain = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), child: horizentalStackOne)

        let pinBGStack = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50), child: bgPin)
        let pinv = ASDisplayNode()
        let pinVHeight : CGFloat = 12
        pinv.style.width = ASDimensionMake(.points,pinVHeight)
        pinv.style.height = ASDimensionMake(.points,pinVHeight)
        pinv.backgroundColor = .blue
        pinv.cornerRadius = pinVHeight / 2
        pinv.layer.maskedCorners = [.layerMaxXMaxYCorner]

        let pinTagStack = ASCornerLayoutSpec(child: pinBGStack, corner:pinv, location: .topLeft)
        pinTagStack.offset = CGPoint(x: pinVHeight / 2, y: pinVHeight / 2)
//        let pinTagStackInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0), child: pinTagStack)

        let verticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .center, flexWrap: .noWrap, alignContent: .center, lineSpacing: 0, children: [pinTagStack])
        
        let overlayStack = ASOverlayLayoutSpec(child: verticalStack, overlay: insetMain)

        let finalStackInset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0), child: overlayStack)
        
        
        return finalStackInset
    }
}
