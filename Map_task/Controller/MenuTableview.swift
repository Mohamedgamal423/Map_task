//
//  MenuTableview.swift
//  Map_task
//
//  Created by moh on 4/12/21.
//  Copyright © 2021 moh. All rights reserved.
//

import UIKit

class MenuTableview: UITableViewController {

    var items = ["location1", "location2", "location3", "location4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

   
}
