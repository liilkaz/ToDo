//
//  TableViewController.swift
//  ToDo
//
//  Created by Лилия Феодотова on 19.03.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var items: Results<Item>?
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
        if let colorHex = UIColor(hexString: (selectCategory!.color!)){
            appearance.backgroundColor = colorHex
            navBar.tintColor = ContrastColorOf(colorHex, returnFlat: true)
            let titleAttribute = [NSAttributedString.Key.foregroundColor: ContrastColorOf(colorHex, returnFlat: true)]
            appearance.largeTitleTextAttributes = titleAttribute
        } else{
            appearance.backgroundColor = .blue
            navBar.tintColor = ContrastColorOf(UIColor.blue, returnFlat: true)
            let titleAttribute = [NSAttributedString.Key.foregroundColor: ContrastColorOf(UIColor.blue, returnFlat: true)]
            appearance.largeTitleTextAttributes = titleAttribute
        }
        
        
        
        
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(item)
                }
            } catch{
                print(error)
            }
        }
    }
    
    func loadItems() {
        items = selectCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    @objc func addBarButtonTapped(){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let add = UIAlertAction(title: "Add item", style: .default) { action in
            if textField.text != ""{
                if let currentCategory = self.selectCategory{
                    do{
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch{
                        print(error)
                    }
                }
            }
            self.tableView.reloadData()
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
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row]{
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: (selectCategory?.color)!)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)){
                let contrastColor = ContrastColorOf(color, returnFlat: true)
                cell.backgroundColor = color
                cell.textLabel?.textColor = contrastColor
                cell.tintColor = contrastColor
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else{
            cell.textLabel?.text = ""
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    //MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = items?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            } catch{
                print(error)
            }
        }
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate

extension ToDoListTableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        if searchText.count != 0{
            items = items?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        } else{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
