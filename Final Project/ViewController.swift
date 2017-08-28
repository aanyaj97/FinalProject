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
    
    let eventStore = EKEventStore() //event store
    var conflictArray: [EKEvent]? //array of events
    var existingCalendarArray: [EKCalendar]? //array of existing calendars
    var calendarsForEvents: [EKCalendar]? //also array of existing calendars (can this be removed?)
    var timeSchedule: [Date] = []
    
    func pullEventInfo() {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy"
        
        let searchStart = dateFormatter.date(from: "08/24/2017")
        let searchEnd = dateFormatter.date(from: "08/25/2017")
        
        //accesses list of calendars in Event Store that contain events and stores them in an array of EKCalendars
        self.existingCalendarArray = eventStore.calendars(for: EKEntityType.event)
        
        
        //creates predicate (query) for events within the date range provided
        let eventPullPredicate = eventStore.predicateForEvents(withStart: searchStart!, end: searchEnd!, calendars: existingCalendarArray)
        
        //accesses list of events matching predicate and stores them in an array of EKEvents
        //sorts list of pulled events by start date
        self.conflictArray = eventStore.events(matching: eventPullPredicate).sorted{
            (ev1: EKEvent, ev2: EKEvent) -> Bool in
            return ev1.startDate.compare(ev2.startDate) == ComparisonResult.orderedAscending
        }
        
        //if the conflict array has members, print the titles of the calendars
        if let conflictArray = conflictArray {
            for i in 0...(conflictArray.count-1) {
                timeSchedule.append(conflictArray[i].startDate)
                timeSchedule.append(conflictArray[i].endDate)
            }
        }
        print (timeSchedule)
    }
    
    func createNewEvent() {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm zzz"
        
        let startTime = dateFormatter.date(from: "08/25/2017 00:30 GMT")
        let endTime = dateFormatter.date(from: "08/25/2017 01:30 GMT")
        
        //accesses list of calendars and stores them as EKCalendar objects in an array
        self.calendarsForEvents = eventStore.calendars(for: EKEntityType.event)
        
        //defines properties of new event
        let newEvent = EKEvent(eventStore: eventStore)
        if let calendarsForEvents = calendarsForEvents {
            newEvent.calendar = calendarsForEvents[0]
        }
        newEvent.title = "Test Event from xCode"
        newEvent.startDate = startTime!
        newEvent.endDate = endTime!
        
        //error handling: tries to save event, in case of error, it will print error
        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
        } catch let err as NSError {
            print (err.description)
        }
    }
    
    func findIfConflict() {
        for i in 1...timeSchedule.count-2 {
            if timeSchedule[i-1] > timeSchedule[i] {
                print ("out of order")
            }
        }
        
    }
    
    func findTime() {
        let dateFormatter = DateFormatter()
        //let dateComponents = NSDateComponents()
        //let hour = dateComponents.hour
        dateFormatter.dateFormat = "MM/dd/yyy zzz"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        
        
    }
    
    
    
    @IBAction func runCode(_ sender: UIButton) {
        pullEventInfo()
        findIfConflict()
    }
    
    @IBAction func newEvent(_ sender: UIButton) {
        createNewEvent()
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

//to do: find how to compare members of the array to see if they are all in order! DONE
//reverse engineer that to find empty slots ??: 
//FIRST: find time around one event on a given day
//SECOND: find time around two events on a given day
//THIRD: find time in between two events on a given day
