//
//  HurenAPI.swift
//  hurenapp
//
//  Created by Sander Goos on 07-02-16.
//  Copyright © 2016 Sander Goos. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

struct HurenAPI {
    static let apiURL = "https://test-huur.azurewebsites.net/api/"
    
    static func getWoningenWithPlaceAsync( place placeParam : String?, table : UITableView, controller: UIViewController) {
        if var place = placeParam {
            
            Globals.loading = true
            
            place = place.lowercaseString
            place = place.capitalizedString
        
            var url = apiURL + "woning"
            
            var filters : Bool = false;
            
            if((Globals.filter.location) != nil) {
                url += "?Plaats=" + (place)
                filters = true
            }
            
            if let minPrijs = Globals.filter.minPrijs {
                url += !filters ? "?" : "&"
                url += "MinPrijs=\(minPrijs)"
                filters = true
            }
            
            if let maxPrijs = Globals.filter.maxPrijs {
                url += !filters ? "?" : "&"
                url += "MaxPrijs=\(maxPrijs)"
                filters = true
            }
            
            if let minOpp = Globals.filter.minOppervlakte {
                url += !filters ? "?" : "&"
                url += "MinOpp=\(minOpp)"
                filters = true
            }
            
            if let minRooms = Globals.filter.minKamers {
                url += !filters ? "?" : "&"
                url += "MinKamers=\(minRooms)"
                filters = true
            }
            
            let favorites : [NSManagedObject] = getFavorites()
            
            Alamofire.request(.GET, url, parameters: nil)
                .responseJSON { response in
                    Globals.woningen = []
                    
                    if response.result.isFailure {
                        //TODO: Internet Error
                        Globals.showAlert("Fout bij het ophalen", message: "Kon huizen niet ophalen. Check je internetconnectie.", target: controller)
                        Globals.loading = false
                        table.reloadData()
                        return
                    }
                    
                    if let val = response.result.value {
                        let readableJSON = JSON(val)
                        let count = readableJSON["Woningen"].count
                        
                        if(count > 0)  {
                            for i in 0...readableJSON["Woningen"].count - 1 {
                                var woning = Woning(json: readableJSON["Woningen"][i])
                                
                                //loop door favorieten om te kijken of deze woning er in zit
                                for favorite : NSManagedObject in favorites {
                                    if(woning.id == favorite.valueForKey("id") as! Int) {
                                        woning.like = true
                                    }
                                }
                                
                                Globals.woningen.append(woning);
                            }
                        }
                        table.reloadData()
                        Globals.loading = false
                    }
            }
        }
    }
    
    static func getFavorites() -> [NSManagedObject] {
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
    
    static func getFavoritesFromAPI(table table: UITableView) {
        let results = getFavorites()
        Globals.loading = true
        //verkrijg array met favorietenIDS
        var favorieten : [Int] = []
        for result : NSManagedObject in results {
            favorieten.append(result.valueForKey("id") as! Int)
        }
        
        //maak de url
        var url = "https://test-huur.azurewebsites.net/api/woning"
        
        var count = 0;
        for id in favorieten {
            url += (count == 0) ? "?" : "&"
            url += "FavorietId=" + "\(id)"
            count++
        }
        
        Alamofire.request(.GET, url).responseJSON { response in
            Globals.favorieten = []
            Globals.loading = false
            if response.result.isFailure {
                table.reloadData()
                return
            }
            let readableJSON = JSON(response.result.value!)
            let count = readableJSON["Woningen"].count
            
            if(count > 0)  {
                for i in 0...readableJSON["Woningen"].count - 1 {
                    let woning = Woning(json: readableJSON["Woningen"][i])
                    Globals.favorieten.append(woning);
                }
                table.reloadData();
            }
        }

    }
    
}
