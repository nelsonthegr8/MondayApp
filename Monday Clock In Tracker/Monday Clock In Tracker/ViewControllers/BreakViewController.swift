//
//  BreakViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/10/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit

class BreakViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createInserts(_ sender: Any)
    {
        
        //create Swift alert to take in specified date and so forth to add to the function to then add to the table
        let alert = UIAlertController(title: "New Time Entry", message: "Enter Your Time Info", preferredStyle: .alert)
        
        alert.addTextField { (Date) in
            Date.placeholder = "date ex:02/02/2020"
            Date.keyboardType = .numbersAndPunctuation
        }
        alert.addTextField { (Day) in
            Day.placeholder = "Day ex: Monday"
        }
        alert.addTextField { (ClockIn) in
            ClockIn.placeholder = "Clock In Time ex: 12:00"
            ClockIn.keyboardType = .numbersAndPunctuation
        }
        alert.addTextField { (ClockOut) in
            ClockOut.placeholder = "Clock out time ex: 5:00"
            ClockOut.keyboardType = .numbersAndPunctuation
        }
        alert.addTextField { (BreakIn) in
            BreakIn.placeholder = "Break Start Time ex: 3:00"
            BreakIn.keyboardType = .numbersAndPunctuation
        }
        alert.addTextField { (BreakOut) in
            BreakOut.placeholder = "Break End Time ex: 3:30"
            BreakOut.keyboardType = .numbersAndPunctuation
        }
        
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            let date = String(alert.textFields![0].text!)
            let day = String(alert.textFields![1].text!)
            let inTime = String(alert.textFields![2].text!)
            let outTime = String(alert.textFields![3].text!)
            let bInTime = String(alert.textFields![4].text!)
            let bOutTime = String(alert.textFields![5].text!)
//            var clockInStats = false
            
            //logic for dealing with multiple entries here
//            if (!DatabaseFunctions.getStatusOfPunchIn())
//            {
//                 clockInStats = true
//            }else
//            {
//                clockInStats = false
//            }
           //calls create ClockInInserts function to add it to the table
            DatabaseFunctions.createPunchInInserts(date: date, inTime: inTime, clockInStatus: true)
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var testLbl: UILabel!
    @IBAction func test(_ sender: Any) {
    }
    
}
