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
    var timeSchedule: [Date] = [] //array of all events in the day
    var eventCreateStartTime: Date?
    var eventCreateEndTime: Date?
    
    class scheduleWithIntervalComponents {
        var startOfTimeSlot: Date
        var durationOfTimeSlotMins: Double
        var durationOfTimeSlotHrs: Double
        
        init(startOfTimeSlot: Date, durationOfTimeSlotMins: Double, durationOfTimeSlotHrs: Double) {
            self.startOfTimeSlot = startOfTimeSlot
            self.durationOfTimeSlotMins = durationOfTimeSlotMins
            self.durationOfTimeSlotHrs = durationOfTimeSlotHrs
        }
    }
    
    var scheduleWithIntervalArray: [scheduleWithIntervalComponents] = []
    
    func pullEventInfo() {
        
        //formats date according to entry (will go after date selector is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy HH:mm zzz"
        
        let searchStart = dateFormatter.date(from: "08/25/2017 00:00 GMT")
        let searchEnd = dateFormatter.date(from: "08/26/2017 00:00 GMT")
        
        //new variable to store events
        var pullEventSchedule: [Date] = []
        
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
        
        //adds start of day to Schedule
        if let searchStart = searchStart {
            pullEventSchedule.append(searchStart)
        }
        
        //if the conflict array has members, print the titles of the calendars
        if let conflictArray = conflictArray {
            if conflictArray.count >= 1 {
            for i in 0...(conflictArray.count-1) {
                pullEventSchedule.append(conflictArray[i].startDate)
                pullEventSchedule.append(conflictArray[i].endDate)
                }
            }
        }
        
        //adds end of day to Schedule
        if let searchEnd = searchEnd {
            pullEventSchedule.append(searchEnd)
        }
        
        timeSchedule = pullEventSchedule //writes timeSchedule variable as the one just pulled
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
        
        var scheduleArray: [scheduleWithIntervalComponents] = [] //array for open time slots
        
        if timeSchedule.count >= 1 { //if there is a member in time schedule array
            for i in 0...(timeSchedule.count/2) { //for half of the elements count
                if i % 2 == 0 { //if the count is even (so it is the first entry, third, etc)
        
                    let durationInMinutes = timeSchedule[i+1].timeIntervalSince(timeSchedule[i])/60 //give me timespan between end of first event and start of second event in mins
                    
                    let durationInHours = timeSchedule[i+1].timeIntervalSince(timeSchedule[i])/60/60 //same in hours
                    
                    scheduleArray.append(scheduleWithIntervalComponents(startOfTimeSlot: timeSchedule[i], durationOfTimeSlotMins: durationInMinutes, durationOfTimeSlotHrs: durationInHours))
                    
                    print("start time of time slot is: \(timeSchedule[i])")
                    print("timeslot in minutes: \(durationInMinutes)")
                    print("timeslot in hours: \(durationInHours)")
                    print("end time of time slot is: \(timeSchedule[i+1])")
                }
            }
            
        }
       scheduleWithIntervalArray = scheduleArray
    }
    
    func createEventInOpening() {
        var timePreferenceArray: [scheduleWithIntervalComponents] = [] //array to sort open times with which have most time available
        for i in scheduleWithIntervalArray {
            if i.durationOfTimeSlotMins >= 60.0 {
                timePreferenceArray.append(i)
            }
        }
        let primeTime = timePreferenceArray.sorted(by: {$0.durationOfTimeSlotMins > $1.durationOfTimeSlotMins})
        
        for j in primeTime {
            print (j.durationOfTimeSlotMins)
        }
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
