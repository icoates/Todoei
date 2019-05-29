//
//  TodoListViewController.swift
//  Todoei
//
//  Created by Ian Coates on 5/15/19.
//  Copyright © 2019 Ian Coates. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    var todoItems: Results<Item>?
    
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
             loadItems()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
        // Do any additional setup after loading the view.
       
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = selectedCategory?.color {
            title = selectedCategory!.name
            updateNavBar(withHexCore: color)
           
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
       updateNavBar(withHexCore: "1D9BF6")
        
        
    }
    
    //MARK: - Update nav bar method
    
    func updateNavBar(withHexCore colorHexCode: String)  {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller doesn't exist")
        }
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
    
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true) ]
        searchBar.barTintColor = navBarColor
        
    }
    
    //MARK: - TableView DataSourceMethods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            cell.backgroundColor = UIColor(hexString: selectedCategory!.color)!.darken(byPercentage:
                CGFloat(indexPath.row) / CGFloat(todoItems!.count)
            )
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        }else{
            cell.textLabel?.text = "No items added yet"
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //MARK: - TableView Delegete Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print (itemArray[indexPath.row])
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write {
                     item.done = !item.done
                }
            }catch{
                print("Error updating property \(error)")
            }
           
        }
        
        //saveItems()
        
        tableView.reloadData()
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item to Todoei", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                //Aca se cocina la comida
            if let currentCategory = self.selectedCategory{
              
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print ("Error saving item \(error)")
                }
            }
            self.tableView.reloadData()

        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField

        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Model Manipulation Funcs
    
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(item)
                }
            }catch{
                print("Error trying to delete item \(error)")
            }
        }
    }
    
}

//MARK: - SearchBar Methods

extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
