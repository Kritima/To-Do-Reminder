//
//  ListTableViewController.swift
//  To-Do-Reminder
//
//  Created by Kritima Kukreja on 2020-06-26.
//  Copyright © 2020 Kritima Kukreja. All rights reserved.
//

import UIKit
import CoreData

class ListTableViewController: UIViewController {

    var selectedSort = 0
       var selectedCategory: Categories? {
           didSet {
               loadTodos()
           }
       }
       
       let todoListContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       var tasksArray = [Todo]()
       var selectedTodo: Todo?
       var todoToMove = [Todo]()
       
       let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var dateSort: UIBarButtonItem!
    @IBOutlet weak var titleSort: UIBarButtonItem!
    
       
        @IBOutlet var tableView: UITableView!
       @IBOutlet weak var categoryLabel: UILabel!
       @IBOutlet weak var sortSegment: UISegmentedControl!
       
       override func viewDidLoad() {
           super.viewDidLoad()
           setUpTableView()
           showSearchBar()
           navigationItem.title = selectedCategory!.category
           tableView.tableFooterView = UIView()
       }
       
    @IBAction func addTodo(_ sender: Any) {
        
        performSegue(withIdentifier: "todoViewScreen", sender: self)
    }
    
       
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
           if let destination = segue.destination as? ListDetailViewController
           {
               destination.delegate = self
               if selectedTodo != nil
               {
                   destination.todo = selectedTodo
               }
           }
           
           if let destination = segue.destination as? MoveToFolderViewController
           {
                   destination.selectedNote = todoToMove
           }
       }
       
       @IBAction func unwindToTaskListView(_ unwindSegue: UIStoryboardSegue) {
           saveTodos()
           loadTodos()
           tableView.reloadData()
       }
   }


   extension ListTableViewController {
       
       func loadTodos(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSPredicate? = nil) {
           
          let sortOptions = ["due_date", "title"]
           let todoPredicate = NSPredicate(format: "parentFolder.category=%@", selectedCategory!.category!)
           request.sortDescriptors = [NSSortDescriptor(key: sortOptions[selectedSort], ascending: true)]
           if let addtionalPredicate = predicate {
               request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [todoPredicate, addtionalPredicate])
           } else {
               request.predicate = todoPredicate
           }
           
           do {
               tasksArray = try todoListContext.fetch(request)
           } catch {
               print("Error loading todos \(error.localizedDescription)")
           }
           
       }
    
    
       
       func deleteTodoFromList() {
           
           todoListContext.delete(selectedTodo!)
           tasksArray.removeAll { (Todo) -> Bool in
               Todo == selectedTodo!
           }
           tableView.reloadData()
           
       }
       
       
       func saveTodos()
       {
           do {
               try todoListContext.save()
           } catch {
               print("Error saving the context \(error.localizedDescription)")
           }
       }
       
       func updateTodo() {
           saveTodos()
           tableView.reloadData()
       }
       
    
       func markTodoCompleted() {
           
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           let request: NSFetchRequest<Categories> = Categories.fetchRequest()
           let folderPredicate = NSPredicate(format: "category MATCHES %@", "Archived")
           request.predicate = folderPredicate
           do {
               let category = try context.fetch(request)
               self.selectedTodo?.parentFolder = category.first
               saveTodos()
               tasksArray.removeAll { (Todo) -> Bool in
                   Todo == selectedTodo!
               }
               tableView.reloadData()
           } catch {
               print("Error fetching data \(error.localizedDescription)")
           }
           
       }
       
       func saveTodo(title: String, taskText: String, dueDate: Date)
       {
           let todo = Todo(context: todoListContext)
           todo.title = title
           todo.text = taskText
           todo.due_date = dueDate
           todo.date = Date()
           todo.parentFolder = selectedCategory
           saveTodos()
           tasksArray.append(todo)
           tableView.reloadData()
       }
       
       
       override func viewWillAppear(_ animated: Bool) {
           selectedTodo = nil
       }
       
   }


   extension ListTableViewController: UITableViewDelegate, UITableViewDataSource {
       func setUpTableView() {
           tableView.delegate = self
           tableView.dataSource = self
        
           tableView.estimatedRowHeight = 44
           tableView.rowHeight = UITableView.automaticDimension
       }
       
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return tasksArray.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
           let task = tasksArray[indexPath.row]
           cell.textLabel?.text = task.title
           
       
           if (task.due_date! < Date() && task.parentFolder?.category != "Archived")
           {
               cell.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
           }

           if (task.due_date! > Date() && task.parentFolder?.category != "Archived")
           {
               cell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
           }
           return cell
       }
       
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
               
               self.todoListContext.delete(self.tasksArray[indexPath.row])
               self.tasksArray.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
               completion(true)
           }
           
           delete.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
           delete.image = UIImage(systemName: "trash.fill")
           return UISwipeActionsConfiguration(actions: [delete])
       }
       
       func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let complete = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
               self.selectedTodo = self.tasksArray[indexPath.row]
               self.markTodoCompleted()
           }
           let move = UIContextualAction(style: .normal, title: "Move") { (action, view, completion) in
               self.todoToMove.append(self.tasksArray[indexPath.row])
               self.performSegue(withIdentifier: "moveTodoScreen", sender: nil)
           }
           complete.backgroundColor = #colorLiteral(red: 0.3019607843, green: 0.6784313725, blue: 0.768627451, alpha: 1)
           complete.image = UIImage(systemName: "checkmark.circle")
           move.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
           move.image = UIImage(systemName: "arrowshape.turn.up.right")
           return UISwipeActionsConfiguration(actions: [complete, move])
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           selectedTodo = tasksArray[indexPath.row]
           performSegue(withIdentifier: "todoViewScreen", sender: self)
       }
   }

   extension ListTableViewController: UISearchBarDelegate {
       
       func showSearchBar()
       {
           searchController.obscuresBackgroundDuringPresentation = false
           searchController.searchBar.placeholder = "Search Folder"
           navigationItem.searchController = searchController
           searchController.searchBar.delegate = self
           definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .black
       }
       
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
           
       {
           let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
           loadTodos(predicate: predicate)
           tableView.reloadData()
       }
       
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchBar.text?.count == 0 {
               loadTodos()

               DispatchQueue.main.async {
                   searchBar.resignFirstResponder()
               }

           }
           loadTodos()
           tableView.reloadData()
       }
       
       
       
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           loadTodos()
           DispatchQueue.main.async {
               searchBar.resignFirstResponder()
           }
           tableView.reloadData()
           searchBar.resignFirstResponder()
       }
   }
