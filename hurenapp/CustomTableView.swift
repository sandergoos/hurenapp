//
//  CustomTableView.swift
//  hurenapp
//
//  Created by Sander Goos on 02-12-15.
//  Copyright © 2015 Sander Goos. All rights reserved.
//
import UIKit;
import Foundation

class CustomTableView : UITableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
}