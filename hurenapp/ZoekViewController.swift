//
//  ZoekViewController.swift
//  hurenapp
//
//  Created by Sander Goos on 31-12-15.
//  Copyright © 2015 Sander Goos. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class ZoekViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var searchField: UITextField!
    var locationManager : CLLocationManager = CLLocationManager()
    
    var advancedSearchView : AdvancedSearchView?
    
    let rangeSlider = RangeSlider(frame: CGRectZero, minVal: 0.0, maxVal: 3000.0)
    
    @IBAction func advancedButtonPressed(sender: AnyObject) {
        self.advancedSearchView = NSBundle.mainBundle().loadNibNamed("AdvancedSearch", owner: self, options: nil)[0] as? AdvancedSearchView
        self.advancedSearchView!.frame = self.view.bounds
        self.advancedSearchView!.addSubview(rangeSlider)
        
        self.advancedSearchView!.searchButton.addTarget(self, action: "advancedSearchPressed:", forControlEvents: .TouchUpInside)
        
        self.advancedSearchView!.saveButton.addTarget(self, action: "saveSearchPressed:", forControlEvents: .TouchUpInside)
        
        self.advancedSearchView!.locationButton.addTarget(self, action: "locationButtonPressedAdv:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(advancedSearchView!)
    }
    
    func locationButtonPressedAdv(button: UIButton) {
        updateLocation()
        self.advancedSearchView!.placeField.text = Globals.filter.location
    }
    
    func saveSearchPressed(button: UIButton) {
        
        if let adv = self.advancedSearchView {
            //1
            let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let entity =  NSEntityDescription.entityForName("Filter",
                inManagedObjectContext:managedContext)
            
            let filterObject = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedContext)
            
            //3
            
            
            let minP = Int(rangeSlider.lowerValue)
            let maxP = Int(rangeSlider.upperValue)
            
            filterObject.setValue(minP, forKey: "minPrice")
            filterObject.setValue(maxP, forKey: "maxPrice")
            
            if let kamers = adv.kamersField.text {
                let minK = Int(kamers)
                filterObject.setValue(minK, forKey: "rooms")
            }
            
            if let opp = adv.opperVlakteField.text {
                let minOpp = Int(opp)
                filterObject.setValue(minOpp, forKey: "oppervlakte")
            }
            
            if let plaats = adv.placeField.text {
                filterObject.setValue(plaats, forKey: "place")
            }
            
            let currentDate = NSDate()
            filterObject.setValue(currentDate, forKey: "dateAdded")
            
            //4
            do {
                try managedContext.save()
                Globals.showAlert("Filter opgeslagen.", message: "Dit filter is nu te vinden bij filters", target: self)
                //5
            } catch _ as NSError  {
                Globals.showAlert("Probleem met het opslaan.", message: "Zorg dat er genoeg ruimte beschikbaar is op het toestel", target: self)
            }
        }
    }
    
    func advancedSearchPressed(button: UIButton) {
        if let adv = advancedSearchView {
            
            Globals.filter.minPrijs = Int(rangeSlider.lowerValue)
            Globals.filter.maxPrijs = Int(rangeSlider.upperValue)
            
            if let kamers = adv.kamersField.text {
                Globals.filter.minKamers = Int(kamers)
            } else {
                Globals.filter.minKamers = nil
            }
            
            if let opp = adv.opperVlakteField.text {
                Globals.filter.minOppervlakte = Int(opp)
            } else {
                Globals.filter.minOppervlakte = nil
            }
            
            if let plaats = adv.placeField.text {
                Globals.filter.location = plaats
            } else {
                Globals.filter.location = nil
            }
            
            Globals.locationLock = true
            
            self.tabBarController?.selectedIndex = 0
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let adv = self.advancedSearchView {
            let frame = adv.rangeSliderView.frame
            
            let width = adv.rangeSliderView.frame.width
            rangeSlider.frame = CGRect(x: frame.origin.x, y: 62.0 + frame.origin.y,
                width: width, height: 31.0)
            rangeSlider.addTarget(self, action: "rangeSliderValueChanged:", forControlEvents: .ValueChanged)
            self.rangeSliderValueChanged(self.rangeSlider)
        }
    }
    
    func rangeSliderValueChanged(rs : RangeSlider) {
        self.advancedSearchView!.updateLabels("Prijs van €\(Int(rs.lowerValue))", maxText: "Prijs tot €\(Int(rs.upperValue))")
    }
    
    override func viewDidLoad() {
        //enable location
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //enable the close of the keyboard
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "closeKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //eigen code
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        if let city = searchField.text {
            Globals.filter.location = city
            Globals.locationLock = true
            transitionToWoningen()
        } else {
            //geef aan dat de stad ingevuld moet worden.
            Globals.showAlert("Geen locatie ingevuld", message: "Vul een locatie in.", target: self)
        }
    }
    
    func transitionToWoningen() {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func locationButtonPressed(sender: AnyObject) {
        updateLocation()
        searchField.text = Globals.filter.location
    }
    
    func updateLocation() {
        if let loc = locationManager.location {
            if(CLLocationManager.locationServicesEnabled()) {
                let geoCoder = CLGeocoder()
                geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemark, error) -> Void in
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    if placemark!.count > 0 {
                        let pm = placemark![0] as CLPlacemark
                        Globals.location = pm.locality
                    } else {
                        print("Error with data")
                    }
                })
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}
