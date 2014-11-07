//
//  ViewController.swift
//  DateInput
//
//  Created by 石田純一 on 10/5/14.
//  Copyright (c) 2014 Junichi Ishida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var dateInput: DateInput!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dateInput.reload(year: NSDate().year, month: NSDate().month)
        self.dateInput.callback = { year, month, day in println("DAY: \(year)-\(month)-\(day)") }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

