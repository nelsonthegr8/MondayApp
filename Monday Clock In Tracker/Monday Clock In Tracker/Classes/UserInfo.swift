//
//  UserInfo.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 2/4/20.
//  Copyright © 2020 Nelson Brumaire. All rights reserved.
//

import Foundation

class UserInfo
{
    private var date: String
    private var inTime: String
    private var outTime: String
    private var bInTime: String
    private var bOutTime: String
    private var payRate: Double
    private var id: Int64
    
    init(date: String, inTime: String, outTime: String,bInTime: String,bOutTime: String, id: Int64, pay: Double) {
        self.date = date;
        self.inTime = inTime;
        self.outTime = outTime;
        self.bInTime = bInTime;
        self.bOutTime = bOutTime;
        self.payRate = pay;
        self.id = id;
    }
    
    public func setDate(date: String)
    {
        self.date = date;
    }
    public func getDate() -> String
    {
        return self.date;
    }
    
    public func setInTime(inTime: String)
    {
        self.inTime = inTime;
    }
    public func getInTime() -> String
    {
        return self.inTime;
    }
    
    public func setOutTime(outTime: String)
    {
        self.outTime = outTime;
    }
    public func getOutTime() -> String
    {
        return self.outTime;
    }
    
    public func setBinTime(bInTime: String)
    {
        self.bInTime = bInTime;
    }
    public func getBinTime() -> String
    {
        return self.bInTime;
    }
    
    public func setBoutTime(bOutTime: String)
    {
        self.bOutTime = bOutTime;
    }
    public func getBoutTime() -> String
    {
        return self.bOutTime;
    }
    public func getID() -> Int64
    {
        return self.id;
    }
    public func getPay() -> Double
    {
        return self.payRate;
    }
    
        
}
