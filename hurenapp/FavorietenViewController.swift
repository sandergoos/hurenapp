//
//  SecondViewController.swift
//  hurenapp
//
//  Created by Sander Goos on 27-11-15.
//  Copyright © 2015 Sander Goos. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import Alamofire

class FavorietenViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //var woningen = [Woning]();
    var selectedWoning : Woning?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var navTitle: UINavigationItem!
    
    var location : CLLocationCoordinate2D?
    var locationManager : CLLocationManager = CLLocationManager()
    var placesClient : GMSPlacesClient?
    var mapView : GMSMapView?
    
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup context for core data use
        context = appDel.managedObjectContext
        
        //enable location
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        
        HurenAPI.getFavoritesFromAPI(table: self.tableView)
    }
    
    @IBAction func segmentedControlChange(sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 1) {
            //self.showMap()
            self.mapView = GMSMapView()
            Globals.showMap(view: self.tableView, mapView: &self.mapView!, delegate: self, locationInput: locationManager.location)
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
            for woning in Globals.favorieten {
                if(woning.id == id) {
                    selectedWoning = woning
                    self.performSegueWithIdentifier("CustomSeque", sender: self)
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Globals.favorieten.count == 0 {
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            emptyLabel.text = !Globals.loading ? "Geen favorieten gevonden" : "Aan het laden.."
            //emptyLabel.backgroundColor = UIColor.purpleColor()
            emptyLabel.numberOfLines = 2
            emptyLabel.textColor = UIColor.blackColor()
            emptyLabel.textAlignment = .Center
            
            self.tableView.backgroundView = emptyLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return Globals.favorieten.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //haal woningen op uit core data
        var dataWoningen : [NSManagedObject] = []
        
        do {
            let request = NSFetchRequest(entityName: "Woning")
            request.returnsObjectsAsFaults = false
            let results = try context!.executeFetchRequest(request)
            if results.count > 0 {
                dataWoningen = results as! [NSManagedObject]
            }
        }catch(let error as NSError){
            NSLog(error.localizedDescription)
        }
        
        let woningenId = Globals.favorieten[indexPath.row].id
        //zoek de bijbehorende woning en verwijder deze uit zowel woningen als de core data
        for i in dataWoningen {
            let id = i.valueForKey("id") as! Int
            if(id == woningenId) {
                context?.deleteObject(i)
                var counter = 0
                for woning in Globals.woningen {
                    if(woning.id == id) {
                        Globals.woningen[counter].like = false
                    }
                    counter++
                }
            }
        }

        do {
            Globals.favorieten.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            try context?.save()
        } catch (let error as NSError) {
            print("\(error.localizedDescription)")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoriteTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! WoningTableViewCell
        cell.streetName?.text = Globals.favorieten[indexPath.row].straatnaam + " " + Globals.favorieten[indexPath.row].huisnummer
        cell.cityName?.text = Globals.favorieten[indexPath.row].plaats
        cell.price?.text = "€\(Int(Globals.favorieten[indexPath.row].prijs)) p/m inc."
        
        let imgURL = Globals.favorieten[indexPath.row].thumbnail
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! DetailViewController
        dest.woning = selectedWoning;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedWoning = Globals.favorieten[indexPath.row]
        self.performSegueWithIdentifier("CustomSeque", sender: self)
    }
    
    func getImage(image: String) -> UIImage {
        if let dataURL = NSURL(string:image) {
            if let data = NSData(contentsOfURL: dataURL) {
                return UIImage(data: data)!
            }
        }
        return UIImage();
    }
    
    
}

