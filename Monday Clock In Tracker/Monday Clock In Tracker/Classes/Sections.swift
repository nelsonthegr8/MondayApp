//
//  Sections.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 2/15/20.
//  Copyright © 2020 Nelson Brumaire. All rights reserved.
//

import Foundation

class Sections
{
    var isExpanded: Bool = true
    private var rowInfo: [RowInfo]
    
    init(rowInfo: [RowInfo], expand: Bool = true) {
        self.rowInfo = rowInfo
        self.isExpanded = expand
    }
    
    public func getRowInfo() -> [RowInfo]
    {
        return rowInfo
    }
    
    public func setExpanded(b: Bool)
    {
        isExpanded = b
    }
    
}
