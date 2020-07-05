//
//  CategoryTableViewController.swift
//  To-Do-Reminder
//
//  Created by Kritima Kukreja on 2020-06-26.
//  Copyright © 2020 Kritima Kukreja. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class CategoryTableViewController: UIViewController {
    
  var categoryContext: NSManagedObjectContext!
    
      var notification = [Todo]()
      var categoryName = UITextField()
    
      var categories: [Categories] = [Categories]()
      
   
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
      {
          super.viewDidLoad()
          
          getCoreData()
          setUpTableView()
          firstTimeSetup()
          setUpNotifications()
          tableView.tableFooterView = UIView()
      }

    
    @IBAction func addCategory(_ sender: Any) {
        
        let alert = UIAlertController(title: "Category Name", message: "", preferredStyle: .alert)
               alert.addTextField(configurationHandler: addCategoryName(textField:))
               alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
                   if(self.categoryName.text!.count < 1)
                   {
                       self.emptyFieldAlert()
                       return
                   }
                   else
                   {
                       self.addNewCategory()
                   }
               }))
               alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
               self.present(alert, animated: true, completion: nil)
    }
    
    
      func emptyFieldAlert()
      {
          let alert = UIAlertController(title: "Error!", message: "Name can't be empty", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
          self.present(alert, animated: true, completion: nil)
          
      }
      
      func addCategoryName(textField: UITextField)
      {
          self.categoryName = textField
          self.categoryName.placeholder = "Enter Category Name"
      }

  }

  extension CategoryTableViewController
  {
      
      func getCoreData() {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          categoryContext = appDelegate.persistentContainer.viewContext
          fetchCategoryData()
          
      }
      
      func firstTimeSetup() {
          let categoryNames = self.categories.map {$0.category}
          guard !categoryNames.contains("Archived") else {return}
          let newCategory = Categories(context: self.categoryContext)
          newCategory.category = "Archived"
          self.categories.append(newCategory)
          do
          {
              try categoryContext.save()
              tableView.reloadData()
          }
          catch
          {
              print("Error saving categories \(error.localizedDescription)")
          }
      }
      
      //Function to get category data and display them in a table
      func fetchCategoryData()
      {
          let request: NSFetchRequest<Categories> = Categories.fetchRequest()
          let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
          request.sortDescriptors = [sortDescriptor]
          do {
              categories = try categoryContext.fetch(request)
          } catch {
              print("Error loading categories: \(error.localizedDescription)")
          }
          tableView.reloadData()
      }
      
      //Function to add new category to category list
      func addNewCategory()
      {
          let categoryNames = self.categories.map {$0.category}
          guard !categoryNames.contains(categoryName.text) else {self.showAlert(); return}
          let newCategory = Categories(context: self.categoryContext)
          newCategory.category = categoryName.text!
          self.categories.append(newCategory)
          do {
              try categoryContext.save()
              tableView.reloadData()
          } catch {
              print("Error saving categories \(error.localizedDescription)")
          }
      }
      

      func showAlert()
      {
          let alert = UIAlertController(title: "Category Already Exists!", message: "", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
          self.present(alert, animated: true, completion: nil)
      }
      
      
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          let destination = segue.destination as! ListTableViewController
          if let indexPath = tableView.indexPathForSelectedRow {
              destination.selectedCategory = categories[indexPath.row]
          }
      }
      
  }

  extension CategoryTableViewController: UITableViewDelegate, UITableViewDataSource {
      

      func setUpTableView()
      {
          tableView.delegate = self
          tableView.dataSource = self
          tableView.estimatedRowHeight = 44
          tableView.rowHeight = UITableView.automaticDimension
      }
          
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
      {
          return categories.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
          let category = categories[indexPath.row]
          if category.category == "Archived"
          {
              cell.backgroundColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
              cell.textLabel?.textColor = UIColor.blue
              //cell.textLabel?.textAlignment = .center
          }
          cell.textLabel?.text = category.category
          return cell
      }
    
    
      func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                  self.categoryContext.delete(self.categories[indexPath.row])
                  self.categories.remove(at: indexPath.row)
                  do {
                      try self.categoryContext.save()
                  } catch {
                      print("Error saving the context \(error.localizedDescription)")
                  }
                  self.tableView.reloadData()
                  completion(true)
          }
          
          delete.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
          delete.image = UIImage(systemName: "trash.fill")
          return UISwipeActionsConfiguration(actions: [delete])
      }
      
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          performSegue(withIdentifier: "listScreen", sender: self)
      }
  }
    
    extension CategoryTableViewController {
        
    //    Notification
        func setUpNotifications() {
            
            checkDueTasks()
            if notification.count > 0 {
                for task in notification {
                    
                    if let name = task.title {
                        let notificationCenter = UNUserNotificationCenter.current()
                        let notificationContent = UNMutableNotificationContent()
                        
                        notificationContent.title = "Task Reminder"
                        notificationContent.body = "Just a friendly reminder that \(name) is due tommorow"
                        notificationContent.sound = .default
    //                    sets up notification for a day before the task
                        let fromDate = Calendar.current.date(byAdding: .day, value: -1, to: task.due_date!)!
                        let components = Calendar.current.dateComponents([.month, .day, .year], from: fromDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        let request = UNNotificationRequest(identifier: "\(name)taskid", content: notificationContent, trigger: trigger)
                        notificationCenter.add(request) { (error) in
                            if error != nil {
                                print(error ?? "notification center error")
                            }
                        }
                    }
                }
            }
            
        }

func checkDueTasks() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        do {
            let notifications = try context.fetch(request)
            for task in notifications {
                if Calendar.current.isDateInTomorrow(task.due_date!) {
                    notification.append(task)
                }
            }
        } catch {
            print("Error loading todos \(error.localizedDescription)")
        }
        
    }
    
}








