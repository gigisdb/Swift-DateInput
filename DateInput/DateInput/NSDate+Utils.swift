//
//  NSDate+Utils.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import Foundation

extension NSDate {
    var year:    Int { return components.year }
    var month:   Int { return components.month }
    var day:     Int { return components.day }
    var weekday: Int { return components.weekday }

    var components: (year: Int, month: Int, day: Int, weekday: Int) {
        let flag = NSCalendarUnit.CalendarUnitYear  |
            NSCalendarUnit.CalendarUnitMonth |
            NSCalendarUnit.CalendarUnitDay |
            NSCalendarUnit.CalendarUnitWeekday

        let components = NSCalendar.currentCalendar().components(flag, fromDate: self)
        return (components.year, components.month, components.day, components.weekday)
    }

    var lastDay: Int {
        let (year, month, _, _) = self.components
        let date = NSDate(year: year, month: month + 1, day: 0)

        return date.day
    }

    convenience init (year: Int, month: Int, day: Int) {
        var components   = NSDateComponents()
        components.year  = year
        components.month = month
        components.day   = day
       
        let date = NSCalendar.currentCalendar().dateFromComponents(components)
        
        self.init(timeInterval: 0, sinceDate: date!)
    }
}