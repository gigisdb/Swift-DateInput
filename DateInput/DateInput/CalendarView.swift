//
//  CalendarView.swift
//  DateInput
//
//  Created by 石田純一 on 11/10/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

private enum Weekday: Int {
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

private extension UIColor {
    class func colorWithWeekday (weekday: Weekday) -> UIColor {
        switch (weekday) {
        case .Sunday:    return UIColor.redColor()
        case .Saturday:  return UIColor.blueColor()
        default:
            return UIColor.blackColor()
        }
    }
}

protocol CalendarViewDelegate: class {
    func calendarView (calendarView: CalendarView, didSelectDate selectedDate: NSDate)
    func calendarView (calendarView: CalendarView, didChangeTopTitle topTitle: String)
}


class CalendarView: UIScrollView, UIScrollViewDelegate {

    // MARK: Properties

    weak var calendarViewDelegate: CalendarViewDelegate?

    var callback: ((year: Int, month: Int, day: Int) -> ())? {
        didSet {
            for monthView in self.monthViewList { monthView.callback = callback }
        }
    }

    private let monthViewList: [CalendarMonthView]!
    private var year: Int!
    private var month: Int!
    private var topTitle: String?


    // MARK: Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.monthViewList = (0..<4).map { _ -> CalendarMonthView in return CalendarMonthView(coder: aDecoder) }
        for monthView in self.monthViewList { monthView.callback = self.onTouchUpDayView }

        for (index, monthView) in enumerate(self.monthViewList) {
            monthView.frame = monthView.frame.rectByOffsetting(dx: 0, dy: CGFloat(44 * Weekday.Count * index))
            
            self.addSubview(monthView)
        }

        self.contentSize = self.monthViewList.first!.frame.rectByUnion(self.monthViewList.last!.frame).size
    }

    
    // MARK: Internal

    func reload (#year: Int, month: Int) {
        self.year  = year
        self.month = month

        for (index, monthView) in enumerate(self.monthViewList) {
            monthView.date = NSDate(year: year, month: month + index - 1, day: 1)
        }
    }

    override func layoutSubviews() {
        let contentOffsetY = self.contentOffset.y
        let topView = self.monthViewList.filter { ($0.frame.minY...$0.frame.maxY ~= contentOffsetY) }.first

        let newTopTitle = topView?.title ?? self.topTitle

        if newTopTitle != self.topTitle {
            self.topTitle = newTopTitle
            self.calendarViewDelegate?.calendarView(self, didChangeTopTitle: self.topTitle!)
        }

        if self.contentOffset.y < 0 {
            dispatch_async(dispatch_get_main_queue()) {
                self.prev()
                self.contentOffset.y += self.monthViewList[1].frame.origin.y
            }
        } else if self.contentOffset.y > self.monthViewList[2].frame.origin.y {
            dispatch_async(dispatch_get_main_queue()) {
                self.next()
                self.contentOffset.y = self.monthViewList[1].frame.origin.y
            }
        }
    }

    func onTouchUpDayView (year: Int, month: Int, day: Int) {
        let selectedDate = NSDate(year: year, month: month, day: day)

        self.calendarViewDelegate?.calendarView(self, didSelectDate: selectedDate)
    }
   
   
    // MARK: Private

    private func prev() {
        self.reload(year: self.year, month: self.month - 1)
    }

    private func next() {
        self.reload(year: self.year, month: self.month + 1)
    }
}


class CalendarMonthView: UIView {

    // MARK: Types

    struct Constants {
        static let width  = 44
        static let height = 44
        static let size   = CGSize(width: width, height: height)
    }


    // MARK: Properties

    var callback: ((year: Int, month: Int, day: Int) -> ())?

    var title: String {
        let (year, month, _, _) = self.date.components

        return "\(year)/\(month)"
    }

    var date: NSDate! {
        didSet {
            configureView(date)

            self.titleLabel.text = self.title
        }
    }
   
    private let titleLabel: UILabel!
    private let dayViewList = reduce((0..<6), [CalendarDayView]()) { $0 + CalendarMonthView.createDayViews($1) }


    // MARK: Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.titleLabel = UILabel(frame: self.titleLabelFrame)
        self.addSubview(self.titleLabel)

        let dayViewContainer = UIView(frame: self.dayViewContainerFrame)
        self.addSubview(dayViewContainer)

        for dayView in self.dayViewList {
            dayView.addTarget(self, action: "onTouchDayView:", forControlEvents: .TouchUpInside)

            dayViewContainer.addSubview(dayView)
        }
    }


    // MARK: Internal

    class func createDayViews (weekOfMonth: Int) -> [CalendarDayView] {
        return Array( enumerate(Weekday.All) ).map { index, weekday in
            let x     = Constants.width  * index
            let y     = Constants.height * weekOfMonth
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: Constants.size)

            return CalendarDayView(frame: frame, weekday: weekday)
        }
    }

    func onTouchDayView (sender: CalendarDayView) {
        if self.callback == nil { return }

        // dayがnilの場合は、押せない（非表示になっている）ので、無条件でdayをunwrapする
        let (year, month, _, _) = self.date.components
        self.callback!(year: year, month: month, day: sender.day!)
    }

   
    // MARK: Private

    private func configureView (date: NSDate) {
        // weekdayが1始まり（Sunday=1）なので、1を引く
        let startIndex = date.weekday - 1
        let lastDay    = date.lastDay

        for (index, dayView) in enumerate(self.dayViewList) {
            let day = index - startIndex + 1

            if day < 1 || day > lastDay {
                dayView.day = nil
            }
            else {
                dayView.day = day
            }
        }
        
        let numWeekOfmonth = self.dayViewList[ self.dayViewList.count - Weekday.Count ].hidden ? 6 : 7
        self.frame = CGRect(origin: self.frame.origin,
                              size: Constants.size * CGSize(width: Weekday.Count, height: numWeekOfmonth))
    }
}

extension CalendarMonthView {
    var titleLabelFrame: CGRect {
        return CGRect(origin: CGPoint.zeroPoint, 
                        size: CGSize(width: self.frame.width, height: 44))
    }
   
    var dayViewContainerFrame: CGRect {
        let titleLabelSize = self.titleLabelFrame.size

        return CGRect(origin: CGPoint(x: 0, y: titleLabelSize.height), 
                        size: Constants.size * CGSize(width: Weekday.Count, height: 6))
    }
}


class CalendarDayView: UIButton {

    // MARK: Properties

    var day: Int? {
        didSet {
            if let day = self.day {
                self.label.text = "\(day)"
                self.hidden     = false
            }
            else {
                self.hidden = true
            }
        }
    }

    private var label: UILabel!


    // MARK: Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.label = UILabel(frame: self.frame)
    }

    private init (frame: CGRect, weekday: Weekday) {
        super.init(frame: frame)

        self.hidden = true

        self.label = UILabel(frame: CGRect(origin: CGPoint.zeroPoint, size: frame.size))
        self.label.textAlignment = .Center
        self.label.textColor     = UIColor.colorWithWeekday(weekday)
        
        self.addSubview(self.label)
    }
}