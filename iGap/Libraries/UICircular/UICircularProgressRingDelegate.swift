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

/**
 This is the protocol declaration for the UICircularRing delegate property
 
 ## Important ##
 When progress is done updating via UICircularRing.setValue(_:), the
 finishedUpdatingProgress(forRing: UICircularRing) will be called.
 
 The ring will be passed to the delegate in order to keep 
 track of multiple ring updates if needed.
 
 ## Author
 Luis Padron
 */
public protocol UICircularProgressRingDelegate: class {
    /**
     Called when progress ring is done animating for current value
     
     - Paramater
        - ring: The ring which finished animating
     
     */
    func didFinishProgress(for ring: UICircularProgressRing)

    /**
     Called when progress has paused

     - Parameter:
       - ring: The ring which has paused
     */
    func didPauseProgress(for ring: UICircularProgressRing)

    /**
     Called when the progress has continued after a pause

     - Parameter:
       - ring: The ring which has continued
     */
    func didContinueProgress(for ring: UICircularProgressRing)

    /**
     This method is called whenever the value is updated, this means during animation this method will be called in real time.
     This can be used to update another label or do some other work, whenever you need the exact current value of the ring
     during animation.

     ## Important:

     This is a very hot method and may be called hundreds of times per second during animations. As such make sure to only
     do very simple and non-intensive work in this method. Doing any work that takes time will considerably slow down your application.

     - Paramater
        - ring: The ring which updated the progress
        - newValue: The value which the ring has updated to
     */
    func didUpdateProgressValue(for ring: UICircularProgressRing, to newValue: CGFloat)

    /**
     This method is called whenever the label is about to be drawn.
     This can be used to modify the label looks e.g. NSAttributedString for text kerning

     - Paramater
        - ring: The ring which the label will be displayed in
        - label: The label which will be displayed
     */
    func willDisplayLabel(for ring: UICircularProgressRing, _ label: UILabel)
}
