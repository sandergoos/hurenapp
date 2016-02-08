//
//  RangeSliderViewController.swift
//  hurenapp
//
//  Created by Sander Goos on 17-01-16.
//  Copyright © 2016 Sander Goos. All rights reserved.
//

import UIKit

class RangeSliderViewController : UIViewController {
    
    let rangeSlider = RangeSlider(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rangeSlider.backgroundColor = UIColor.redColor()
        view.addSubview(rangeSlider)
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider.frame = CGRect(x: margin, y: margin + topLayoutGuide.length,
            width: width, height: 31.0)
        rangeSlider.addTarget(self, action: "rangeSliderValueChanged:", forControlEvents: .ValueChanged)
    }
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) \(rangeSlider.upperValue))")
    }
    
    
}
