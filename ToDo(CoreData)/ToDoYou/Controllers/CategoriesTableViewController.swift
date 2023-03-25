//
//  CategoriesTableViewController.swift
//  ToDo
//
//  Created by Лилия Феодотова on 20.03.2023.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {
    
    let colors = Colors()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [Category]()
    
    private lazy var addBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
        self.tableView.rowHeight = 70
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigation()
    }
    
    private func setNavigation(){
        guard let navBar = navigationController?.navigationBar else{
            fatalError("Navigation Controller does not exist")
        }

        // Navigation Bar background color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        let color = colors.getRandomColor()
        appearance.backgroundColor = colors.hexStringToUIColor(hex: color)
        navigationController?.navigationBar.prefersLargeTitles = true
        navBar.tintColor = .white
        
        navigationItem.rightBarButtonItem = addBarButtonItem

        // setup title font color
        title = "To Do"
        let titleAttribute = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = titleAttribute
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
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
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add Category", style: .default) { action in
            if textField.text != ""{
                
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text!
                newCategory.color = self.colors.getRandomColor()
                self.categories.append(newCategory)
                self.saveCategories() //
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addTextField{(alertTextField) in
            alertTextField.placeholder = "Create a new category"
            textField = alertTextField
        }
        alert.addAction(add)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    
    func saveCategories(){
        do{
            try context.save()
        }catch{
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do{
            categories = try context.fetch(request)
        } catch{
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.textLabel?.textColor = .white //??
        cell.backgroundColor = colors.hexStringToUIColor(hex: category.color ?? "#FFC312")
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let toDo = ToDoListTableViewController()
        navigationController?.pushViewController(toDo, animated: true)
            toDo.selectCategory = categories[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            saveCategories()
        }
    }
}


extension CategoriesTableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count != 0{
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            loadCategories(with: request)
        } else{
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
