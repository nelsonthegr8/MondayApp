//
//  PayPeriods.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 2/19/20.
//  Copyright © 2020 Nelson Brumaire. All rights reserved.
//

import Foundation

class PayPeriod
{
    let calendar = Calendar.current;
    private var payPerionds:[String]!
    private var rowInfo: [RowInfo]
    private var years = [Int:[RowInfo]]()
    
    init(r: [RowInfo])
    {
        rowInfo = r;
        seperateByYears()
    }
    
    private func seperateByYears()
    {
        var months:[[RowInfo]] = [[],[],[],[],[],[],[],[],[],[],[],[]];
        var finalizedMonths:[[RowInfo]] = []
        
        //itterate through each row in the row variables to sift and place each punch in into the correct month path which is
        //1 less than the month number that is returned
        for row in rowInfo
        {
            months[row.getMonth() - 1].append(row)
        }
        //This for loop itterates through the built sections and sees which months actually have information inside of them
        //if its empty it skips over, if its not empty then add that section to the sections array to be displayed if the user
        //chooses the month segmented control
        for row in months
        {
            if(!row.isEmpty)
            {
                finalizedMonths.append(row)
            }else{}
        }
        //next itterate through the finalized weeded months array and weed it by the years to get the final sections
        for section in finalizedMonths
        {
            for row in section
            {
                if(years.keys.contains(row.getYear() + row.getMonth()))
                {
                    years[row.getYear() + row.getMonth()]?.append(row)
                }else
                {
                    years[row.getYear() + row.getMonth()] = []
                    years[row.getYear() + row.getMonth()]?.append(row)
                }
            }
        }
       
    }
 
    public func getYears() -> [Int:[RowInfo]]
    {
        return years
    }
    
    public func getPayPeriod() -> [String]
    {
        return payPerionds;
    }
}
