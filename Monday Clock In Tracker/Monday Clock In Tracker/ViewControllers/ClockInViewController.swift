//
//  ClockInViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/13/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit

class ClockInViewController: UIViewController {
    //initialize the view controller items to variables
    
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var clockInButton: UIButton!
    @IBOutlet weak var breakButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        DatabaseFunctions.makeConnectionToDB()
        setLabels()
        setClockInButtons()
    }
    
    @IBAction func punchButton(_ sender: Any)
    {
        clockInButtonsFunctions()
    }
    
    @IBAction func breakButtonPressed(_ sender: Any)
    {
        breakButtonFunctions()
    }
    
    private func clockInButtonsFunctions()
    {
           
           switch breakButton.title(for:.normal) {
           case "Break End":
               showAlerts()
           default:
               if(clockInButton.titleLabel?.text == "Clock Out")
               {
                   DatabaseFunctions.createPunchOutInserts(status: "", time: DatabaseFunctions.getCurrentTime(request: "Time"))
                   TimeLbl.text = "Clocked out at: " + DatabaseFunctions.getCurrentTime(request: "Time")
               }
               else
               {
                   DatabaseFunctions.createPunchInInserts(date: DatabaseFunctions.getCurrentTime(request: "Date"), inTime: DatabaseFunctions.getCurrentTime(request: "Time"), clockInStatus: true)
                   TimeLbl.text = "Clocked In at: " + DatabaseFunctions.getCurrentTime(request: "Time")
               }
           }

           setClockInButtons()
       }
    
    private func breakButtonFunctions()
    {
        if(breakButton.titleLabel?.text == "Break End")
        {
            DatabaseFunctions.createPunchOutInserts(status: "break end", time: DatabaseFunctions.getCurrentTime(request: "Time"))
            TimeLbl.text = "Break Ended at: " + DatabaseFunctions.getCurrentTime(request: "Time")
        }
        else
        {
            DatabaseFunctions.createPunchOutInserts(status: "break start", time: DatabaseFunctions.getCurrentTime(request: "Time"))
            TimeLbl.text = "Break Started at: " + DatabaseFunctions.getCurrentTime(request: "Time")
        }
        setClockInButtons()
    }
    
    private func setClockInButtons()
    {
        
        if(DatabaseFunctions.getStatusOfPunchIn(button: "clockInStatus"))//Gets clockin status but passes the name of the column to the query
        {
            clockInButton.setTitle("Clock Out", for:.normal)
            clockInButton.backgroundColor = .red
            breakButton.isHidden = false
            TimeLbl.text = "Clocked In at: " + DatabaseFunctions.getClockedInTime(time: "inTime")
            //this sets the break button based on what is stored in the database
            if(DatabaseFunctions.getStatusOfPunchIn(button: "breakStatus"))
            {breakButton.setTitle("Break End", for:.normal); TimeLbl.text = "Break In at: " + DatabaseFunctions.getClockedInTime(time: "inTime")}
            else
            {breakButton.setTitle("Break Start", for:.normal)}
            
        }
        else
        {
            clockInButton.setTitle("Clock In", for:.normal)
            clockInButton.backgroundColor = UIColor(red: 0.2314, green: 0.8196, blue: 0, alpha: 1.0) /* #3bd100 */
            breakButton.isHidden = true
        }
        
    }

    private func setLabels()
    {
        DateLbl.text = DatabaseFunctions.getCurrentTime(request: "Date")
    }

    private func showAlerts()
    {
        let alert = UIAlertController(title: "Alert", message: "End break first before clocking out", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
