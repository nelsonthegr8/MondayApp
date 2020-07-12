//
//  TimeSheetsTableViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/19/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit
import MessageUI

class TimeSheetsTableViewController: UITableViewController {
//initialize variables
    private var rowVariables:[RowInfo] = []
    private let months:[String] =
        ["January","February","March",
        "April","May","June","July","August",
        "September","October","November","December"];
    private var sections:[Sections] = []
    private var userId:Int!
    private var editStyle:Bool = false
    //first function that runs when view is loaded
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupTable()
        navigationItem.rightBarButtonItem = editButtonItem
    }
    //Function handles the pull down to refresh function
    @IBAction func handleRefresh(_ sender: UIRefreshControl)
    {
        refreshTable()
    }

    // MARK: - Table view data source
    //Checks to see which row was tapped and in which section then passes the info to the table segue
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if(!self.tableView.isEditing)
        {
            userId = Int(sections[indexPath.section].getRowInfo()[indexPath.row].getId())
            self.performSegue(withIdentifier: "TableSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let info = segue.destination as! TableSequeViewController
        info.userId = userId;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sections[section].isExpanded ? sections[section].getRowInfo().count : 0;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return sections.count;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = months[sections[section].getRowInfo()[0].getMonth() - 1] + " - " + String(sections[section].getRowInfo()[0].getYear())
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.tag = section
        button.addTarget(self, action: #selector(handleOpenClose), for: .touchUpInside)
        
        return button
    }
    
    @objc func handleOpenClose(button: UIButton)
    {
        let section = button.tag
        var indexPaths = [IndexPath]()
        
        for row in sections[section].getRowInfo().indices
        {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        sections[section].isExpanded = sections[section].isExpanded ? false : true
        
        switch sections[section].isExpanded {
        case false:
            tableView .deleteRows(at: indexPaths, with: .fade)
        default:
            tableView .insertRows(at: indexPaths, with: .fade)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeSheetCell")as! TimeSheetTableViewCell
        
        cell.dateRowLbl.text = sections[indexPath.section].getRowInfo()[indexPath.row].getDate()
        cell.hrsRowLbl.text  = sections[indexPath.section].getRowInfo()[indexPath.row].getHrs() + (Double(sections[indexPath.section].getRowInfo()[indexPath.row].getHrs())! > 1.0 ? "hr(s)" : "min(s)")
        cell.payRowLbl.text = sections[indexPath.section].getRowInfo()[indexPath.row].getPay()
        
        return cell
    }
    
    
     private func refreshTable()
    {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false){(timer) in
            DatabaseFunctions.getRowValues()
            self.rowVariables = DatabaseFunctions.sendRowValues()
            self.setSectionsMonths()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    //function takes the information and puts them into month sections to be displayed on the table
    private func setSectionsMonths()
    {
        //make sure sections array is empty so that when this function is call it does not create double
        sections.removeAll()
        
        let payPeriods = PayPeriod(r: rowVariables)
        
        for section in payPeriods.getYears().values
        {
            if !section.isEmpty
            {
                sections.append(Sections(rowInfo: section, expand: Int(DatabaseFunctions.getCurrentTime(request: "Date").prefix(7).suffix(2)) == section[0].getMonth()))
            }
        }
        
    }
    
    private func setupTable()
    {
        refreshTable()
        changeEditingStyle()
    }

    @IBAction func sendSelectionToEmail(_ sender: Any) {
        
        switch self.tableView.isEditing {
        case true:
            if(self.tableView.indexPathsForSelectedRows?.isEmpty ?? true)
            {
                self.tableView.setEditing(false, animated: true)
                editStyle = false
                changeEditingStyle()
                navigationItem.rightBarButtonItem?.isEnabled = true
            }else
            {
                emailInfo()
            }
        default:
            editStyle = true
            changeEditingStyle()
            self.tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    }
    
    private func changeEditingStyle()
    {
        if(editStyle){self.tableView.allowsMultipleSelectionDuringEditing = true}
        else{self.tableView.allowsMultipleSelectionDuringEditing = false}
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete)
        {
            DatabaseFunctions.deleteRowFromDatabase(id: Int(sections[indexPath.section].getRowInfo()[indexPath.row].getId()))
            refreshTable()
        }
    }
    
    private func emailInfo()
    {
        //initiate variables
        var subjectBodyString = "";
        //create a catch to see if the user can send an email
        guard MFMailComposeViewController.canSendMail() else{
            //show the user they cant send mail
            
            //stop editing mode
            self.tableView.setEditing(false, animated: true)
            editStyle = false
            changeEditingStyle()
            navigationItem.rightBarButtonItem?.isEnabled = true
            return
        }
        //get all selected rows info and input it into the message string
        for index in (self.tableView.indexPathsForSelectedRows)!
        {
            let userInfo: UserInfo = DatabaseFunctions.getInDepthInfo(id: Int(sections[index.section].getRowInfo()[index.row].getId()))
            subjectBodyString +=
                "\n" + "\n" + sections[index.section].getRowInfo()[index.row].getDate() + "\n" + userInfo.getInTime() + " - " + userInfo.getOutTime() + " = " + sections[index.section].getRowInfo()[index.row].getHrs() + "hrs"
        }
        
        //create mail composer
        let composer = MFMailComposeViewController()
        
        composer.mailComposeDelegate = self
        composer.setToRecipients(["Roym@phybill.com"])
        composer.setSubject("Hours")
        composer.setMessageBody(subjectBodyString, isHTML: false)
        
        present(composer, animated:true)
        
        //stop the editing mode
        self.tableView.setEditing(false, animated: true)
        editStyle = false
        changeEditingStyle()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
}

extension UITableViewController:MFMailComposeViewControllerDelegate{
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            //show error alert
            controller.dismiss(animated: true)
        }
        
        switch result {
        case .cancelled:
            break;
        case .failed:
            break;
        case .saved:
            break;
        case .sent:
            break;
        @unknown default:
            break;
        }
        
        controller.dismiss(animated: true)
        
    }
}
