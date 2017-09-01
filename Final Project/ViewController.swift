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
    
    let eventStore = EKEventStore() //event store access
    var eventPullArray: [EKEvent]? //array of existing events
    var existingCalendarArray: [EKCalendar]? //array of existing calendars
    var eventCreateStartTime: [Date]? //variable to store start times for new events
    var eventCreateEndTime: [Date]? //variable to store end times for new events
    var endOfSchedulingPeriod: Date? //date for end of event pull search AND end of empty time slot search
    
    class timeSlotSchedule {
        var startOfTimeSlot: Date
        var endOfTimeSlot: Date
        var canSchedule: Bool
        
        func durationOfTimeSlot() -> Double {
            return endOfTimeSlot.timeIntervalSince(startOfTimeSlot) //returns duration of time slot
        }
        
        init(startOfTimeSlot: Date, endOfTimeSlot: Date, canSchedule: Bool) {
            self.startOfTimeSlot = startOfTimeSlot
            self.endOfTimeSlot = endOfTimeSlot
            self.canSchedule = canSchedule
        }
    }
    
    var scheduleWithIntervalArray: [timeSlotSchedule] = []
    
    func pullEventInfo() {
        
        //formats date according to entry (this will be deleted after date spinner UIComponent is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy HH:mm zzz"
        
        let searchStart = NSDate() as Date //retrieves current time
        let searchEnd = dateFormatter.date(from: "09/1/2017 00:00 GMT") //retrieves current time + requested time schedule period (user input)
        
        endOfSchedulingPeriod = searchEnd //assigns the end of the period to schedule in as the end of the period to search events for
        
        //accesses list of calendars in Event Store that contain events and stores them in an array of EKCalendars
        self.existingCalendarArray = eventStore.calendars(for: EKEntityType.event)
        
        //creates predicate (query) for events within the date range provided
        let eventPullPredicate = eventStore.predicateForEvents(withStart: searchStart, end: searchEnd!, calendars: existingCalendarArray)
        
        //accesses list of events from Event Store matching predicate and stores them in an array of EKEvents
        //sorts list of pulled events by start date
        self.eventPullArray = eventStore.events(matching: eventPullPredicate).sorted{
            (ev1: EKEvent, ev2: EKEvent) -> Bool in
            return ev1.startDate.compare(ev2.startDate) == ComparisonResult.orderedAscending
        }
    }
    
    func createNewEvent() {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm zzz"
        
        let startTime = eventCreateStartTime
        let endTime = eventCreateEndTime
        
        //defines properties of new event
        let newEvent = EKEvent(eventStore: eventStore)
        if let existingCalendarArray = existingCalendarArray {
            if existingCalendarArray.count >= 1 {
            newEvent.calendar = existingCalendarArray[0]
            }
        }
        newEvent.title = "Test Event from xCode"
        if let startTime = startTime {
            if let endTime = endTime {
                newEvent.startDate = startTime[0]
                newEvent.endDate = endTime[0]
            }
        }
        
        //error handling: tries to save event, in case of error, it will print error
        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
        } catch let err as NSError {
            print (err.description)
        }
    }
    
    func findOpenings() {
        
        var scheduleArray: [timeSlotSchedule] = [] //array for open time slots
        
        if let eventPullArray = eventPullArray {
        if eventPullArray.count >= 1 { //if there is a member in time schedule array
            scheduleArray.append(timeSlotSchedule(startOfTimeSlot: NSDate() as Date, endOfTimeSlot: eventPullArray[0].startDate, canSchedule: false ))
            for i in 0...(eventPullArray.count-2) { //for half of the elements count
                scheduleArray.append(timeSlotSchedule(startOfTimeSlot: eventPullArray[i].endDate, endOfTimeSlot: eventPullArray[i+1].startDate, canSchedule: false))
                }
            scheduleArray.append(timeSlotSchedule(startOfTimeSlot: (eventPullArray.last?.endDate)!, endOfTimeSlot: endOfSchedulingPeriod!, canSchedule: false))
            }
        }
       scheduleWithIntervalArray = scheduleArray
        for i in scheduleWithIntervalArray {
        print (i.startOfTimeSlot)
        print (i.durationOfTimeSlot())
        print (i.endOfTimeSlot)
        }
    }
    
    
    func findAllApplicableOpenings() {
        for i in scheduleWithIntervalArray {
            if i.durationOfTimeSlot() >= 60 {
                i.canSchedule = true
                }
            if i.canSchedule == true {
                eventCreateStartTime?.append(i.startOfTimeSlot)
            }
            }
    }


    @IBAction func runCode(_ sender: UIButton) {
        pullEventInfo()
        findOpenings()
        findAllApplicableOpenings()
        
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

//MAJOR TO DO: Figure out how to adjust time according to difference i.e. make end time 1 hour after start time! 


//MAJOR PROBLEM: ARRAY IS NOT REFRESHED AFTER BUTTON PRESS - DONE
//Conditions that this program works on:
//1-user does not already have conflicting events (MAYBE)
//2-user does not have events that span over midnight (MAYBE)
//3-user does not have all-day events(MAYBE)
//problems 1 & 2 solved by assessing array prior to inputting time slots and converting to suitable array

//next steps is to create an event when the program finds an open slot
