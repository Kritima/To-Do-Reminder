//
//  CategoryTableViewController.swift
//  To-Do-Reminder
//
//  Created by Kritima Kukreja on 2020-06-26.
//  Copyright © 2020 Kritima Kukreja. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    // create a folder array to populate the table
    var categories = [Categories]()
    
// create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
