//
//  DateInputView.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

public class DateInput: UIView, CalendarViewDelegate {
    private let headerLabel: UILabel!
    private let body: CalendarView!
   
    public var callback: ((selectedDate: NSDate) -> ())?

    required public init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.headerLabel = UILabel(frame: CGRect(origin: CGPoint.zeroPoint, 
                                                   size: CGSize(width: self.frame.width, height: 44)))
        self.addSubview(self.headerLabel)
        
        self.body = CalendarView(coder: aDecoder)
        self.body.frame = CGRect(origin: CGPoint(x: 0, y: 44),
                                   size: CGSize(width: self.frame.width, height: self.frame.height - 44))
        self.body.calendarViewDelegate = self
        self.addSubview(self.body)
       
        self.bringSubviewToFront(self.headerLabel)
    }

    public func reload (#year: Int, month: Int) {
        self.body.reload(year: year, month: month)
    }
   
    func calendarView (calendarView: CalendarView, didSelectDate selectedDate: NSDate) {
        if callback == nil { return }

        self.callback!(selectedDate: selectedDate)
    }
   
    func calendarView (calendarView: CalendarView, didChangeTopTitle topTitle: String) {
        self.headerLabel.text = topTitle
    }
}



