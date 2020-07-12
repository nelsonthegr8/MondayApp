//
//  RowInfo.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 2/5/20.
//  Copyright © 2020 Nelson Brumaire. All rights reserved.
//

import Foundation

class RowInfo
{
    private var date:String
    private var hrs:String
    private var pay:String
    private var id:Int64
    private var month:Int!
    private var year:Int!
    
    init(date: String, hrs:String, pay:String, id: Int64) {
        self.date = date
        self.hrs = hrs
        self.pay = pay
        self.id = id
        setMonth()
        setYear()
    }
    
    public func getHrs() -> String
    {
        return hrs
    }
    public func getDate() -> String
    {
        return date
    }
    public func getPay() -> String
    {
        return pay
    }
    public func getId() -> Int64
    {
        return id
    }
    public func getMonth() -> Int
    {
        return month
    }
    public func getYear() -> Int
    {
        return year
    }
    private func setMonth()
    {
        month = Int(date.prefix(7).suffix(2))
    }
    private func setYear()
    {
        year = Int(date.prefix(4))
    }
}
