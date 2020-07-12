//
//  DatabaseFunctions.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/10/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import Foundation
import SQLite

class DatabaseFunctions{
//call the database globally to establish a connection
    private static var database: Connection!
    private static var UserInformation:[UserInfo] = []
    private static var hrs:[String] = []

    public static func makeConnectionToDB()
    {
        do{
               //this creates a folder in the users phone to where we can store the database
               let documentDirectory = try FileManager.default.url(for: .documentDirectory,
               in: .userDomainMask, appropriateFor: nil, create: true)
               //this creates the database name in the file or folder we created above
               let fileUrl = documentDirectory.appendingPathComponent("TimeSheet").appendingPathExtension("sqlite3")
               let database = try Connection(fileUrl.path)//this creates a connection to the database
               self.database = database//this makes the connection that we made to the database global so that we can make calls and changes in the lines below
            }catch{
               print(error)
            }
        //below checks to see if table is here if not create the table
        var clockInHere:Int64 = 0
        let Query = "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='ClockIn'"
        do{
            let tableHere = try database.prepare(Query)
            clockInHere = try tableHere.scalar() as! Int64
        }catch{}
        
        if(clockInHere == 0)
        {
            createTable()
        }
        
    }

    private static func createTable()
    {
            let createClockInQuery = "CREATE TABLE ClockIn( id INTEGER PRIMARY KEY AUTOINCREMENT, date Text, inTime Text, outTime Text, breakInTime Text, breakOutTime Text, clockInStatus Text NOT Null, breakStatus Text NOT NULL, Final INTEGER NOT NULL, PayRate DOUBLE)"
            let createPayRateTable = "CREATE TABLE PayRate(rate DOUBLE)"
            let createPayInsert = "INSERT INTO PayRate(rate) Values(12.00)"
            do{try self.database.run(createClockInQuery)}catch{print(error)}
            do{try self.database.run(createPayRateTable);try self.database.run(createPayInsert)}catch{print(error)}
    }
    //this function is just a test to create/add rows to the database table rows
    public static func createPunchInInserts(date: String, inTime: String, clockInStatus: Bool)
    {
        
        var Query = "INSERT INTO ClockIn( date, inTime, clockInStatus, breakStatus, Final)"
        let values = "VALUES('\(date)', '\(inTime)', '\(clockInStatus)', 'false', 0)"
        Query.append(values)

        do{
            try self.database.run(Query)
        }catch{print(error)}
        
    }

    public static func createPunchOutInserts(status: String, time: String)
    {
        var Query = ""
        if(status == "break start")
        {
            Query = "UPDATE ClockIn SET breakStatus = 'true', breakInTime = '\(time)' WHERE id = (SELECT id FROM ClockIn ORDER By id DESC LIMIT 1)"
        }
        else if(status == "break end")
        {
            Query = "UPDATE ClockIn SET breakStatus = 'false', breakOutTime = '\(time)' WHERE id = (SELECT id FROM ClockIn ORDER By id DESC LIMIT 1)"
        }
        else if(status == "")
        {
            Query = "UPDATE ClockIn SET clockInStatus = 'false', outTime = '\(time)', Final = 1 WHERE id = (SELECT id FROM ClockIn ORDER By id DESC LIMIT 1)"
        }

        do{
            try self.database.run(Query)
        }catch{print(error)}
        
        
    }
    
    public static func getStatusOfPunchIn(button: String) -> Bool
    {
        var status = ""
        var response = false
        let Query = "SELECT \(button) FROM ClockIn ORDER By id DESC LIMIT 1"
        do{
            let result = try database.run(Query)
            
            if(try (result.scalar()) != nil)
            {status = try result.scalar() as! String; if(status == "true"){response = true}}
            else{}
            
        }catch{print(error)}
        
        return response
    }

    public static func getCurrentTime(request: String) -> String
    {
        var response = ""
        let currentDateTime = Date()
        let formatter = DateFormatter()
        
        if(request == "both")
        {
            formatter.timeStyle = .short
            formatter.dateFormat = "yyyy/MM/dd"
            response = formatter.string(from: currentDateTime)
        }
        else if(request == "Date")
        {
            formatter.dateFormat = "yyyy/MM/dd"
            response = formatter.string(from: currentDateTime)
        }else if(request == "Time")
        {
            formatter.timeStyle = .short
            response = formatter.string(from: currentDateTime)
        }
        
        return(response)
    }
    
    public static func defaultPay() -> Double
    {
        let Query = "SELECT rate FROM PayRate"
        var rate:Double = 0.00
        
        do
        {
            let row = try database.run(Query)
            rate = try row.scalar() as! Double
        }catch{print(error)}
        
        
        return rate;
    }
    
    public static func updateDefaultPayRate(pay: Double)
    {
        let Query = "UPDATE PayRate SET rate = \(pay);"
        do{try self.database.run(Query)}catch{print(error)}
    }
    
    public static func getRowValues()
    {
        let Query = "SELECT date, inTime, outTime, breakInTime, breakOutTime, id, PayRate FROM ClockIn WHERE final = 1 ORDER BY date"
        resetValues()
        for row in try! database.prepare(Query)
        {
            UserInformation.append(UserInfo(date: row[0] as? String ?? "", inTime: row[1] as? String ?? "", outTime: row[2] as? String ?? "", bInTime: row[3] as? String ?? "", bOutTime: row[4] as? String ?? "", id: row[5] as! Int64, pay: row[6] as? Double ?? defaultPay()))
        }
        setHrsCalculation()
    }

    public static func sendRowValues() -> [RowInfo]
    {
        var rowResults:[RowInfo] = []
        var i = 0;
        for userInfo in UserInformation
        {
            let payText = "$"+String(format:"%.2f", (userInfo.getPay() * Double(hrs[i])!))
            rowResults.append(RowInfo(date: userInfo.getDate(), hrs: hrs[i], pay: payText, id: userInfo.getID()))
            i+=1;
        }
        return rowResults
    }

    public static func createInsert(date: String,intime: String, outTime: String, breakInTime: String, breakOutTime: String)
    {
       let Query = "INSERT INTO ClockIn( date, inTime,outTime,breakInTime,breakOutTime,clockInStatus,breakStatus, Final) VALUES( '\(date)','\(intime)', '\(outTime)','\(breakInTime)','\(breakOutTime)','false','false', 1)"
       do{try database.run(Query)}
       catch{print(error)}
    }

    public static func getClockedInTime(time: String) -> String
    {
        var result = ""
        do{result = try database.scalar("SELECT \(time) FROM ClockIn WHERE id = (SELECT id FROM ClockIn ORDER By id DESC LIMIT 1)") as! String}catch{}
        return result
    }

    public static func getInDepthInfo(id: Int) -> UserInfo
    {
        let selectedInfo:UserInfo = UserInfo(date: "", inTime: "", outTime: "", bInTime: "", bOutTime: "", id: 1, pay: 0.00);
        for UserInfo in UserInformation
        {
            if(UserInfo.getID() == id)
            {
                return UserInfo;
            }
        }
        return selectedInfo;
    }
    
    public static func deleteRowFromDatabase(id: Int)
    {
        let Query = "DELETE FROM ClockIn WHERE id = \(id);"
        do{try self.database.run(Query)}catch{print(error)}
    }

    private static func resetValues()
    {
        UserInformation = []
        hrs = []
    }

    private static func removeLetter( _ text:String) -> String
    {
        
        var result = ""
        let charP:Character = "P"
        let charM:Character = "M"
        let charA:Character = "A"
        let charS:Character = " "
        
        for c in text {
            
            if c != charP && c != charM && c != charA && c != charS {
                result.append( c )
            }
            
        }
        
        return result
    }

    private static func makeCalculationsForHrDisplay(startTime: String, endTime: String,breakStartTime: String = "01",breakEndTime: String = "01", isBreak: Bool = false) -> String
    {
        //Initialize Variables//
        var answer:String = ""
        var startHrs:Int = 0
        var endHrs:Int = 0
        var breakStartHrs:Int = 0
        var breakEndHrs:Int = 0
        
        if(startTime.prefix(2).contains(":"))
        {startHrs = Int(startTime.prefix(1))!}
        else{startHrs = Int(startTime.prefix(2))!}
        
        if(endTime.prefix(2).contains(":"))
        {endHrs = Int(endTime.prefix(1))!}
        else{endHrs = Int(endTime.prefix(2))!}
        
        if(isBreak)
        {
            if(breakStartTime.prefix(2).contains(":"))
            {breakStartHrs = Int(breakStartTime.prefix(1))!}
            else{breakStartHrs = Int(breakStartTime.prefix(2))!}
            
            if(breakEndTime.prefix(2).contains(":"))
            {breakEndHrs = Int(breakEndTime.prefix(1))!}
            else{breakEndHrs = Int(breakEndTime.prefix(2))!}
        }
        
        let breakStartMins = Int(breakStartTime.suffix(2))!
        var breakEndMins = Int(breakEndTime.suffix(2))!
        let startMins = Int(startTime.suffix(2))!
        var endMins = Int(endTime.suffix(2))!
        var finalBreakHrs:Int = 0
        var finalBreakMins:Int = 0
        var finalHrs:Int = 0
        var finalMins:Int = 0
        var answerHr:Int = 0
        var answerMin:Int = 0
       //end of region//
        
        if(endMins < startMins)
        {
            endHrs = endHrs - 1
            endMins = endMins + 60
            finalMins = endMins - startMins
        }else{finalMins = endMins - startMins}
        
        if(endHrs < startHrs)
        {
            endHrs = endHrs + 12
            finalHrs = endHrs - startHrs
        }else{finalHrs = endHrs - startHrs}
        //End of regular Calculations//
            if(isBreak)
            {
                if(breakEndMins < breakStartMins)
                {
                    breakEndHrs = breakEndHrs - 1
                    breakEndMins = breakEndMins + 60
                    finalBreakMins = breakEndMins - breakStartMins
                }else{finalBreakMins = breakEndMins - breakStartMins}
                
                if(breakEndHrs < breakStartHrs)
                {
                    breakEndHrs = breakEndHrs - 12
                    finalBreakHrs = breakEndHrs - breakStartHrs
                }else{finalBreakHrs = breakEndHrs - breakStartHrs}
                
               if(finalMins < finalBreakMins)
                {
                    finalHrs = finalHrs - 1
                    finalMins = finalMins + 60
                    answerMin = finalMins - finalBreakMins
                    answerHr = finalHrs - finalBreakHrs
                }
               else
               {
                answerMin = finalMins - finalBreakMins
                answerHr = finalHrs
                }
                if((Double(answerMin) / 0.60) >= 10.00)
                {answer = String(answerHr) + "." + String(Double(answerMin) / 0.60).prefix(2)}
                else
                {answer = String(answerHr) + ".0" + String(Double(answerMin) / 0.60).prefix(1)}
            }
            else
            {
                if((Double(finalMins) / 0.60) >= 10.00)
                {answer = String(finalHrs) + "." + String(Double(finalMins) / 0.60).prefix(2)}
                else
                {answer = String(finalHrs) + ".0" + String(Double(finalMins) / 0.60).prefix(1)}
            }
            
            return answer;
    }

    private static func setHrsCalculation()
    {
        if(!UserInformation.isEmpty)
        {
            for UserInfo in UserInformation
            {
                //this turns time into 24hr time then removes the : in the 24hr time and turns the string into an int to be subtracted
                if(UserInfo.getInTime() == "" || UserInfo.getOutTime() == ""){}//If null or empty do nothing
                //if 24hr end time is less than 24hr start time start time add 2400 to it then subtract it to get hours also multiply by .01 to get decimal places
                
                else if(UserInfo.getBinTime() != "")
                {
                    let answer = makeCalculationsForHrDisplay(startTime: removeLetter(UserInfo.getInTime()), endTime: removeLetter(UserInfo.getOutTime()),breakStartTime: removeLetter(UserInfo.getBinTime()),breakEndTime: removeLetter(UserInfo.getBoutTime()), isBreak: true)
                    hrs.append(answer)
                }
                else
                {
                    let answer = makeCalculationsForHrDisplay(startTime: removeLetter(UserInfo.getInTime()), endTime: removeLetter(UserInfo.getOutTime()))
                    hrs.append(answer)
                }
                
            }
            
        }
    }

}
