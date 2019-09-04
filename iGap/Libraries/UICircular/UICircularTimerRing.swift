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

final public class UICircularTimerRing: UICircularRing {
    // MARK: Members

    /**
     The formatter used when formatting the value into a string for the ring.

     Default formatter is of type `UICircularTimerRingFormatter`.
     */
    public var valueFormatter: UICircularRingValueFormatter = UICircularTimerRingFormatter() {
        didSet { ringLayer.valueFormatter = valueFormatter }
    }

    /**
     The handler for the timer.

     The handler is called whenever the timer finishes or is paused.
     If the timer is paused handler will be called with (false, elapsedTime)
     Otherwise the handler will be called with (true, finalTime)
     */
    public typealias TimerHandler = (State) -> Void

    // MARK: Private Members

    /// This is the max value for the layer, which corresponds
    /// to the time that was set for the timer
    private var time: TimeInterval = 60 {
        didSet {
            ringLayer.value = time.float
            ringLayer.maxValue = time.float
        }
    }

    /// the elapsed time since calling `startTimer`
    private var elapsedTime: TimeInterval? {
        return layer.presentation()?.value(forKey: .value) as? TimeInterval
    }

    /// the completion for over all timer
    private var timerHandler: TimerHandler?

    // MARK: API

    /**
     Starts the timer until the given time is elapsed.
     */
    public func startTimer(to time: TimeInterval, handler: TimerHandler?) {
        startAnimation(duration: time) {
            self.timerHandler?(.finished)
        }

        self.time = time
        self.timerHandler = handler
    }

    /**
     Pauses the timer.

     Handler will be called with (false, elapsedTime)
     */
    public func pauseTimer() {
        timerHandler?(.paused(elpasedTime: elapsedTime))
        pauseAnimation()
    }

    /**
     Continues the timer from a previously paused time.
     */
    public func continueTimer() {
        self.timerHandler?(.continued(elapsedTime: elapsedTime))
        continueAnimation {
            self.timerHandler?(.finished)
        }
    }

    /**
     Resets the timer, this means the time is reset and
     previously set handler will no longer be used.
     */
    public func resetTimer() {
        resetAnimation()
        ringLayer.value = 0
        timerHandler = nil
    }

    // MARK: Overrides

    /// initialize with some defaults relevant to this timer ring
    override func initialize() {
        super.initialize()
        ringLayer.ring = self
        ringLayer.minValue = 0
        ringLayer.value = 0
        ringLayer.maxValue = time.float
        ringLayer.valueFormatter = valueFormatter
        ringLayer.animationTimingFunction = .linear
    }
}

// MARK: UICircularTimerRing.State

public extension UICircularTimerRing {
    /// state of the timer ring, used in handler
    enum State {
        /// the timer has finished
        case finished

        /// the timer was continued called `continueTimer`
        case continued(elapsedTime: TimeInterval?)

        /// the timer was paused called `pauseTimer`
        case paused(elpasedTime: TimeInterval?)
    }
}
