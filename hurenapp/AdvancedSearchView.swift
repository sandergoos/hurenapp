//
//  AdvancedSearchView.swift
//  hurenapp
//
//  Created by Sander Goos on 18-01-16.
//  Copyright © 2016 Sander Goos. All rights reserved.
//

import UIKit
import CoreData

class AdvancedSearchView: UIView {

    @IBOutlet var rangeSliderView: UIView!
    @IBOutlet var minLabel: UILabel!
    @IBOutlet var maxLabel: UILabel!
    
    @IBOutlet var opperVlakteField: UITextField!
    @IBOutlet var kamersField: UITextField!
    @IBOutlet var placeField: UITextField!
    
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    func updateLabels(minText: String, maxText: String) {
        minLabel.text = minText
        maxLabel.text = maxText
    }
    
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.removeFromSuperview()
    }
    
    
}
