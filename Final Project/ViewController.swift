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
    
    let eventStore = EKEventStore()
    var calendar: [EKCalendar]?
    var conflict: [EKEvent]?
    
    @IBAction func runCode(_ sender: UIButton) {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy"
        
        let startDay = dateFormatter.date(from: "08/24/2017")
        let endDay = dateFormatter.date(from: "08/25/2017")
        
        //accesses list of calendars in Event Store that contain events and stores them in an array of EKCalendars
        self.calendar = eventStore.calendars(for: EKEntityType.event)
        
        //creates predicate (query) for events within the date range provided
        let conflictPredicate = eventStore.predicateForEvents(withStart: startDay!, end: endDay!, calendars: calendar)
        
        //accesses list of events matching predicate and stores them in an array of EKEvents
        self.conflict = eventStore.events(matching: conflictPredicate)
        
        //if the calendar array has members, print the titles of the calendars
        if let calendar = calendar {
            for i in 0...(calendar.count-1) {
                print (calendar[i].title)
            }
        }
        
        //if the conflict array has members, print the titles of the calendars
        if let conflict = conflict {
            for i in 0...(conflict.count-1) {
                print (conflict[i].title)
                print (conflict[i].startDate)
                print (conflict[i].endDate)
                print ("Next Event")
            }
        }
        
        
    }
    
    @IBAction func newEvent(_ sender: UIButton) {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        let startTime = dateFormatter.date(from: "08/24/2017 23:00")
        let endTime = dateFormatter.date(from: "08/24/2017 23:30")
        
        //accesses list of calendars and stores them as EKCalendar objects in an array
        self.calendar = eventStore.calendars(for: EKEntityType.event)
        
        //defines properties of new event
        let newEvent = EKEvent(eventStore: eventStore)
        if let calendar = calendar {
            newEvent.calendar = calendar[0]
        }
        newEvent.title = "Test Event from xCode"
        newEvent.startDate = startTime!
        newEvent.endDate = endTime!
        
        eventStore.save
        
        //error handling ? of saving a new event
   //     do {
     //       try eventStore.save(newEvent, span: .thisEvent, commit: true)
       //     } catch {
         //       print ("Event did not save")
   //     }
        
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

//issues: - events are being pulled correctly, but are returning in GMT not CDT.
//issues: - events are being saved correctly, but are saving in CDT and not GMT. 
