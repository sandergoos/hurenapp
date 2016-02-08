//
//  FirstViewController.swift
//  hurenapp
//
//  Created by Sander Goos on 27-11-15.
//  Copyright © 2015 Sander Goos. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import CoreData

class WoningenViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var selectedWoning : Woning?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var navTitle: UINavigationItem!
    
    var location : CLLocationCoordinate2D?
    var locationManager : CLLocationManager = CLLocationManager()
    var placesClient : GMSPlacesClient?
    var mapView : GMSMapView?
    
    var advancedSearchView : AdvancedSearchView?
    
    let rangeSlider = RangeSlider(frame: CGRectZero, minVal: 0.0, maxVal: 3000.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillAppear(animated: Bool) {
        //eerst plaats verkrijgen, daarna woningen ophalen
        if(Globals.locationLock) {
            self.updatePlace(Globals.filter.location)
        } else {
            self.getPlaats()
        }
        self.tableView.reloadData()
    }
    
    @IBAction func segmentedControlChange(sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 1) {
            self.mapView = GMSMapView()
            Globals.showMap(view: self.tableView, mapView: &self.mapView!, delegate: self, locationInput: self.locationManager.location)
        } else {
            if let mView = mapView {
                mView.removeFromSuperview()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = manager.location!.coordinate
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        if let id = marker.userData as! Int? {
            for woning in Globals.woningen {
                if(woning.id == id) {
                    selectedWoning = woning
                    self.performSegueWithIdentifier("CustomSegue", sender: self)
                }
            }
        }
    }
    
    @IBAction func fitlersPressed(sender: AnyObject) {
        self.advancedSearchView = NSBundle.mainBundle().loadNibNamed("AdvancedSearch", owner: self, options: nil)[0] as? AdvancedSearchView
        self.advancedSearchView!.frame = self.view.bounds
        self.advancedSearchView!.addSubview(rangeSlider)
        
        
        self.advancedSearchView!.searchButton.addTarget(self, action: "advancedSearchPressed:", forControlEvents: .TouchUpInside)
        
        self.advancedSearchView!.saveButton.addTarget(self, action: "saveSearchPressed:", forControlEvents: .TouchUpInside)
        
        self.advancedSearchView!.locationButton.addTarget(self, action: "locationButtonPressedAdv:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(advancedSearchView!)
    }
    
    func locationButtonPressedAdv(button: UIButton) {
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
            
            adv.removeFromSuperview()
            //eerst plaats verkrijgen, daarna woningen ophalen
            if(Globals.locationLock) {
                self.updatePlace(Globals.filter.location)
            } else {
                self.getPlaats()
            }
            self.tableView.reloadData()
            
        }
    }
    
    func getPlaats() -> Void {
        if(CLLocationManager.locationServicesEnabled()) {
            let geoCoder = CLGeocoder()
            if let loc = locationManager.location {
                geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemark, error) -> Void in
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    if placemark!.count > 0 {
                        let pm = placemark![0] as CLPlacemark
                        self.updatePlace(pm.locality)
                        if(pm.locality == "Bloemendaal" || pm.locality == "Overveen") { self.updatePlace("Haarlem") }
                    } else {
                        print("Error with data")
                    }
                })
            }
            
        }
    }
    
    func updatePlace(locality: String?) {
        if let loc = locality {
            Globals.filter.location = loc
            navTitle.title = loc
        } else {
            navTitle.title = "Huurwoningen"
        }
        
        HurenAPI.getWoningenWithPlaceAsync(place: Globals.filter.location, table: tableView, controller: self)
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Globals.woningen.count == 0 {
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            emptyLabel.text = !Globals.loading ? "Geen woningen gevonden met de huidige filters" : "Aan het laden.."
            //emptyLabel.backgroundColor = UIColor.purpleColor()
            emptyLabel.numberOfLines = 2
            emptyLabel.textColor = UIColor.blackColor()
            emptyLabel.textAlignment = .Center
            
            self.tableView.backgroundView = emptyLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return Globals.woningen.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "WoningTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! WoningTableViewCell
        cell.streetName?.text = Globals.woningen[indexPath.row].straatnaam + " " + Globals.woningen[indexPath.row].huisnummer
        cell.cityName?.text = Globals.woningen[indexPath.row].plaats
        cell.price?.text = "€\(Int(Globals.woningen[indexPath.row].prijs)) p/m inc."
        
        cell.favoriteButton.woningIndex = indexPath.row
        let image = (Globals.woningen[indexPath.row].like) ? UIImage(named: "Like Filled-25.png") : UIImage(named: "Like-25.png")
        cell.favoriteButton.setImage(image, forState: .Normal)
        cell.favoriteButton.addTarget(self, action: "favorite:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let imgURL = Globals.woningen[indexPath.row].thumbnail
        if(cell.imageURL == nil ||  imgURL != cell.imageURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                cell.imageURL = imgURL
                let img = self.getImage(imgURL)
                dispatch_async(dispatch_get_main_queue(), {
                    //bouw het imageveld
                    var frame = cell.bounds
                    frame.origin.x = -115.0
                    frame.origin.y = 0.0
                    
                    let imgView = UIImageView(image: img)
                    imgView.contentMode = .ScaleAspectFit
                    imgView.frame = frame
                    cell.addSubview(imgView)
                    
                    //herlaad de cell na het ophalen van de image
                    self.tableView.reloadData()
                });
            });
        }
        return cell;
    }
    
    func favorite(sender: LikeButton!) {
        
        if(Globals.woningen.count > 0) {
            let woning = Globals.woningen[sender.woningIndex!]
            if (woning.like) {
                self.deleteFavorite(woning)
            } else {
                self.saveFavorite(woning)
            }
            
            Globals.woningen[sender.woningIndex!].like = woning.like ? false : true
        }
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! DetailViewController
        dest.woning = selectedWoning;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedWoning = Globals.woningen[indexPath.row]
        self.performSegueWithIdentifier("CustomSegue", sender: self)
    }
    
    func deleteFavorite(woning: Woning) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //bereid het verzoek voor
        let request = NSFetchRequest(entityName: "Woning")
        request.returnsObjectsAsFaults = false
        
        //4
        do {
            let results = try managedContext.executeFetchRequest(request)
            if results.count > 0 {
                
                //zoek de desbetreffende woning en verwijder uit coredata
                for result : NSManagedObject in results as! [NSManagedObject] {
                    let id = result.valueForKey("id") as! Int
                    if( id == woning.id ) {
                        managedContext.deleteObject(result)
                        try managedContext.save()
                    }
                }
            }
        } catch let error as NSError  {
            print("Could not delete \(error), \(error.userInfo)")
        }

    }
    
    func saveFavorite(woning: Woning) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Woning",
            inManagedObjectContext:managedContext)
        
        let woningObject = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3
        woningObject.setValue(woning.id, forKey: "id")
        
        //4
        do {
            try managedContext.save()
            //5
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getImage(image: String) -> UIImage {
        if let dataURL = NSURL(string:image) {
            if let data = NSData(contentsOfURL: dataURL) {
                return UIImage(data: data)!
            }
        }
        return UIImage();
    }
    
    func getFavorites() -> [NSManagedObject] {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //haal woningen op uit core data
        var dataWoningen : [NSManagedObject] = []
        
        do {
            let request = NSFetchRequest(entityName: "Woning")
            request.returnsObjectsAsFaults = false
            let results = try managedContext.executeFetchRequest(request)
            if results.count > 0 {
                dataWoningen = results as! [NSManagedObject]
            }
        }catch(let error as NSError){
            NSLog(error.localizedDescription)
        }
        
        return dataWoningen
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

