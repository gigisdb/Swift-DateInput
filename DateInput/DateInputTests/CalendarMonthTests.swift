//
//  CalendarMonthTests.swift
//  DateInput
//
//  Created by 石田純一 on 11/24/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit
import XCTest

class CalendarTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testProperties() {
        // 2014/10
        let calendar_201410 = CalendarMonth(year: 2014, month: 10)

        XCTAssertEqual(calendar_201410.year,  2014)
        XCTAssertEqual(calendar_201410.month,   10)
        XCTAssertEqual(calendar_201410.firstDay, 1)
        XCTAssertEqual(calendar_201410.lastDay, 31)
        XCTAssertEqual(calendar_201410.firstWeekday, Weekday.Wednesday, "\(calendar_201410.firstWeekday.rawValue)")
        XCTAssertEqual(calendar_201410.numWeekOfMonth, 5)
       
       
        // 2014/11
        let calendar_201411 = CalendarMonth(year: 2014, month: 11)

        XCTAssertEqual(calendar_201411.year,  2014)
        XCTAssertEqual(calendar_201411.month,   11)
        XCTAssertEqual(calendar_201411.firstDay, 1)
        XCTAssertEqual(calendar_201411.lastDay, 30)
        XCTAssertEqual(calendar_201411.firstWeekday, Weekday.Saturday, "\(calendar_201411.firstWeekday.rawValue)")
        XCTAssertEqual(calendar_201411.numWeekOfMonth, 6)


        // 2015/02
        let calendar_201502 = CalendarMonth(year: 2015, month: 2)

        XCTAssertEqual(calendar_201502.year,  2015)
        XCTAssertEqual(calendar_201502.month,    2)
        XCTAssertEqual(calendar_201502.firstDay, 1)
        XCTAssertEqual(calendar_201502.lastDay, 28)
        XCTAssertEqual(calendar_201502.firstWeekday, Weekday.Sunday, "\(calendar_201502.firstWeekday.rawValue)")
        XCTAssertEqual(calendar_201502.numWeekOfMonth, 4)


        // 2014/14
        let calendar_201414 = CalendarMonth(year: 2014, month: 14)

        XCTAssertEqual(calendar_201414.year,  2015)
        XCTAssertEqual(calendar_201414.month,    2)
        XCTAssertEqual(calendar_201414.firstDay, 1)
        XCTAssertEqual(calendar_201414.lastDay, 28)
        XCTAssertEqual(calendar_201414.firstWeekday, Weekday.Sunday, "\(calendar_201414.firstWeekday.rawValue)")
        XCTAssertEqual(calendar_201414.numWeekOfMonth, 4)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            let calendarMonth = CalendarMonth(year: 2014, month: 14)
        }
    }

}
