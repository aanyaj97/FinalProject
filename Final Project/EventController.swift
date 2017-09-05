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
    var eventArray: [EKEvent]? //array of existing events
    var existingCalendarArray: [EKCalendar]? //array of existing calendars
    var eventCreateStartTime: [Date]? //array to store start times for new events
    var eventCreateEndTime: [Date]? //array to store end times for new events
    var endOfSchedulingPeriod: Date? //date for end of event pull search AND end of empty time slot search
    let calendar = Calendar.current
    
    class TimeSlotSchedule {
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
    
    var scheduleWithIntervalArray: [TimeSlotSchedule] = []
    
    func pullEventInfo() { //pulls all existing calendar events
        
        //formats date according to entry (this will be deleted after date spinner UIComponent is implemented)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyy HH:mm zzz"
        
        let searchStart = NSDate() as Date //retrieves current time
        let daysToAdd = 7 //variable to store days to add to start time
        let searchEnd = calendar.date(byAdding: .day, value: daysToAdd, to: searchStart)
        //retrieves current time + requested time schedule period (will be user input but is currently one week)
        
        endOfSchedulingPeriod = searchEnd //assigns the end of the period to schedule in as the end of the period to search events for
        
        print (searchStart)
        if let searchEnd = searchEnd {
            print (searchEnd)
        }
        
        //accesses list of calendars in Event Store that contain events and stores them in an array of EKCalendars
        self.existingCalendarArray = eventStore.calendars(for: EKEntityType.event)
        
        //creates predicate (query) for events within the date range provided
        let eventPullPredicate = eventStore.predicateForEvents(withStart: searchStart, end: searchEnd!, calendars: existingCalendarArray)
        
        //accesses list of events from Event Store matching predicate and stores them in an array of EKEvents
        //sorts list of pulled events by start date
        let eventPullArray = eventStore.events(matching: eventPullPredicate).sorted{
            (ev1: EKEvent, ev2: EKEvent) -> Bool in
            return ev1.startDate.compare(ev2.startDate) == ComparisonResult.orderedAscending
        }
        
        if eventPullArray.count >= 1 {
            self.eventArray = eventPullArray
        } else {
            self.eventArray = []
        }
    }
    
    func createEvent(startTime: Date, duration: Int) { //create a new event given a start and end time
        let newEvent = EKEvent(eventStore: eventStore)
        if let existingCalendarArray = existingCalendarArray {
            if existingCalendarArray.count >= 1 {
                newEvent.calendar = existingCalendarArray[0]
            }
        }
        
        newEvent.title = "Test Event"
        newEvent.startDate = startTime
        let durationTime = duration
        let endTime = calendar.date(byAdding: .minute, value: durationTime, to: startTime)
        if let endTime = endTime {
        newEvent.endDate = endTime
        }
        
        do { //tries to save event, in case of an error it prints the error
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
        } catch let err as NSError {
            print (err.description)
        }
    }
    
    func findAllOpenings() {
        
        var scheduleArray: [TimeSlotSchedule] = [] //array for open time slots
        
        if let eventArray = eventArray {
            if eventArray.count >= 1 { //if there is a member in existing event array
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: NSDate() as Date, endOfTimeSlot: eventArray[0].startDate)) //find time difference between search time and start of first event
                for i in 0...(eventArray.count-2) { //for each event in the array except last one, pull the end time and assign to it to the opening of a time slot and pull the start time of the next event and assign it to the end of that time slot. This will therefore create an array with each member having a start time, end time, and duration in which new events can be scheduled.
                    scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: eventArray[i].endDate, endOfTimeSlot: eventArray[i+1].startDate))
                } //at the end, calculate the time difference between the end of the last event and the end of the scheduling period.
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: (eventArray.last?.endDate)!, endOfTimeSlot: endOfSchedulingPeriod!))
            } else { //if there are no events, make the schedulable time cover all time from the search start until the search end
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: NSDate() as Date, endOfTimeSlot: endOfSchedulingPeriod!))
            }
        }
        scheduleWithIntervalArray = scheduleArray //now this array has all of the schedulable slots
    }
    
    func createNewEventInOpening() {
    var timeSlotFound = false
        while timeSlotFound == false {
            for i in scheduleWithIntervalArray {
                if i.durationOfTimeSlot() >= 60 {
                    timeSlotFound = true
                    createEvent(startTime: i.startOfTimeSlot, duration: 60)
                }
            }
        }
    }
    
}
