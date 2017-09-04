//
//  EventController.swift
//  Final Project
//
//  Created by Aanya Jhaveri on 9/4/17.
//  Copyright © 2017 Aanya Jhaveri. All rights reserved.
//

import UIKit
import EventKit

class EventController: NSObject {
    let eventStore = EKEventStore() //event store access
    var eventPullArray: [EKEvent]? //array of existing events
    var existingCalendarArray: [EKCalendar]? //array of existing calendars
    var eventCreateStartTime: [Date]? //variable to store start times for new events
    var eventCreateEndTime: [Date]? //variable to store end times for new events
    var endOfSchedulingPeriod: Date? //date for end of event pull search AND end of empty time slot search
    
    class TimeSlotSchedule {
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
    
    var scheduleWithIntervalArray: [TimeSlotSchedule] = []
    
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
        
        var scheduleArray: [TimeSlotSchedule] = [] //array for open time slots
        
        if let eventPullArray = eventPullArray {
            if eventPullArray.count >= 1 { //if there is a member in time schedule array
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: NSDate() as Date, endOfTimeSlot: eventPullArray[0].startDate, canSchedule: false ))
                for i in 0...(eventPullArray.count-2) { //for half of the elements count
                    scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: eventPullArray[i].endDate, endOfTimeSlot: eventPullArray[i+1].startDate, canSchedule: false))
                }
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: (eventPullArray.last?.endDate)!, endOfTimeSlot: endOfSchedulingPeriod!, canSchedule: false))
            }
        }
        scheduleWithIntervalArray = scheduleArray
        for i in scheduleWithIntervalArray {
            print (i.startOfTimeSlot)
            print (i.durationOfTimeSlot())
            print (i.endOfTimeSlot)
        }
    }
    
    
    //    func findAllApplicableOpenings() {
    //        for i in scheduleWithIntervalArray {
    //            if i.durationOfTimeSlot() >= 60 {
    //                i.canSchedule = true
    //                }
    //            if i.canSchedule == true {
    //                eventCreateStartTime?.append(i.startOfTimeSlot)
    //            }
    //            }
    //    }


}
