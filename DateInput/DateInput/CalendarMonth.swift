//
//  CalendarMonth.swift
//  DateInput
//
//  Created by 石田純一 on 11/24/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//


import Foundation

enum Weekday: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

    static var All: [Weekday] {
        return [.Sunday,
                .Monday,
                .Tuesday,
                .Wednesday,
                .Thursday,
	            .Friday,
                .Saturday]
    }
   
    static let Count = 7
}

class CalendarMonth {
    private let _year: Int
    private let _month: Int
    private let _lastDate: (year: Int, month: Int, day: Int, weekday: Int)

    var year: Int {
        return _year
    }

    var month: Int {
        return _month
    }

    var firstDay: Int {
        return 1
    }

    var lastDay: Int {
        return _lastDate.day
    }

    var firstWeekday: Weekday {
        // １周目に何日あるかを算出する（日曜日始まりの場合は０）
        // 月 -> 土
        // ６ -> １
        let numDayOfFirstWeek = ((_lastDate.day - _lastDate.weekday) % 7)

        if numDayOfFirstWeek == 0 {
            // １周目が0の場合は、日曜日
            return Weekday.Sunday
        }
        else {
            // １周目にある日数から、初日の曜日を算出
            return Weekday(rawValue: Weekday.Saturday.rawValue - numDayOfFirstWeek + 1)!
        }
    }

    var numWeekOfMonth: Int {
        return Int(ceil( Double(self.lastDay + (self.firstWeekday.rawValue - 1)) / 7.0 ))
    }

    init (year: Int, month: Int) {
        _year     = year
        _month    = month
        _lastDate = NSDate(year: year, month: month + 1, day: 0).components
    }
}
