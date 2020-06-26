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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadFolder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Data manipulation methods
    
    func loadFolder() {
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    func saveFolders() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving folders \(error.localizedDescription)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].category
     //   cell.textLabel?.textColor = .lightGray
     //   cell.detailTextLabel?.textColor = .lightGray
        //  cell.detailTextLabel?.text = "\(categories[indexPath.row].notes?.count ?? 0)"
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK: - add category method
    @IBAction func addFolder(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New CategoryS", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let folderNames = self.categories.map {$0.category}
            guard !folderNames.contains(textField.text) else {self.showAlert(); return}
            let newFolder = Categories(context: self.context)
            newFolder.category = textField.text!
            self.categories.append(newFolder)
            self.saveFolders()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // change the font color of cancel action
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Folder Name"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Name Taken", message: "Please choose another name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        okAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ListTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedFolder = categories[indexPath.row]
        }
        
    }*/
}







