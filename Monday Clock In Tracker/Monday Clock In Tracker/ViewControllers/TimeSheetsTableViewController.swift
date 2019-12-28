//
//  TimeSheetsTableViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/19/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit

class TimeSheetsTableViewController: UITableViewController {

    private var rowVariables:[[Any]]!
    
    @IBAction func handleRefresh(_ sender: UIRefreshControl)
    {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false){(timer) in
            self.refreshTable()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        refreshTable()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rowVariables[1].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSheetCell")as! TimeSheetTableViewCell
        cell.dateRowLbl.text = rowVariables[0][indexPath.row] as? String
        cell.hrsRowLbl.text  = rowVariables[1][indexPath.row] as? String
        //cell.payRowLbl.text = rowVariables[2][indexPath.row] as? String
        return cell
    }
    
     public func refreshTable()
    {
        DatabaseFunctions.getRowValues()
        rowVariables = DatabaseFunctions.sendRowValues()
    }

}
