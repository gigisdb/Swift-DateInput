//
//  DateInputView.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorWithWeekday (weekday: Int) -> UIColor {
        switch (weekday) {
        case 0:  return UIColor.redColor()
        case 6:  return UIColor.blueColor()
        default: return UIColor.blackColor()
        }
    }
}

class DayView: UIButton {
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

    private var label: UILabel!

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

public class DateInput: UIScrollView {
    private let dateViewList: [DateView]!
    public var callback: ((year: Int, month: Int, day: Int) -> ())? {
        didSet {
            for dateView in self.dateViewList { dateView.callback = callback }
        }
    }

    public var date: NSDate! {
        didSet {
            for (index, dateView) in enumerate(self.dateViewList) {
                dateView.date  = date
                dateView.month = date.month + index - 1
            }
        }
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        self.dateViewList = [DateView(coder: aDecoder), DateView(coder: aDecoder), DateView(coder: aDecoder)]
        self.contentSize  = self.dateViewList.first!.size * CGSize(width: 1, height: self.dateViewList.count)
        for (index, dateView) in enumerate(self.dateViewList) {
            dateView.frame = CGRectOffset(dateView.frame, 0, dateView.size.height * CGFloat(index))
            self.addSubview(dateView)
        }
    }
}


public class DateView: UIView {
    struct Constants {
        static let width  = 44
        static let height = 44
        static let size   = CGSize(width: width, height: height)
    }
   
    public var size: CGSize {
        get { return Constants.size * CGSize(width: 7, height: 7) }
    }

    public var callback: ((year: Int, month: Int, day: Int) -> ())?
   
    public var year:  Int! {
        didSet {
            self.date = NSDate(year: year, month: self.month, day: self.date.day)
        }
    }

    public var month: Int! {
        didSet {
            self.date = NSDate(year: self.date.year, month: month, day: self.date.day)
        }
    }

    public var date: NSDate! {
        didSet {
            configureView(date)
            self.titleLabel.text = "\(date.year)/\(date.month)"
        }
    }

    let titleLabel: UILabel!
    var dayViewList = [DayView]()

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel = UILabel(frame: CGRect(origin: CGPoint.zeroPoint,
                                                  size: CGSize(width: self.frame.size.width, height: 44)))
        self.addSubview(self.titleLabel)
        self.dayViewList = reduce((1...6), [DayView]()) {$0 + DateView.dayViews($1)}

        for dayView in self.dayViewList {
            dayView.addTarget(self, action: "onTouchDayView:", forControlEvents: .TouchUpInside)
            self.addSubview(dayView)
        }
    }

    class func dayViews (weekOfMonth: Int) -> [DayView] {
        return (0..<7).map { weekday -> DayView in
            let x     = Constants.width  * weekday
            let y     = Constants.height * weekOfMonth
            let frame = CGRect(origin: CGPoint(x: x, y: y), size: Constants.size)

            return DayView(frame: frame, weekday: weekday)
        }
    }

    func onTouchDayView (sender: DayView) {
        if self.callback == nil { return }

        // dayがnilの場合は、押せない（非表示になっている）ので、無条件でdayをunwrapする
        self.callback!(year: self.date.year, month: self.date.month, day: sender.day!)
    }

    func configureView (date: NSDate) {
        // weekdayが1始まり（Sunday=1）なので、1を引く
        let startIndex = NSDate(year: date.year, month: date.month, day: 1).weekday - 1
        let lastDay    = date.lastDay

        for (index, dayView) in enumerate(dayViewList) {
            let day = index - startIndex + 1
            if day < 1 || day > lastDay {
                dayView.day = nil
            } else {
                dayView.day = day
            }
        }
    }
}
