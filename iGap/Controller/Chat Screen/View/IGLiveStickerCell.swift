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
import Lottie

class IGLiveStickerCell: UICollectionViewCell {
    
    var animationView : AnimationView!
    var attachedFile : IGFile!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.height = 80.0
    }
    private func initTheme() {}
    func setLiveAvatar(animation: AnimationView!,attachment: IGFile!) {
        animationView = animation
        attachedFile = attachment
        makeAnimationView(attachmentJson: attachedFile)
    }
    private func makeAnimationView(attachmentJson: IGFile) {
            animationView.layer.masksToBounds = true
            animationView.contentMode = .scaleAspectFit
            animationView.backgroundColor = .clear
            self.addSubview(animationView)

            animationView.translatesAutoresizingMaskIntoConstraints = false
            animationView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            animationView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            animationView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            animationView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            animationView.setLiveSticker(for: attachmentJson)

        }

}
