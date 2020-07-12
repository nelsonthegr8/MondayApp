//
//  SettingsViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/13/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var payRate: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        payRate.delegate = self
    }
    
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        
        guard let enteredPayRate = Double(payRate.text!) else{
            let alert = UIAlertController(title: "Alert", message: "Please enter a valid Payrate with no $ sign", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        DatabaseFunctions.updateDefaultPayRate(pay: enteredPayRate)
        
        payRate.text = ""
        
        let alert = UIAlertController(title: "Alert", message: "Pay Rate has been successfully changed", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        payRate.resignFirstResponder()
        return true
    }
    
}
