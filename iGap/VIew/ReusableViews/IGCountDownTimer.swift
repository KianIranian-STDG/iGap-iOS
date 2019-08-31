/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2019 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit

@objc public protocol IGCountdownTimerDelegate: class {
    @objc optional func timerDidUpdateCounterValue(newValue: Int)
    @objc optional func timerDidStart()
    @objc optional func timerDidPause()
    @objc optional func timerDidResume()
    @objc optional func timerDidEnd()
}

public class IGCountdownTimer: UIView {
    @IBInspectable public var lineWidth: CGFloat = 2.0
    @IBInspectable public var lineColor: UIColor = .iGapSubmitButtons()
    @IBInspectable public var trailLineColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    @IBInspectable public var isLabelHidden: Bool = false
    @IBInspectable public var labelFont: UIFont?
    @IBInspectable public var labelTextColor: UIColor?
    @IBInspectable public var timerFinishingText: String?
    
    public weak var delegate: IGCountdownTimerDelegate?
    
    // use minutes and seconds for presentation
    public var useMinutesAndSecondsRepresentation = false
    
    private var timer: Timer?
    private var beginingValue: Int = 1
    private var totalTime: TimeInterval = 1
    private var elapsedTime: TimeInterval = 0
    private var interval: TimeInterval = 1 // Interval which is set by a user
    private let fireInterval: TimeInterval = 0.01 // ~60 FPS
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        
        label.textAlignment = .center
        label.frame = self.bounds
        if let font = self.labelFont {
            label.font = font
        }
        if let color = self.labelTextColor {
            label.textColor = color
        }
        
        return label
    }()
    private var currentCounterValue: Int = 0 {
        didSet {
            if !isLabelHidden {
                if let text = timerFinishingText, currentCounterValue == 0 {
                    counterLabel.text = ("00:" + text).inLocalizedLanguage()
                } else {
                    if useMinutesAndSecondsRepresentation {
                        counterLabel.text = ("00:" +  getMinutesAndSeconds(remainingSeconds: currentCounterValue)).inLocalizedLanguage()
                    } else {
                        counterLabel.text = ("00:" + "\(currentCounterValue)").inLocalizedLanguage()
                    }
                }
            }
            
            delegate?.timerDidUpdateCounterValue?(newValue: currentCounterValue)
        }
    }
    
    // MARK: Inits
    override public init(frame: CGRect) {
        if frame.width != frame.height {
            fatalError("Please use a rectangle frame for IGCountdownTimer")
        }
        
        super.init(frame: frame)
        
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        let radius = (rect.width - lineWidth) / 2
        let currentAngle = CGFloat((.pi * 2 * elapsedTime) / totalTime)
        
        context?.setLineWidth(lineWidth)
        
        // Main line
        context?.beginPath()
        context?.addArc(
            center: CGPoint(x: rect.midX, y:rect.midY),
            radius: radius,
            startAngle: currentAngle - .pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: false)
        context?.setStrokeColor(lineColor.cgColor)
        context?.strokePath()
        
        // Trail line
        context?.beginPath()
        context?.addArc(
            center: CGPoint(x: rect.midX, y:rect.midY),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: currentAngle - .pi / 2,
            clockwise: false)
        context?.setStrokeColor(trailLineColor.cgColor)
        context?.strokePath()
    }
    
    // MARK: Public methods
    /**
     * Starts the timer and the animation. If timer was previously runned, it'll invalidate it.
     * - Parameters:
     *   - beginingValue: Value to start countdown from.
     *   - interval: Interval between reducing the counter(1 second by default)
     */
    public func start(beginingValue: Int, interval: TimeInterval = 1) {
        self.beginingValue = beginingValue
        self.interval = interval
        
        totalTime = TimeInterval(beginingValue) * interval
        elapsedTime = 0
        currentCounterValue = beginingValue
        
        timer?.invalidate()
        timer = Timer(timeInterval: fireInterval, target: self, selector: #selector(IGCountdownTimer.timerFired(_:)), userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer!, forMode: .common)
        
        delegate?.timerDidStart?()
    }
    
    /**
     * Pauses the timer with saving the current state
     */
    public func pause() {
        timer?.fireDate = Date.distantFuture
        
        delegate?.timerDidPause?()
    }
    
    /**
     * Resumes the timer from the current state
     */
    public func resume() {
        timer?.fireDate = Date()
        
        delegate?.timerDidResume?()
    }
    
    /**
     * End the timer
     */
    public func end() {
        self.currentCounterValue = 0
        timer?.invalidate()
        
        delegate?.timerDidEnd?()
    }
    
    /**
     * Calculate value in minutes and seconds and return it as String
     */
    private func getMinutesAndSeconds(remainingSeconds: Int) -> (String) {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds - minutes * 60
        let secondString = seconds < 10 ? "0" + seconds.description : seconds.description
        return minutes.description + ":" + secondString
    }
    
    // MARK: Private methods
    @objc private func timerFired(_ timer: Timer) {
        elapsedTime += fireInterval
        
        if elapsedTime < totalTime {
            setNeedsDisplay()
            
            let computedCounterValue = beginingValue - Int(elapsedTime / interval)
            if computedCounterValue != currentCounterValue {
                currentCounterValue = computedCounterValue
            }
        } else {
            end()
        }
    }
}
