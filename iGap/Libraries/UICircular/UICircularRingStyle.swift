/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit.UIColor

// MARK: UICircularRingStyle

/**
 
 # UICircularRingStyle
 
 This is an enumeration which is used to determine the style of the progress ring.
 
 ## Author
 Luis Padron
 
 */
public enum UICircularRingStyle {
    /// inner ring is inside the circle
    case inside

    /// inner ring is placed ontop of the outer ring
    case ontop

    /// outer ring is dashed, the pattern list is how the dashes should appear
    case dashed(pattern: [CGFloat])

    /// outer ring is dotted
    case dotted

    /// inner ring is placed ontop of the outer ring and outer ring has border
    case bordered(width: CGFloat, color: UIColor)
}

public struct UICircularRingValueKnobStyle {

    /// default implmementation of the knob style
    public static let `default` = UICircularRingValueKnobStyle(size: 15.0, color: .clear)

    /// the size of the knob
    public let size: CGFloat

    /// the color of the knob
    public let color: UIColor

    /// the amount of blur to give the shadow
    public let shadowBlur: CGFloat

    /// the offset to give the shadow
    public let shadowOffset: CGSize

    /// the color for the shadow
    public let shadowColor: UIColor

    /// creates a new `UICircularRingValueKnobStyle`
    public init(size: CGFloat,
                color: UIColor,
                shadowBlur: CGFloat = 2.0,
                shadowOffset: CGSize = .zero,
                shadowColor: UIColor = UIColor.black.withAlphaComponent(0.8)) {
        self.size = size
        self.color = color
        self.shadowBlur = shadowBlur
        self.shadowOffset = shadowOffset
        self.shadowColor = shadowColor
    }
}

// MARK: UICircularRingGradientPosition

/**

 UICircularRingGradientPosition

 This is an enumeration which is used to determine the position for a
 gradient. Used inside the `UICircularRingLayer` to allow customization
 for the gradient.
 */
public enum UICircularRingGradientPosition {
    /// Gradient positioned at the top
    case top
    /// Gradient positioned at the bottom
    case bottom
    /// Gradient positioned to the left
    case left
    /// Gradient positioned to the right
    case right
    /// Gradient positioned in the top left corner
    case topLeft
    /// Gradient positioned in the top right corner
    case topRight
    /// Gradient positioned in the bottom left corner
    case bottomLeft
    /// Gradient positioned in the bottom right corner
    case bottomRight

    /**
     Returns a `CGPoint` in the coordinates space of the passed in `CGRect`
     for the specified position of the gradient.
     */
    func pointForPosition(in rect: CGRect) -> CGPoint {
        switch self {
        case .top:
            return CGPoint(x: rect.midX, y: rect.minY)
        case .bottom:
            return CGPoint(x: rect.midX, y: rect.maxY)
        case .left:
            return CGPoint(x: rect.minX, y: rect.midY)
        case .right:
            return CGPoint(x: rect.maxX, y: rect.midY)
        case .topLeft:
            return CGPoint(x: rect.minX, y: rect.minY)
        case .topRight:
            return CGPoint(x: rect.maxX, y: rect.minY)
        case .bottomLeft:
            return CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomRight:
            return CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }
}

// MARK: UICircularRingGradientOptions

/**
 UICircularRingGradientOptions

 Struct for defining the options for the UICircularRingStyle.gradient case.

 ## Important ##
 Make sure the number of `colors` is equal to the number of `colorLocations`
 */
public struct UICircularRingGradientOptions {

    /// a default styling option for the gradient style
    public static let `default` = UICircularRingGradientOptions(startPosition: .topRight,
                                                            endPosition: .bottomLeft,
                                                            colors: [.red, .blue],
                                                            colorLocations: [0, 1])

    /// the start location for the gradient
    public let startPosition: UICircularRingGradientPosition

    /// the end location for the gradient
    public let endPosition: UICircularRingGradientPosition

    /// the colors to use in the gradient, the count of this list must match the count of `colorLocations`
    public let colors: [UIColor]

    /// the locations of where to place the colors, valid numbers are from 0.0 - 1.0
    public let colorLocations: [CGFloat]

    /// create a new UICircularRingGradientOptions
    public init(startPosition: UICircularRingGradientPosition,
                endPosition: UICircularRingGradientPosition,
                colors: [UIColor],
                colorLocations: [CGFloat]) {
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.colors = colors
        self.colorLocations = colorLocations
    }
}
