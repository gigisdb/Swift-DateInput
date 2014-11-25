//
//  CalendarView.swift
//  DateInput
//
//  Created by 石田純一 on 11/10/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

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
            for monthView in _monthViewList { monthView.callback = callback }
        }
    }

    private let _monthViewList: [CalendarMonthView]!
    private var _year: Int!
    private var _month: Int!
    private var _topTitle: String?


    // MARK: Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.clipsToBounds = true

        _monthViewList = (0..<4).map { _ -> CalendarMonthView in return CalendarMonthView(coder: aDecoder) }

        for monthView in _monthViewList { monthView.callback = self.onTouchUpDayView }

        for (index, monthView) in enumerate(_monthViewList) {
            monthView.frame = monthView.frame.rectByOffsetting(dx: 0, dy: CGFloat(44 * Weekday.Count * index))
            
            self.addSubview(monthView)
        }

        self.contentSize = _monthViewList.first!.frame.rectByUnion(_monthViewList.last!.frame).size
    }

    
    // MARK: Internal

    func reload (#year: Int, month: Int) {
        _year  = year
        _month = month

        for (index, monthView) in enumerate(_monthViewList) {
            monthView.update(year: year, month: month + index - 1)
        }
    }

    override func layoutSubviews() {
        let contentOffsetY = self.contentOffset.y
        let topView = _monthViewList.filter { ($0.frame.minY...$0.frame.maxY ~= contentOffsetY) }.first

        let newTopTitle = topView?.title ?? _topTitle

        if newTopTitle != _topTitle {
            _topTitle = newTopTitle
            self.calendarViewDelegate?.calendarView(self, didChangeTopTitle: _topTitle!)
        }

        if self.contentOffset.y < 0 {
            dispatch_async(dispatch_get_main_queue()) {
                self.prev()
                self.contentOffset.y += self._monthViewList[1].frame.origin.y
            }
        } else if self.contentOffset.y > _monthViewList[2].frame.origin.y {
            dispatch_async(dispatch_get_main_queue()) {
                self.next()
                self.contentOffset.y = self._monthViewList[1].frame.origin.y
            }
        }
    }

    func onTouchUpDayView (year: Int, month: Int, day: Int) {
        let selectedDate = NSDate(year: year, month: month, day: day)

        self.calendarViewDelegate?.calendarView(self, didSelectDate: selectedDate)
    }
   
   
    // MARK: Private

    private func prev() {
        self.reload(year: _year, month: _month - 1)
    }

    private func next() {
        self.reload(year: _year, month: _month + 1)
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
        return "\(_calendarMonth.year)/\(_calendarMonth.month)"
    }

    private var _calendarMonth: CalendarMonth! {
        didSet {
            configureView(_calendarMonth)

            _titleLabel.text = self.title
        }
    }
   
    private let _titleLabel: UILabel!
    private let _dayViewList = reduce((0..<6), [CalendarDayView]()) { $0 + CalendarMonthView.createDayViews($1) }


    // MARK: Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        _titleLabel = UILabel(frame: _titleLabelFrame)
        self.addSubview(_titleLabel)

        let dayViewContainer = UIView(frame: _dayViewContainerFrame)
        self.addSubview(dayViewContainer)

        for dayView in _dayViewList {
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

    func update (#year: Int, month: Int) {
        _calendarMonth = CalendarMonth(year: year, month: month)
    }

    func onTouchDayView (sender: CalendarDayView) {
        if self.callback == nil { return }

        // dayがnilの場合は、押せない（非表示になっている）ので、無条件でdayをunwrapする
        self.callback!(year: _calendarMonth.year, month: _calendarMonth.month, day: sender.day!)
    }

   
    // MARK: Private

    private func configureView (calendarMonth: CalendarMonth) {
        // weekdayが1始まり（Sunday=1）なので、1を引く
        let startIndex = _calendarMonth.firstWeekday.rawValue - 1
        let lastDay    = _calendarMonth.lastDay

        for (index, dayView) in enumerate(_dayViewList) {
            let day = index - startIndex + 1

            if day < 1 || day > lastDay {
                dayView.day = nil
            }
            else {
                dayView.day = day
            }
        }
        
        let heightCount = _calendarMonth.numWeekOfMonth + 1
        self.frame = CGRect(origin: self.frame.origin,
                              size: Constants.size * CGSize(width: Weekday.Count, height: heightCount))
    }
}

private extension CalendarMonthView {
    var _titleLabelFrame: CGRect {
        return CGRect(origin: CGPoint.zeroPoint, 
                        size: CGSize(width: self.frame.width, height: 44))
    }
   
    var _dayViewContainerFrame: CGRect {
        let titleLabelSize = _titleLabelFrame.size

        return CGRect(origin: CGPoint(x: 0, y: titleLabelSize.height), 
                        size: Constants.size * CGSize(width: Weekday.Count, height: 6))
    }
}


class CalendarDayView: UIButton {

    // MARK: Properties

    var day: Int? {
        didSet {
            if let day = self.day {
                _label.text = "\(day)"
                self.hidden = false
            }
            else {
                self.hidden = true
            }
        }
    }

    private var _label: UILabel!


    // MARK: Initializers

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        _label = UILabel(frame: self.frame)
    }

    private init (frame: CGRect, weekday: Weekday) {
        super.init(frame: frame)

        self.hidden = true

        _label = UILabel(frame: CGRect(origin: CGPoint.zeroPoint, size: frame.size))
        _label.textAlignment = .Center
        _label.textColor     = UIColor.colorWithWeekday(weekday)

        self.setBackgroundImage(UIImage(named: "calendar-day-background"), forState: .Normal)
        
        self.addSubview(_label)
    }
}
