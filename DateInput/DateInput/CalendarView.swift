//
//  CalendarView.swift
//  DateInput
//
//  Created by 石田純一 on 11/10/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

private extension UIColor {
    class func colorWithWeekday (weekday: Int) -> UIColor {
        switch (weekday) {
        case 0:  return UIColor.redColor()
        case 6:  return UIColor.blueColor()
        default: return UIColor.blackColor()
        }
    }
}

protocol CalendarViewDelegate {
    func calendarView (dateView: CalendarView, didChangeTopTitle: String)
}


class CalendarView: UIScrollView, UIScrollViewDelegate {
    private let monthViewList: [CalendarMonthView]!

    var calendarViewDelegate: CalendarViewDelegate?

    var callback: ((year: Int, month: Int, day: Int) -> ())? {
        didSet {
            for monthView in self.monthViewList { monthView.callback = callback }
        }
    }

    private var year: Int!
    private var month: Int!

    func reload (#year: Int, month: Int, direction: Int = 0) {
        self.year  = year
        self.month = month

        for (index, monthView) in enumerate(self.monthViewList) {
            monthView.date = NSDate(year: year, month: month + index - 1, day: 1)
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.monthViewList = (0..<4).map { _ -> CalendarMonthView in return CalendarMonthView(coder: aDecoder) }
        self.contentSize  = CalendarMonthView.size * CGSize(width: 1, height: self.monthViewList.count)

        for (index, monthView) in enumerate(self.monthViewList) {
            monthView.frame = CGRectOffset(monthView.frame, 0, CalendarMonthView.size.height * CGFloat(index))
            self.addSubview(monthView)
        }
    }

    private func prev() {
        self.reload(year: self.year, month: self.month - 1)
    }

    private func next() {
        self.reload(year: self.year, month: self.month + 1)
    }

    private var topTitle: String?

    override func layoutSubviews() {
        let topViewIndex = Int(self.contentOffset.y / CalendarMonthView.size.height)
        let newTopTitle  = self.monthViewList[topViewIndex].title

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
}


class CalendarMonthView: UIView {
    struct Constants {
        static let width  = 44
        static let height = 44
        static let size   = CGSize(width: width, height: height)
    }

    class var size: CGSize {
        get { return Constants.size * CGSize(width: 7, height: 7) }
    }

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

    let titleLabel: UILabel!
    var dayViewList = [CalendarDayView]()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel = UILabel(frame: CGRect(origin: CGPoint.zeroPoint,
            size: CGSize(width: self.frame.size.width, height: 44)))
        self.addSubview(self.titleLabel)
        self.dayViewList = reduce((1...6), [CalendarDayView]()) {$0 + CalendarMonthView.dayViews($1)}

        for dayView in self.dayViewList {
            dayView.addTarget(self, action: "onTouchDayView:", forControlEvents: .TouchUpInside)
            self.addSubview(dayView)
        }
    }

    class func dayViews (weekOfMonth: Int) -> [CalendarDayView] {
        return (0..<7).map { weekday in
            let x     = Constants.width  * weekday
            let y     = Constants.height * weekOfMonth
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: Constants.size)

            return CalendarDayView(frame: frame, weekday: weekday)
        }
    }

    internal func onTouchDayView (sender: CalendarDayView) {
        if self.callback == nil { return }

        // dayがnilの場合は、押せない（非表示になっている）ので、無条件でdayをunwrapする
        let (year, month, _, _) = self.date.components
        self.callback!(year: year, month: month, day: sender.day!)
    }

    func configureView (date: NSDate) {
        // weekdayが1始まり（Sunday=1）なので、1を引く
        let startIndex = date.weekday - 1
        let lastDay    = date.lastDay

        for (index, dayView) in enumerate(self.dayViewList) {
            let day = index - startIndex + 1

            if day < 1 || day > lastDay {
                dayView.day = nil
            } else {
                dayView.day = day
            }
        }
    }
}


class CalendarDayView: UIButton {
    var day: Int? {
        didSet {
            if let day = self.day {
                self.label.text = "\(day)"
                self.hidden     = false
            } else {
                self.hidden = true
            }
        }
    }

    var label: UILabel!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.label = UILabel(frame: self.frame)
    }

    init (frame: CGRect, weekday: Int) {
        super.init(frame: frame)

        self.hidden = true

        self.label = UILabel(frame: CGRect(origin: CGPoint.zeroPoint, size: frame.size))
        self.label.textAlignment = .Center
        self.label.textColor     = UIColor.colorWithWeekday(weekday)
        
        self.addSubview(self.label)
    }
}