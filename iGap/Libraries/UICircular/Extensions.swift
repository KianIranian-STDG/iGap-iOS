/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */
/**
 * This file includes internal extensions.
 */

/// Helper extension to allow removing layer animation based on AnimationKeys enum
extension CALayer {
    func removeAnimation(forKey key: UICircularRing.AnimationKeys) {
        removeAnimation(forKey: key.rawValue)
    }

    func animation(forKey key: UICircularRing.AnimationKeys) -> CAAnimation? {
        return animation(forKey: key.rawValue)
    }

    func value(forKey key: UICircularRing.AnimationKeys) -> Any? {
        return value(forKey: key.rawValue)
    }
}

/**
 A private extension to CGFloat in order to provide simple
 conversion from degrees to radians, used when drawing the rings.
 */
extension CGFloat {
    var rads: CGFloat { return self * CGFloat.pi / 180 }
}

/// adds simple conversion to CGFloat
extension TimeInterval {
    var float: CGFloat { return CGFloat(self) }
}

/// adds simple conversion to TimeInterval
extension CGFloat {
    var interval: TimeInterval { return TimeInterval(self) }
}
