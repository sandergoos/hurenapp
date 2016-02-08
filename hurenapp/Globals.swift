//
//  Globals.swift
//  hurenapp
//
//  Created by Sander Goos on 05-12-15.
//  Copyright © 2015 Sander Goos. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import GoogleMaps

struct Globals {
    static var location : String?
    static var woningen : [Woning] = [Woning]()
    static var favorieten : [Woning] = [Woning]()
    static var locationLock : Bool = false
    static var filter : Filter = Filter()
    static var loading : Bool = false
    
    static func showAlert(title: String, message: String, target: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
        alert.addAction(alertAction)
        target.presentViewController(alert, animated: true) { () -> Void in }
    }
    
    static func showMap(view presentView: UIView, inout mapView: GMSMapView, delegate: GMSMapViewDelegate, locationInput: CLLocation?) {
        var camera : GMSCameraPosition
        if let loc : CLLocation = locationInput {
            camera = GMSCameraPosition.cameraWithLatitude(loc.coordinate.latitude,
                longitude: loc.coordinate.longitude, zoom: 10)
        } else {
            let loc = CLLocationCoordinate2D(latitude: 52.3417755, longitude: 4.731369)
            camera = GMSCameraPosition.cameraWithLatitude(loc.latitude,
                longitude: loc.longitude, zoom: 10)
        }
        let frame = presentView.bounds
        
        mapView = GMSMapView.mapWithFrame(frame, camera: camera)
        mapView.delegate = delegate
        mapView.myLocationEnabled = true
        mapView.settings.scrollGestures = true
        presentView.addSubview(mapView)
        
        for woning in Globals.woningen {
            let marker = GMSMarker()
            marker.icon = UIImage(named: "house")
            marker.position = CLLocationCoordinate2DMake(woning.coordLat, woning.coordLong)
            marker.title = (woning.straatnaam) + " " + (woning.huisnummer)
            marker.snippet = woning.omschrijving
            marker.map = mapView
            marker.userData = woning.id
        }
    }
}

class Filter {
    
    var minPrijs : Int?
    var maxPrijs : Int?
    var minOppervlakte : Int?
    var minKamers : Int?
    var location : String?
    
}

