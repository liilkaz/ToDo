//
//  TableViewController.swift
//  ToDo
//
//  Created by Лилия Феодотова on 19.03.2023.
//

import UIKit
import CoreData

class ToDoListTableViewController: UITableViewController {
    
    let colors = Colors()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items = [Item]()
    
    var selectCategory: Category?{
        didSet{
            loadItems()
        }
    }
    
    private lazy var addBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.rowHeight = 70
      
    }
    override func viewWillAppear(_ animated: Bool) {
        setNavigation()
    }
    
    private func setNavigation(){
        guard let navBar = navigationController?.navigationBar else{
            fatalError("Navigation Controller does not exist")
        }
        
        title = selectCategory?.name
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colors.hexStringToUIColor(hex: (selectCategory?.color)!)
        let titleAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = titleAttribute
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navigationItem.rightBarButtonItem = addBarButtonItem
        setupSearchBar()
    }
    
    private func setupSearchBar(){
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.tintColor = .white
    }
    
    @objc func addBarButtonTapped(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add item", style: .default) { action in
            if textField.text != ""{
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectCategory
                self.items.append(newItem)
                self.saveItems()
                self.loadItems()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create a new item"
            textField = alertTextField
        }
        alert.addAction(add)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func saveItems(){
        do{
            try context.save()
        }catch{
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectCategory!.name!)
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else{
            request.predicate = categoryPredicate
        }
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do{
            items = try context.fetch(request)
            
        } catch{
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.backgroundColor = colors.hexStringToUIColor(hex: (selectCategory?.color!)!).withAlphaComponent(CGFloat(indexPath.row) / CGFloat(items.count))
        
        cell.accessoryType = item.done ? .checkmark : .none
        cell.tintColor = (CGFloat(indexPath.row) / CGFloat(items.count) > 0.5 ) ? UIColor.white : UIColor.blue
        cell.textLabel?.textColor = (CGFloat(indexPath.row) / CGFloat(items.count) > 0.5 ) ? UIColor.white : UIColor.black
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].done = !items[indexPath.row].done
        saveItems()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(items[indexPath.row])
            items.remove(at: indexPath.row)
            saveItems()
        }
    }
}

//MARK: - UISearchBarDelegate

extension ToDoListTableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count != 0{
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request, predicate: predicate)
        } else{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
