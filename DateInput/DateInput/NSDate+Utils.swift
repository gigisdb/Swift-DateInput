//
//  NSDate+Utils.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import Foundation

enum Weekday: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}
func + (lhs: Weekday, rhs: Int) -> Weekday {
    return Weekday(rawValue: (lhs.rawValue + rhs) % 7)!
}

extension NSDate {
    var year:    Int { return components.year }
    var month:   Int { return components.month }
    var day:     Int { return components.day }
    var weekday: Int { return components.weekday }

    var lastDay: Int {
        let date = NSDate(year: components.year, month: components.month + 1, day: 0)

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

    private var components: NSDateComponents {
        let flag = NSCalendarUnit.CalendarUnitYear  |
            NSCalendarUnit.CalendarUnitMonth |
            NSCalendarUnit.CalendarUnitDay |
            NSCalendarUnit.CalendarUnitWeekday

        return NSCalendar.currentCalendar().components(flag, fromDate: self)
    }
}