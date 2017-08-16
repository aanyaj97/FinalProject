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
     
        
        let newEvent:EKEvent = EKEvent(eventStore: eventStore)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

            
        newEvent.calendar = eventStore.defaultCalendarForNewEvents
        newEvent.title = "New Event"
        newEvent.startDate = formatter.date(from: "2017/08/16 18:30")!
        newEvent.endDate = formatter.date(from: "2017/08/16 19:30")!
    
        do {
            try eventStore.save(newEvent, span: .thisEvent)
        } catch let error as NSError {
            print("event did not save: \(error)")
            
        }
        print("Saved Event")
        
        
        
        print(newEvent.title)
        print(newEvent.startDate)
        print(newEvent.endDate)
        
        
            
            
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
