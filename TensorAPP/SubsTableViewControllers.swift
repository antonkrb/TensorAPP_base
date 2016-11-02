//
//  SubsTableViewControllers.swift
//  TensorAPP
//
//  Created by ААА on 28.10.16.
//  Copyright © 2016 Anton Korobeynikov. All rights reserved.
//

import UIKit

class SubsTableViewControllers: UITableViewController {
    var folders: Folders?
    var pFolder = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    //    title = folders!.title
        pFolder.removeAll()
        
       // for element in folders!.subs {
       //     pFolder.append(element["title"]! as! String)
       // }
        
    }
    
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! titleTableViewCell
        cell.nameLabel.text = pFolder
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
}
