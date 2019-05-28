//
//  CategoryViewController.swift
//  Todoei
//
//  Created by Ian Coates on 5/27/19.
//  Copyright © 2019 Ian Coates. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var catArray = [Category]()
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = catArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = catArray[indexPath.row]
        }
     }
    
    //MARK: - Data Manipulation Methods
    func loadCategories(with requests : NSFetchRequest<Category> = Category.fetchRequest()){
        
        do{
            catArray = try context.fetch(requests)
        }catch{
            print("error fetching data \(error)")
        }
        tableView.reloadData()
    }
    
    func saveCategories(){
        
        do {
            try context.save()
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
            
            let newCat = Category(context: self.context)
            newCat.name = textField.text!
            
            self.catArray.append(newCat)
            self.saveCategories()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
