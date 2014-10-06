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

@IBDesignable public class DateInput: UIScrollView {
    struct Constants {
        static let width  = 44
        static let height = 44
    }

    var date: NSDate! {
        didSet {
            configureView(date)
        }
    }
   
    var dayTextList = [[UILabel]]()
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        func labels (weekOfMonth: Int) -> [UILabel] {
            return (0..<7).map { weekday -> UILabel in
                let x = Constants.width  * weekday
                let y = Constants.height * weekOfMonth
                let frame = CGRect(x: x, y: y, width: Constants.width, height: Constants.height)
               
                let label = UILabel(frame: frame)
                label.textAlignment = .Center
                label.textColor     = UIColor.colorWithWeekday(weekday)

                self.addSubview(label)
                
                return label
            }
        }

        self.dayTextList = (0..<6).map(labels)
    }

    func configureView (date: NSDate) {
        var row = 0
        eachDay(date, block: { year, month, day, weekday in
            self.dayTextList[row][weekday].text = "\(day)"

            if (weekday == 6) { row++ }
        })
    }

    private func eachDay (date: NSDate, block: (year: Int, month: Int, day: Int, weekday: Int) -> Void) {
        let year    = date.year
        let month   = date.month
        let lastDay = date.lastDay
        let weekday = date.weekday

        for day in 1..<lastDay {
            block(year: year, month: month, day: day, weekday: (weekday + day - 1) % 7)
        }
    }
}