//
//  CategoriesTableViewController.swift
//  ToDo
//
//  Created by Лилия Феодотова on 20.03.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoriesTableViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    private lazy var addBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
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

        let color = RandomFlatColorWithShade(.light)
        appearance.backgroundColor = color
        navigationController?.navigationBar.prefersLargeTitles = true
        navBar.tintColor = ContrastColorOf(color, returnFlat: true)
        
        navigationItem.rightBarButtonItem = addBarButtonItem

        // setup title font color
        title = "To Do"
        let titleAttribute = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(category)
                }
            } catch{
                print(error)
            }
        }
    }
    
    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("Error: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    @objc func addBarButtonTapped(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add Category", style: .default) { action in
            if textField.text != ""{
                
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.color = RandomFlatColorWithShade(.light).hexValue()

                self.save(category: newCategory)
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row]{
            guard let categoryColor = UIColor(hexString: category.color!) else  {fatalError()}
            cell.textLabel?.text = category.name
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.backgroundColor = categoryColor
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let toDo = ToDoListTableViewController()
        navigationController?.pushViewController(toDo, animated: true)
            toDo.selectCategory = categories?[indexPath.row]
    }
}

//MARK: - UISearchBarDelegate

extension CategoriesTableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count != 0{
            
            categories = categories?.filter("name CONTAINS[cd] %@", searchText).sorted(byKeyPath: "name", ascending: true)
            tableView.reloadData()
        } else{
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

