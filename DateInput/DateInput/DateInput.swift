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

public class DateInput: UIScrollView, UIScrollViewDelegate {
    private let dateViewList: [DateView]!

    public var callback: ((year: Int, month: Int, day: Int) -> ())? {
        didSet {
            for dateView in self.dateViewList { dateView.callback = callback }
        }
    }

    private var year: Int!
    private var month: Int!

    public func reload (#year: Int, month: Int, direction: Int = 0) {
        self.year  = year
        self.month = month

        for (index, dateView) in enumerate(self.dateViewList) {
            dateView.date = NSDate(year: year, month: month + index - 1, day: 1)
        }
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
        self.dateViewList = (0..<4).map { _ -> DateView in return DateView(coder: aDecoder) }
        self.contentSize  = DateView.size * CGSize(width: 1, height: self.dateViewList.count)

        for (index, dateView) in enumerate(self.dateViewList) {
            dateView.frame = CGRectOffset(dateView.frame, 0, DateView.size.height * CGFloat(index))
            self.addSubview(dateView)
        }
    }

    func prev() {
        self.reload(year: self.year, month: self.month - 1)
    }

    func next() {
        self.reload(year: self.year, month: self.month + 1)
    }

    public override func layoutSubviews() {
        if self.contentOffset.y < 0 {
            self.prev()
            self.contentOffset.y = self.dateViewList[1].frame.origin.y
        } else if self.contentOffset.y > self.dateViewList[2].frame.origin.y {
            self.next()
            self.contentOffset.y = self.dateViewList[1].frame.origin.y
        }
    }
}


public class DateView: UIView {
    struct Constants {
        static let width  = 44
        static let height = 44
        static let size   = CGSize(width: width, height: height)
    }
   
    public class var size: CGSize {
        get { return Constants.size * CGSize(width: 7, height: 7) }
    }

    public var callback: ((year: Int, month: Int, day: Int) -> ())?

    public var date: NSDate! {
        didSet {
            configureView(date)

            let (year, month, _, _) = date.components
            self.titleLabel.text = "\(year)/\(month)"
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
