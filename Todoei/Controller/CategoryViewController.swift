//
//  CategoryViewController.swift
//  Todoei
//
//  Created by Ian Coates on 5/27/19.
//  Copyright © 2019 Ian Coates. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var catArray: Results<Category>?
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
        
        
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard let category = catArray?[indexPath.row] else {
            fatalError()
        }
        cell.textLabel?.text =  category.name
        
        guard let catUIColor = UIColor(hexString: category.color) else {
            fatalError()
        }
        
        cell.backgroundColor = catUIColor
        cell.textLabel?.textColor = ContrastColorOf(catUIColor, returnFlat: true)
        
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = catArray?[indexPath.row]
        }
     }
    
    override func updateModel(at indexPath: IndexPath) {
        if let cateogory = self.catArray?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(cateogory)
                }
            }catch{
                print("error trying to delete category \(error)")
            }

        }
    }
    
    //MARK: - Data Manipulation Methods
    func loadCategories(){
        
        catArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func save(category: Category){
        
        do {
            try realm.write {
                realm.add(category)
            }
        }catch{
            print("Error saving category: \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category to Todoei", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //Aca se cocina la comida
            
            let newCat = Category()
            newCat.name = textField.text!
            newCat.color = UIColor.randomFlat.hexValue()
           
            self.save(category: newCat)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}


