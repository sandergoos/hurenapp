//
//  FilterViewController.swift
//  hurenapp
//
//  Created by Sander Goos on 19-01-16.
//  Copyright © 2016 Sander Goos. All rights reserved.
//

import UIKit
import CoreData

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var filters: [NSManagedObject] = [NSManagedObject]()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getFilters()
    }
    
    func getFilters() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext
        
        do {
            let request = NSFetchRequest(entityName: "Filter")
            request.returnsObjectsAsFaults = false
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                filters = results as! [NSManagedObject]
            } else {
                
            }
            self.tableView.reloadData()
        }catch(let error as NSError){
            NSLog(error.localizedDescription)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let flt = filters[indexPath.row]
        
        let cellIdentifier = "FilterCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FilterCell
        
        cell.priceLabel.text = "Prijs van \(flt.valueForKey("minPrice") as! Int) tot \(flt.valueForKey("maxPrice") as! Int)"
        
        if let opp = flt.valueForKey("oppervlakte") as? Int {
            cell.oppLabel.text = "> \(opp)m2"
        } else {
            cell.oppLabel.text = "Alle oppervlaktes"
        }
        
        if let place = flt.valueForKey("place") as? String {
            cell.placeLabel.text = place
        } else {
            cell.placeLabel.text = "Alle plaatsen"
        }
    
        let date = flt.valueForKey("dateAdded") as! NSDate
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = dateFormatter.stringFromDate(date)
        cell.dateLabel.text = dateString
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filters.count == 0 {
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            emptyLabel.text = "Geen filters gevonden"
            //emptyLabel.backgroundColor = UIColor.purpleColor()
            emptyLabel.numberOfLines = 2
            emptyLabel.textColor = UIColor.blackColor()
            emptyLabel.textAlignment = .Center
            
            self.tableView.backgroundView = emptyLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return filters.count
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
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context = appDelegate.managedObjectContext
        
        context.deleteObject(filters[indexPath.row])
        filters.removeAtIndex(indexPath.row)
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let flt = filters[indexPath.row]
        Globals.filter.minPrijs = flt.valueForKey("minPrice") as? Int
        Globals.filter.maxPrijs = flt.valueForKey("maxPrice") as? Int
        Globals.filter.location = flt.valueForKey("place") as? String
        Globals.filter.minKamers = flt.valueForKey("rooms") as? Int
        Globals.filter.minOppervlakte = flt.valueForKey("oppervlakte") as? Int
        
        Globals.locationLock = true
        self.tabBarController?.selectedIndex = 0
        
    }
    
    
}
