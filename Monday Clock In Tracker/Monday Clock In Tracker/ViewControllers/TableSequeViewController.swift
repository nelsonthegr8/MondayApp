//
//  TableSequeViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 2/10/20.
//  Copyright © 2020 Nelson Brumaire. All rights reserved.
//

import UIKit

class TableSequeViewController: UIViewController {

    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var clockInLbl: UILabel!
    @IBOutlet weak var clockOutLbl: UILabel!
    @IBOutlet weak var bInLbl: UILabel!
    @IBOutlet weak var bOutLbl: UILabel!
    public var userId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillLbls();
        // Do any additional setup after loading the view.
    }
    
    private func fillLbls()
    {
        let userInfo: UserInfo = DatabaseFunctions.getInDepthInfo(id: userId)
        dateLbl.text = userInfo.getDate()
        clockInLbl.text = userInfo.getInTime()
        clockOutLbl.text = userInfo.getOutTime()
        bInLbl.text = userInfo.getBinTime() == "" ? "No Break" : userInfo.getBinTime()
        bOutLbl.text = userInfo.getBoutTime() == "" ? "No Break" : userInfo.getBoutTime()
    }
}
