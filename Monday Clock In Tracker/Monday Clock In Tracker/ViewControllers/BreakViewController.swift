//
//  BreakViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/10/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit

class BreakViewController: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var inTimeLbl: UILabel!
    @IBOutlet weak var outTimeLbl: UILabel!
    @IBOutlet weak var breakInTimeLbl: UILabel!
    @IBOutlet weak var breakOutTimeLbl: UILabel!
    
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var inBtn: UIButton!
    @IBOutlet weak var outBtn: UIButton!
    @IBOutlet weak var bInBtn: UIButton!
    @IBOutlet weak var bOutBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    
    
    private var buttonSelected:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateBtn.layer.cornerRadius = 10
        self.inBtn.layer.cornerRadius = 10
        self.outBtn.layer.cornerRadius = 10
        self.bInBtn.layer.cornerRadius = 10
        self.bOutBtn.layer.cornerRadius = 10
        self.submitBtn.layer.cornerRadius = 10
        self.resetBtn.layer.cornerRadius = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePopupClosing), name: .saveDateTime, object: nil)
    }
    @IBAction func dateButton(_ sender: UIButton)
    {
        buttonSelected = "date"
    }
    @IBAction func inTimeButton(_ sender: UIButton)
    {
        buttonSelected = "inTime"
    }
    @IBAction func outTimeButton(_ sender: UIButton)
    {
        buttonSelected = "outTime"
    }
    @IBAction func breakInTime(_ sender: UIButton)
    {
        buttonSelected = "breakInTime"
    }
    @IBAction func breakOutTime(_ sender: UIButton)
    {
        buttonSelected = "breakOutTime"
    }
    
    @objc func handlePopupClosing(notification: Notification)
    {
        let dateVc = notification.object as! DatePopUpViewController
        switch buttonSelected {
        case "date":
            dateLbl.text = formatInfo(variable: dateVc.formattedDate,date: true)
        case "inTime":
            inTimeLbl.text = formatInfo(variable: dateVc.formattedTime)
        case "outTime":
            outTimeLbl.text = formatInfo(variable: dateVc.formattedTime)
        case "breakInTime":
            breakInTimeLbl.text = formatInfo(variable: dateVc.formattedTime)
        case "breakOutTime":
            breakOutTimeLbl.text = formatInfo(variable: dateVc.formattedTime)
        default:
            break
        }
    }
    
    private func formatInfo(variable: String,date: Bool = false) -> String
    {
        let formatter = DateFormatter()

        switch date {
        case true:
            formatter.dateStyle = .short
            let result = formatter.date(from: variable)
            formatter.dateFormat = "yyyy/MM/dd"
            let newResult = formatter.string(from: result!)
            return newResult
        default:
            formatter.timeStyle = .short
            let result = formatter.date(from: variable)
            let newString = formatter.string(from: result!)
            return newString
        }
        
        
    }
    
    @IBAction func SubmitInfo(_ sender: UIButton)
    {
        if(dateLbl.text == "" || inTimeLbl.text == "" || outTimeLbl.text == "")
        {
            Alert("Date and Time!");
        }
        else if(breakInTimeLbl.text != "" && breakOutTimeLbl.text == "" || breakOutTimeLbl.text != "" && breakInTimeLbl.text == "")
        {
            Alert(breakOutTimeLbl.text == "" ? "Break Out Time" : "Break In Time!")
        }
        else
        {
            DatabaseFunctions.createInsert(date: dateLbl.text!, intime: inTimeLbl.text!, outTime: outTimeLbl.text!, breakInTime: breakInTimeLbl.text!, breakOutTime: breakOutTimeLbl.text!)
            clearText()
            let alert = UIAlertController(title: "Alert", message: "You have successfully added a Time Stamp!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func ResetBtnPressed(_ sender: UIButton)
    {
        clearText()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender:Any?)
    {
        if (segue.identifier != "DateButtonSegue")
        {
            let popup = segue.destination as! DatePopUpViewController
            popup.showTimePicker = true
        }
    }
    
    private func clearText()
    {
        dateLbl.text = ""
        inTimeLbl.text = ""
        outTimeLbl.text = ""
        breakInTimeLbl.text = ""
        breakOutTimeLbl.text = ""
    }
    private func Alert(_ ans: String)
    {
        let alert = UIAlertController(title: "Invalid", message: "Please Enter a \(ans)", preferredStyle: .alert)
                   let dismiss = UIAlertAction(title: "Return", style: .cancel)
                   alert.addAction(dismiss)
                   present(alert, animated: true, completion: nil)
    }
    
}
