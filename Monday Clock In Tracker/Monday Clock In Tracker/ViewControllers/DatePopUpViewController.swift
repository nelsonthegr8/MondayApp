//
//  DatePopUpViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 1/1/20.
//  Copyright © 2020 Nelson Brumaire. All rights reserved.
//

import UIKit

class DatePopUpViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    var showTimePicker:Bool = false
    var formattedDate: String {
        get{
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: datePicker.date)
        }
    }
    var formattedTime: String {
        get{
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: datePicker.date)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (showTimePicker)
        {
            titleLbl.text = "Select Time"
            datePicker.datePickerMode = .time
            saveButton.setTitle("Save Time", for: .normal)
        }
    }
    

    @IBAction func saveDate(_ sender: Any) {
        NotificationCenter.default.post(name: .saveDateTime, object: self)
        
        dismiss(animated: true)
    }
}
