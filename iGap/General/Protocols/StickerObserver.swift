/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

protocol StickerToolbarObserver {
    func onToolbarClick(index: Int)
}

protocol StickerAddListener {
    func onStickerAdd(index: Int)
}

protocol StickerCurrentGroupIdObserver {
    func fetchCurrentStickerGroupId() -> String
}
