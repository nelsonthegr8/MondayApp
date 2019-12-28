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
//    //clock in table and attributes
//    private static let clockInTable = Table("ClockIn")
//    private static let clockInId = Expression<String>("id")
//    private static let clockInDay = Expression<String>("date")
//    private static let clockInTime = Expression<String>("inTime")
//    private static let clockOutTime = Expression<String>("outTime")
//    private static let breakInTime = Expression<String>("breakInTime")
//    private static let breakOutTime = Expression<String>("breakOutTime")
//    private static let clockInStatus = Expression<Bool>("clockInStatus")
//    private static let BreakStatus = Expression<Bool>("")
    private static var date:[String] = []
    private static var hrs:[String] = []
    private static var startTimes:[String] = []
    private static var endTimes:[String] = []
    private static var breakStartTimes:[Int: String] = [:]
    private static var breakEndTimes:[Int: String] = [:]
    
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
                let createClockInQuery = "CREATE TABLE ClockIn( id INTEGER PRIMARY KEY AUTOINCREMENT, date Text, inTime Text, outTime Text, breakInTime Text, breakOutTime Text, clockInStatus Text NOT Null, breakStatus Text NOT NULL, Final INTEGER NOT NULL)"
                do{try self.database.run(createClockInQuery)}catch{print(error)}
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
                Query = "UPDATE ClockIn SET breakStatus = 'true', breakInTime = '\(time)' WHERE id = (SELECT COUNT(*) FROM ClockIn)"
            }
            else if(status == "break end")
            {
                Query = "UPDATE ClockIn SET breakStatus = 'false', breakOutTime = '\(time)' WHERE id = (SELECT COUNT(*) FROM ClockIn)"
            }
            else if(status == "")
            {
                Query = "UPDATE ClockIn SET clockInStatus = 'false', outTime = '\(time)', Final = 1 WHERE id = (SELECT COUNT(*) FROM ClockIn)"
            }

            do{
                try self.database.run(Query)
            }catch{print(error)}
            
            
        }
        
        public static func getStatusOfPunchIn(button: String) -> Bool
        {
            var status = ""
            var response = false
            let Query = "SELECT \(button) FROM ClockIn WHERE id = (SELECT COUNT(*) FROM ClockIn)"
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
                formatter.dateStyle = .short
                response = formatter.string(from: currentDateTime)
            }
            else if(request == "Date")
            {
                formatter.dateStyle = .short
                response = formatter.string(from: currentDateTime)
            }else if(request == "Time")
            {
                formatter.timeStyle = .short
                response = formatter.string(from: currentDateTime)
            }
            
            return(response)
        }
    
        public static func turnTimeInto24hr(time: String) -> String
        {
            var newTime = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"

            let date = dateFormatter.date(from: time)
            dateFormatter.dateFormat = "HH:mm"

            let Date24 = dateFormatter.string(from: date!)
            
            newTime = Date24
            
            return newTime
        }
    
        public static func getRowValues()
        {
            let Query = "SELECT date, inTime, outTime, breakInTime, breakOutTime FROM ClockIn"
            //var result: Statement?
            //do{}catch{}
            resetValues()
            var i = 0
            for row in try! database.prepare(Query)
            {
                if(row[0] != nil){date.append(row[0] as! String)}
                else{}
                
                if(row[1] != nil){startTimes.append(row[1] as! String)}
                else{}
                
                if(row[2] != nil){endTimes.append(row[2] as! String)}
                else{}
                
                if(row[3] != nil){breakStartTimes[i] = (row[3] as! String)}
                else{}
                
                if(row[4] != nil){breakEndTimes[i] = (row[4] as! String)}
                else{}
                
                i+=1
            }
            
            setHrsCalculation()
        }
    
        public static func sendRowValues() -> [[Any]]
        {
            let rowResults:[[Any]] = [date,hrs]
            return rowResults
        }
    
        public static func getClockedInTime(time: String) -> String
        {
            var result = ""
            do{result = try database.scalar("SELECT \(time) FROM ClockIn WHERE id = (SELECT COUNT(*) FROM ClockIn)") as! String}catch{}
            return result
        }
    
        private static func resetValues()
        {
            date = []
            startTimes = []
            endTimes = []
            hrs = []
            breakStartTimes = [:]
            breakEndTimes = [:]
        }
    
        private static func removeLetter( _ text:String) -> String
        {
            
            var result = ""
            let char:Character = ":"
            
            for c in text {
                
                if c != char {
                    
                    result.append( c )
                }
            }
            
            return result
        }
    
        private static func setHrsCalculation()
        {
            if(!startTimes.isEmpty)
            {
                for index in (0...startTimes.count - 1)
                {
                    //this turns time into 24hr time then removes the : in the 24hr time and turns the string into an int to be subtracted
                    if(endTimes[index] == "" || startTimes[index] == ""){}//If null or empty do nothing
                    //if 24hr end time is less than 24hr start time start time add 2400 to it then subtract it to get hours also multiply by .01 to get decimal places
                    else if(Int(removeLetter(turnTimeInto24hr(time: endTimes[index])))! < Int(removeLetter(turnTimeInto24hr(time: startTimes[index])))!) && breakStartTimes.keys.contains(index)
                    {
                        let timeVaule = Double((Int(removeLetter(turnTimeInto24hr(time: endTimes[index])))! + 2400) - Int(removeLetter(turnTimeInto24hr(time: startTimes[index])))!) * 0.01
                        var formatString = "%.2f"
                        var timeToString = String(format: formatString, timeVaule)
                        
                        if(timeToString.contains("0."))
                        {formatString = "%0f";timeToString = String(format: formatString, timeVaule * 100.0);hrs.append(timeToString + " mins")}
                        else
                        {formatString = "%.1f";timeToString = String(format: formatString, timeVaule);hrs.append(timeToString + " hrs")}
                        print("here 1")
                    }
                    else if(breakStartTimes.keys.contains(index))
                    {
                        let timeVaule = Double((Int(removeLetter(turnTimeInto24hr(time: endTimes[index])))!) - Int(removeLetter(turnTimeInto24hr(time: startTimes[index])))!) * 0.01
                        var formatString = "%.2f"
                        var timeToString = String(format: formatString, timeVaule)
                        
                        if(timeToString.contains("0."))
                        {formatString = "%.0f";timeToString = String(format: formatString, timeVaule * 100.0);hrs.append(timeToString + " mins")}
                        else
                        {formatString = "%.1f";timeToString = String(format: formatString, timeVaule);hrs.append(timeToString + " hrs")}
                        print("Here 2")
                    }
                    else if(Int(removeLetter(turnTimeInto24hr(time: endTimes[index])))! < Int(removeLetter(turnTimeInto24hr(time: startTimes[index])))!)
                    {
                        let timeVaule = Double((Int(removeLetter(turnTimeInto24hr(time: endTimes[index])))! + 2400) - Int(removeLetter(turnTimeInto24hr(time: startTimes[index])))!) * 0.01
                        var formatString = "%.2f"
                        var timeToString = String(format: formatString, timeVaule)
                        
                        if(timeToString.contains("0."))
                        {formatString = "%0f";timeToString = String(format: formatString, timeVaule * 100.0);hrs.append(timeToString + " mins")}
                        else
                        {formatString = "%.1f";timeToString = String(format: formatString, timeVaule);hrs.append(timeToString + " hrs")}
                        
                    }
                    else
                    {
                        let timeVaule = Double((Int(removeLetter(turnTimeInto24hr(time: endTimes[index])))!) - Int(removeLetter(turnTimeInto24hr(time: startTimes[index])))!) * 0.01
                        var formatString = "%.2f"
                        var timeToString = String(format: formatString, timeVaule)
                        
                        if(timeToString.contains("0."))
                        {formatString = "%.0f";timeToString = String(format: formatString, timeVaule * 100.0);hrs.append(timeToString + " mins")}
                        else
                        {formatString = "%.1f";timeToString = String(format: formatString, timeVaule);hrs.append(timeToString + " hrs")}
                        
                    }
                    
                }
                
            }
            
        }
    
        
    
    }
