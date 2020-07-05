//
//  MoveToFolderViewController.swift
//  To-Do-Reminder
//
//  Created by Kritima Kukreja on 2020-06-29.
//  Copyright © 2020 Kritima Kukreja. All rights reserved.
//

import UIKit
import CoreData


class MoveToFolderViewController: UIViewController {
    
    var categories = [Categories]()
    var selectedNote: [Todo]? {
        didSet {
            loadCategories()
        }
    }
  
    @IBOutlet weak var tableView: UITableView!
    
    let moveTodoContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}




extension MoveToFolderViewController {
    
    func loadCategories() {
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        let categoryPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedNote?[0].parentFolder?.category ?? "")
        request.predicate = categoryPredicate
        
        do {
            categories = try moveTodoContext.fetch(request)
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
    }

}


extension MoveToFolderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = categories[indexPath.row].category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            for todo in self.selectedNote! {
                todo.parentFolder = self.categories[indexPath.row]
            }
            self.performSegue(withIdentifier: "goBackToTaskList", sender: self)
        
    }
}

