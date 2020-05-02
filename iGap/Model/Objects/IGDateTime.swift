//
//  IGDateTime.swift
//  iGap
//
//  Created by ahmad mohammadi on 5/2/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct IGDateTime {
    
    var date: IGDate?
    var time: IGTime?
    
    init() {
        
    }
    
    init(date: IGDate, time: IGTime) {
        self.date = date
        self.time = time
    }
    
    init(date: IGDate) {
        self.date = date
        self.time = IGTime(hour: 0, minute: 0)
    }
    
    struct IGDate {
        var year: Int
        var month: Int
        var day: Int
        
        init(year: Int, month: Int, day: Int) {
            self.year = year
            self.month = month
            self.day = day
        }
        
        init(year: Int, month: Int) {
            self.year = year
            self.month = month
            self.day = 1
        }
        
    }
    
    struct IGTime {
        var hour: Int
        var minute: Int
        var second: Int
        
        init(hour: Int, minute: Int, second: Int) {
            self.hour = hour
            self.minute = minute
            self.second = second
        }
        
        init(hour: Int, minute: Int) {
            self.hour = hour
            self.minute = minute
            self.second = 0
        }
        
    }
    
    
    // MARK: - Methods
    func toMobileBankString() -> String {
        if date == nil {
            return ""
        }
        if time == nil {
            return ""
        }
        
        return "\(date!.year)-\(date!.month)-\(date!.day) \(time!.hour):\(time!.minute):\(time!.second)"
    }
    
    
    
}
