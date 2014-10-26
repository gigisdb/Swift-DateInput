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
    struct Constants {
        static let width  = 44
        static let height = 44
        static let size   = CGSize(width: width, height: height)
    }

    public var callback: ((year: Int, month: Int, day: Int) -> ())?

    var date: NSDate! {
        didSet {
            configureView(date)
        }
    }
   
    var dayViewList = [[DayView]]()
    var flatDayViewList: [DayView] {
        return dayViewList.reduce([DayView](), combine: +)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        func dayViews (weekOfMonth: Int) -> [DayView] {
            return (0..<7).map { weekday -> DayView in
                let x     = Constants.width  * weekday
                let y     = Constants.height * weekOfMonth
                let frame = CGRect(origin: CGPoint(x: x, y: y), size: Constants.size)
               
                let dayView = DayView(frame: frame, weekday: weekday)
                dayView.addTarget(self, action: "onTouchDayView:", forControlEvents: .TouchUpInside)

                self.addSubview(dayView)
                
                return dayView
            }
        }

        self.dayViewList = (0..<6).map(dayViews)
    }

    func onTouchDayView (sender: DayView) {
        if self.callback == nil { return }

        // dayがnilの場合は、押せない（非表示になっている）ので、無条件でdayをunwrapする
        self.callback!(year: self.date.year, month: self.date.month, day: sender.day!)
    }

    func configureView (date: NSDate) {
        var row = 0
        eachDay(date, block: { year, month, day, weekday in
            self.dayViewList[row][weekday].day = day

            if (weekday == 6) { row++ }
        })
    }

    private func eachDay (date: NSDate, block: (year: Int, month: Int, day: Int, weekday: Int) -> ()) {
        let year    = date.year
        let month   = date.month
        let lastDay = date.lastDay
        let weekday = date.weekday

        for day in 1..<lastDay {
            block(year: year, month: month, day: day, weekday: (weekday + day - 1) % 7)
        }
    }
}
