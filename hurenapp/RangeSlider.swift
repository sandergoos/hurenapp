//
//  RangeSlider.swift
//  hurenapp
//
//  Created by Sander Goos on 18-01-16.
//  Copyright © 2016 Sander Goos. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSlider: UIControl {
    var minimumValue = 0.0
    var maximumValue = 100.0
    var lowerValue = 20.0
    var upperValue = 80.0
    
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    
    var previousLocation = CGPoint()
    
    var trackTintColor = UIColor(white: 0.9, alpha: 1.0)
    var trackHighlightTintColor = UIColor.greenColor()
    var thumbTintColor = UIColor.whiteColor()
    
    var curvaceousness : CGFloat = 1.0
    
    
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        previousLocation = location
        
            // 2. Update the values
            if lowerThumbLayer.highlighted {
                lowerValue += deltaValue
                lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            } else if upperThumbLayer.highlighted {
                upperValue += deltaValue
                upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
            }
        
        // 3. Update the UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        sendActionsForControlEvents(.ValueChanged)
        return true
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        if upperValue == minimumValue
        {
            if upperThumbLayer.frame.contains(previousLocation) {
                upperThumbLayer.highlighted = true
            } else if lowerThumbLayer.frame.contains(previousLocation) {
                lowerThumbLayer.highlighted = true
            }
        } else {
            if lowerThumbLayer.frame.contains(previousLocation) {
                lowerThumbLayer.highlighted = true
            } else if upperThumbLayer.frame.contains(previousLocation) {
                upperThumbLayer.highlighted = true
            }
        }
        
        // Hit test the thumb layers
        
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    convenience init(frame: CGRect, minVal: Double, maxVal: Double) {
        self.init(frame: frame)
        self.minimumValue = minVal
        self.maximumValue = maxVal
        self.upperValue = (maxVal / 100) * 80
        self.lowerValue = (maxVal / 100) * 20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(upperThumbLayer)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func updateLayerFrames() {
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0,
            width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 0.0,
            width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
}