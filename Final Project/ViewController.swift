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
    var eventPullArray: [EKEvent]? //array of existing events
    var existingCalendarArray: [EKCalendar]? //array of existing calendars
    var eventCreateStartTime: Date?
    var eventCreateEndTime: Date?
    var endOfSchedulingPeriod: Date?
    
    class timeSlotSchedule {
        var startOfTimeSlot: Date
        var endOfTimeSlot: Date
        
        func durationOfTimeSlot() -> Double {
            return endOfTimeSlot.timeIntervalSince(startOfTimeSlot) //returns duration of time slot
        }
        
        init(startOfTimeSlot: Date, endOfTimeSlot: Date) {
            self.startOfTimeSlot = startOfTimeSlot
            self.endOfTimeSlot = endOfTimeSlot
        }
    }
    
    var scheduleWithIntervalArray: [timeSlotSchedule] = []
    
    func pullEventInfo() {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy HH:mm zzz"
        
        let searchStart = NSDate() as Date
        let searchEnd = dateFormatter.date(from: "08/26/2017 00:00 GMT")
        
        endOfSchedulingPeriod = searchEnd //assigns the end of the period to schedule in as the end of the period to search events for
        
        //accesses list of calendars in Event Store that contain events and stores them in an array of EKCalendars
        self.existingCalendarArray = eventStore.calendars(for: EKEntityType.event)
        
        
        //creates predicate (query) for events within the date range provided
        let eventPullPredicate = eventStore.predicateForEvents(withStart: searchStart, end: searchEnd!, calendars: existingCalendarArray)
        
        //accesses list of events matching predicate and stores them in an array of EKEvents
        //sorts list of pulled events by start date
        self.eventPullArray = eventStore.events(matching: eventPullPredicate).sorted{
            (ev1: EKEvent, ev2: EKEvent) -> Bool in
            return ev1.startDate.compare(ev2.startDate) == ComparisonResult.orderedAscending
        }
    }
    
//    func createNewEvent() {
//        
//        //formats date according to entry (will go after date selector is implemented)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm zzz"
//        
//        let startTime = dateFormatter.date(from: "08/25/2017 00:30 GMT")
//        let endTime = dateFormatter.date(from: "08/25/2017 01:30 GMT")
//        
//        //accesses list of calendars and stores them as EKCalendar objects in an array
//        self.calendarsForEvents = eventStore.calendars(for: EKEntityType.event)
//        
//        //defines properties of new event
//        let newEvent = EKEvent(eventStore: eventStore)
//        if let calendarsForEvents = calendarsForEvents {
//            newEvent.calendar = calendarsForEvents[0]
//        }
//        newEvent.title = "Test Event from xCode"
//        newEvent.startDate = startTime!
//        newEvent.endDate = endTime!
//        
//        //error handling: tries to save event, in case of error, it will print error
//        do {
//            try eventStore.save(newEvent, span: .thisEvent, commit: true)
//        } catch let err as NSError {
//            print (err.description)
//        }
//    }
    
    func findOpenings() {
        
        var scheduleArray: [timeSlotSchedule] = [] //array for open time slots
        
        if let eventPullArray = eventPullArray {
        if eventPullArray.count >= 1 { //if there is a member in time schedule array
            scheduleArray.append(timeSlotSchedule(startOfTimeSlot: NSDate() as Date, endOfTimeSlot: eventPullArray[0].startDate))
            for i in 0...(eventPullArray.count-2) { //for half of the elements count
                scheduleArray.append(timeSlotSchedule(startOfTimeSlot: eventPullArray[i].endDate, endOfTimeSlot: eventPullArray[i+1].startDate))
                }
            scheduleArray.append(timeSlotSchedule(startOfTimeSlot: (eventPullArray.last?.endDate)!, endOfTimeSlot: endOfSchedulingPeriod!))
            }
        }
       scheduleWithIntervalArray = scheduleArray
        print (scheduleWithIntervalArray[0].startOfTimeSlot)
        print (scheduleWithIntervalArray[0].durationOfTimeSlot())
        print (scheduleWithIntervalArray[0].endOfTimeSlot)
    }
    
    
    func createEventInOpening() {
    }


    @IBAction func runCode(_ sender: UIButton) {
        pullEventInfo()
        findOpenings()
        createEventInOpening()
    }
    
    @IBAction func newEvent(_ sender: UIButton) {
        //createNewEvent()
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
//reverse engineer that to find empty slots ?? - DONE
//FIRST: find time around one event on a given day
//SECOND: find time around two events on a given day
//THIRD: find time in between two events on a given day


//MAJOR PROBLEM: ARRAY IS NOT REFRESHED AFTER BUTTON PRESS - DONE
//Conditions that this program works on:
//1-user does not already have conflicting events (MAYBE)
//2-user does not have events that span over midnight (MAYBE)
//3-user does not have all-day events(MAYBE)
