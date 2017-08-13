//
//  ViewController.swift
//  Final Project
//
//  Created by Aanya Jhaveri on 8/13/17.
//  Copyright © 2017 Aanya Jhaveri. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    
    @IBAction  internal func buttonTapped(sender: UIButton)
    {
     print("hello")
    let eventStore = EKEventStore()
     
        if let calendarForEvent = eventStore.calendar(withIdentifier: "Calendar") {
            
            let newEvent = EKEvent(eventStore: eventStore)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"

            
            newEvent.calendar = calendarForEvent
            newEvent.title = "New Event"
            newEvent.startDate = formatter.date(from: "2017/08/14 18:30")!
            newEvent.endDate = formatter.date(from: "2017/08/14 19:30")!
    
            print(newEvent.title)
            print(newEvent.startDate)
            print(newEvent.endDate)
        
            
            
    }
    
    
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//find out how to GET calendars! 
