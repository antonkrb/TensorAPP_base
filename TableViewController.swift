//
//  TableViewController.swift
//  TensorAPP
//
//  Created by ААА on 26.10.16.
//  Copyright © 2016 Anton Korobeynikov. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var fetchResultsController: NSFetchedResultsController<Folders>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        let fetchRequest: NSFetchRequest<Folders> = Folders.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "folder_title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext{
            
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchResultsController.delegate = self
        }
    
        
        do {
            try fetchResultsController.performFetch()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if (self.fetchResultsController.fetchedObjects?.isEmpty)! { getJSON()}
        
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        let textupdate = "Обновление"
        refreshControl?.attributedTitle = NSAttributedString(string: textupdate)
        refreshControl?.addTarget(self, action: #selector(getJSON), for: .valueChanged)
        //tableView.reloadData()
        //Убираем бэк в Nbar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    
    func ErrorCoonection() {
        self.refreshControl?.endRefreshing()
        let uc = UIAlertController(title: "Проблема подключения", message: "Проверьте настройки сети", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        uc.addAction(ok)
        present(uc, animated: true, completion: nil)
    }
    
    
    @IBAction func RefreshFolder(_ sender: AnyObject) {
        getJSON()
        self.refreshControl?.endRefreshing()
       // tableView.reloadData()
        
    }
    
    
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func getJSON() {
        
        let url = URL(string: "http://jsonstub.com/test_api")!;
        var request = URLRequest(url: url);
        
        request.cachePolicy = .reloadIgnoringCacheData;
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("cbd2482f-5e46-4483-b9f9-ad667183a86b", forHTTPHeaderField: "JsonStub-User-Key")
        request.addValue("334e7727-f014-493e-87c2-3db789aa802a", forHTTPHeaderField: "JsonStub-Project-Key")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyObject] else {
                    throw JSONError.ConversionFailed
                }
                
                //print(json)
  
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext{
                     self.DeleteFolders()
                    
                    for element in json {
                        let folders = Folders(context: context)
                        let nametitle = element["title"]!
                      //print(nametitle)
                        
                       // let msubs = element["subs"]as! [AnyObject]
                        
                      //  for subs in msubs {
                            folders.folder_title = nametitle as! String?
                       //     folders.subs_title = subs["title"] as! String?
                           // folders.subs_id = subs["id"] as! String?
                   //     }
                        
                        
                        
                        //  print("title: \(nametitle!)")
                        //          let msubs = element["subs"] as! [AnyObject]
                        
                        //self.mTitle.append(Folders(entity: nametitle as! String,insertInto: msubs))
                        do{
                            try context.save()
                            print("сохранил")
                        } catch let error as NSError {
                            print("Не удалось сохранить данные\(error), \(error.userInfo)")
                        }
                        
                    }
                    
                    do {
                        try self.fetchResultsController.performFetch()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                }
                
                
       //         print(self.mTitle.count)
               // print(self.fetchResultsController.fetchedObjects?.count)
                
                
                DispatchQueue.main.async { //Отдельный поток
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                }
                
                
                
            } catch let error as JSONError {
                self.refreshControl?.endRefreshing()
                print(error.rawValue)
                self.ErrorCoonection()
            } catch let error as NSError {
                self.refreshControl?.endRefreshing()
                print(error.debugDescription)
                self.ErrorCoonection()
            }
            
            }.resume() 
        
    }
    
    // MARK: - Fetch results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
    tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert: guard let indexPath = newIndexPath else { break }
            tableView.insertRows(at: [indexPath], with: .fade)
        case.delete: guard let indexPath = indexPath else { break }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case.update: guard let indexPath = indexPath else { break }
        tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            tableView.reloadData()
        }
     //   mTitle = controller.fetchedObjects as! [Folders]
       
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! titleTableViewCell
       cell.nameLabel.text = self.fetchResultsController.object(at: indexPath).folder_title
        
        //self.mTitle[indexPath.row].folder_title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.fetchResultsController.fetchedObjects?.count)!//self.mTitle.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //delete
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            self.mTitle.remove(at: indexPath.row)
//        }
//        tableView.deleteRows(at: [indexPath], with: .fade)
//    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
      let delete = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
     //   self.mTitle.remove(at: indexPath.row)
      //  self.fetchResultsController.object(at: <#T##IndexPath#>)
        
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext{
        
        let objectToDelete = self.fetchResultsController.object(at: indexPath)
            context.delete(objectToDelete)
            
            do{
            try context.save()
            }catch{
            print(error.localizedDescription)
            print("Error delete")
            }
            
        }
        
        }
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return [delete]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subs"{
            if let IndexPath = tableView.indexPathForSelectedRow{
                let dvc = segue.destination as! SubsTableViewControllers
               // dvc.folders = //self.mTitle[IndexPath.row]
                dvc.pFolder.append(self.fetchResultsController.object(at: IndexPath).folder_title!)
                //pFolder.append(self.mTitle[IndexPath.row].folder_title!)
            //   for element in self.mTitle {
            //        print(element)
                
             //   }
                
            }
        }
    }
    
    
    
    
    func ReloadFolder() {
        getJSON()
        self.refreshControl?.endRefreshing()
    }
    //
    
    func DeleteFolders(){
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext{
            
            do {
                try context.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Folders")))
                try context.save()
                print("clear core data")
            } catch {
                print(error.localizedDescription)
            }
    }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
