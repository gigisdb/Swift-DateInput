//
//  DateInputView.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

public class DateInput: UIView {

    // MARK: Properties
   
    public var callback: ((selectedDate: NSDate) -> ())?
    
    private let _headerLabel: UILabel!
    private let _calendarView: CalendarView!


    // MARK: Initializers

    required public init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // headerLabel
        _headerLabel = UILabel(frame: _headerLabelFrame)
        self.addSubview(_headerLabel)
        
        // calendarView
        _calendarView = CalendarView(coder: aDecoder)
        _calendarView.frame = _calendarViewFrame
        _calendarView.calendarViewDelegate = self
        self.addSubview(_calendarView)
       
        self.bringSubviewToFront(_headerLabel)
    }


    // MARK: Public

    public func reload (#year: Int, month: Int) {
        _calendarView.reload(year: year, month: month)
    }
}

private extension DateInput {
    var _headerLabelFrame: CGRect {
        return CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: self.frame.width, height: 44))
    }
   
    var _calendarViewFrame: CGRect {
        let headerSize = _headerLabelFrame.size
        return CGRect(origin: CGPoint(x: 0, y: headerSize.height),
                        size: CGSize(width: headerSize.width, height: self.frame.height - headerSize.height))
    }
}

extension DateInput: CalendarViewDelegate {
    func calendarView (calendarView: CalendarView, didSelectDate selectedDate: NSDate) {
        if self.callback == nil { return }

        self.callback!(selectedDate: selectedDate)
    }

    func calendarView (calendarView: CalendarView, didChangeTopTitle topTitle: String) {
        _headerLabel.text = topTitle
    }
}



