//
//  DateInputView.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

public class DateInput: UIView, CalendarViewDelegate {

    // MARK: Properties
   
    public var callback: ((selectedDate: NSDate) -> ())?
    
    private let headerLabel: UILabel!
    private let calendarView: CalendarView!


    // MARK: Initializers

    required public init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // headerLabel
        self.headerLabel = UILabel(frame: self.headerLabelFrame)
        self.addSubview(self.headerLabel)
        
        // calendarView
        self.calendarView = CalendarView(coder: aDecoder)
        self.calendarView.frame = self.calendarViewFrame
        self.calendarView.calendarViewDelegate = self
        self.addSubview(self.calendarView)
       
        self.bringSubviewToFront(self.headerLabel)
    }


    // MARK: Public

    public func reload (#year: Int, month: Int) {
        self.calendarView.reload(year: year, month: month)
    }

    
    // MARK: Internal
   
    func calendarView (calendarView: CalendarView, didSelectDate selectedDate: NSDate) {
        if self.callback == nil { return }
   
        self.callback!(selectedDate: selectedDate)
    }
   
    func calendarView (calendarView: CalendarView, didChangeTopTitle topTitle: String) {
        self.headerLabel.text = topTitle
    }
}

extension DateInput {
    var headerLabelFrame: CGRect {
        return CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: self.frame.width, height: 44))
    }
   
    var calendarViewFrame: CGRect {
        let headerSize = self.headerLabelFrame.size
        return CGRect(origin: CGPoint(x: 0, y: headerSize.height),
                        size: CGSize(width: headerSize.width, height: self.frame.height - headerSize.height))
    }
}



