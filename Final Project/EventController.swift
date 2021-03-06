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
    //below are unchanging inputs from user's device/system
    let eventStore = EKEventStore() //event store access
    let calendar = Calendar.current //user's calendar preference (Gregorian,etc)
    
    //below are variables that need to be passed between functions
    var eventArray: [EKEvent]? //array of existing events
    var existingCalendarArray: [EKCalendar]? //array of existing calendars
    var eventCreateStartTime: [Date]? //array to store start times for new events
    var eventCreateEndTime: [Date]? //array to store end times for new events
    var startOfSchedulingPeriod: Date? //date for start of event pull search AND start of empty time slot search
    var endOfSchedulingPeriod: Date? //date for end of event pull search AND end of empty time slot search
    var scheduleWithIntervalArray: [TimeSlotSchedule] = []
    var scheduledEventCount = 0
    
   
    //this class stores data which contains information on empty timeslots in the user's schedule
    class TimeSlotSchedule {
        var startOfTimeSlot: Date //start of time slot opening
        var endOfTimeSlot: Date //end of time slot opening
        
        func durationOfTimeSlot() -> Int {
            return Int(endOfTimeSlot.timeIntervalSince(startOfTimeSlot))/60 //returns duration of time slot
        } //calculates duration of time slot opening in minutes
        
        init(startOfTimeSlot: Date, endOfTimeSlot: Date) {
            self.startOfTimeSlot = startOfTimeSlot
            self.endOfTimeSlot = endOfTimeSlot
        }
    }
    
    func roundDate(date: Date) -> Date { //rounds date to next quarter of the hour
        let currentDate = date
        
        //calculates time until the next quarter hour minus one minute (as seconds will add to next minute)
        let minuteComponent = calendar.component(.minute, from: currentDate)
        let timeDifferenceToNextQuarterHour = 14 - (minuteComponent % 15)
        
        //calculates time until the next minute
        let secondComponent = calendar.component(.second, from: currentDate)
        let timeDifferenceToStartOfMinute = 60 - secondComponent
        
        //rounds current time to the next quarter hour by adding minutes and seconds until then
        let roundedMinuteDate = calendar.date(byAdding: .minute, value: timeDifferenceToNextQuarterHour, to: currentDate)!
        let roundedDate = calendar.date(byAdding: .second, value: timeDifferenceToStartOfMinute, to: roundedMinuteDate)!
        
        return roundedDate
    
    }

    
    func pullEventInfo(span: Int) { //pulls all existing calendar events, inputs span as the number of dates to reschedule over
        
        let dateTime = NSDate() as Date //current date and time
        
        let searchStart = roundDate(date: dateTime) //rounds current time to 15 minutes from now as this is the earliest new events will be scheduled for conveience's sake
        
        let daysToAdd = span //variable to store days to add to start time
        
        let searchEnd = calendar.date(byAdding: .day, value: daysToAdd, to: searchStart)
        //retrieves current time + requested time schedule period (will be user input but is currently one week)
        
        startOfSchedulingPeriod = searchStart //assigns the start of the period to schedule in as the start of the period to search events for
        
        endOfSchedulingPeriod = searchEnd //assigns the end of the period to schedule in as the end of the period to search events for
        
        
        self.existingCalendarArray = eventStore.calendars(for: EKEntityType.event) //accesses list of calendars in Event Store that contain events and stores them in an array of EKCalendars
        
        
        let eventPullPredicate = eventStore.predicateForEvents(withStart: searchStart, end: searchEnd!, calendars: existingCalendarArray) //creates predicate (query) for events within the date range provided
        
        let eventPullArray = eventStore.events(matching: eventPullPredicate).sorted{
            (ev1: EKEvent, ev2: EKEvent) -> Bool in
            return ev1.startDate.compare(ev2.startDate) == ComparisonResult.orderedAscending
        
        //accesses list of events from Event Store matching predicate and stores them in an array of EKEvents
        //sorts list of pulled events by start date
        }
        
        if eventPullArray.count >= 1 {
            self.eventArray = eventPullArray
        } else {
            self.eventArray = []
        } //if there are events, fill the eventArray with them. Otherwise, assign the eventArray to an empty array

        if eventArray!.count > 1 {
            for i in 0...eventArray!.count-1 {
                print ("Event \(i) is called \(eventArray![i].title) and it starts at \(eventArray![i].startDate) and ends at \(eventArray![i].endDate)")
            }
        }
    }
    
    func findAllOpenings(duration: Int) {
        
        var scheduleArray: [TimeSlotSchedule] = [] //array for open time slots
        var scheduleFilteredArray: [TimeSlotSchedule] = [] //array for open time slots given set duration
        
        if let eventArray = eventArray {
            if eventArray.count >= 1 { //if there are 1 or more members in existing event array
                
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: startOfSchedulingPeriod!, endOfTimeSlot: eventArray[0].startDate)) //find time difference between search time and start of first event
                
                if eventArray.count >= 2 { //if there are 2 or more events, we want the differences between each of those as well
                
                for i in 0...(eventArray.count-2) {
                    
                    scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: eventArray[i].endDate, endOfTimeSlot: eventArray[i+1].startDate))
                } //for each event in the array except last one, pull the end time and assign to it to the opening of a time slot and pull the start time of the next event and assign it to the end of that time slot. This will therefore create an array with each member having a start time, end time, and duration in which new events can be scheduled.
                
                }
                
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: (eventArray.last?.endDate)!, endOfTimeSlot: endOfSchedulingPeriod!)) //at the end, calculate the time difference between the end of the last event and the end of the scheduling period.
                
            } else { //if there are no events, make the schedulable time cover all time from the search start until the search end
                scheduleArray.append(TimeSlotSchedule(startOfTimeSlot: startOfSchedulingPeriod!, endOfTimeSlot: endOfSchedulingPeriod!))
            }
        }
        
        for i in scheduleArray { //search the schedule interval array
            if i.durationOfTimeSlot() >= duration { //if a timeslot is long enough
        scheduleFilteredArray.append(i) //append it to this array
            }
        }
        
        scheduleWithIntervalArray = scheduleFilteredArray
        
        print ("Schedule Array, unfiltered:")
        
        for i in 0...scheduleArray.count-1 {
            print ("Event Slot #\(i) starts at \(scheduleArray[i].startOfTimeSlot) and lasts \(scheduleArray[i].durationOfTimeSlot())") //this is correct
        }
        

        print ("Schedule Array, timeslots too short removed:")
        
        for i in 0...scheduleWithIntervalArray.count-1 {
            print ("Event Slot #\(i) starts at \(scheduleWithIntervalArray[i].startOfTimeSlot) and lasts \(scheduleWithIntervalArray[i].durationOfTimeSlot())") //there is an issue here - solved! it was because the schedulewithinterval array was not refreshing each while loop
        }
    }
    
    func createEvent(name: String, startTime: Date, duration: Int) { //create a new event given a start and end time and name
        let newEvent = EKEvent(eventStore: eventStore)
        if let existingCalendarArray = existingCalendarArray {
            if existingCalendarArray.count >= 1 {
                newEvent.calendar = existingCalendarArray[0]
            }
        }
        
        newEvent.title = name //assign title of event to name input
        newEvent.startDate = startTime //assign start date of event to start time input
        
        let durationTime = duration //assign duration of event to duration input
        let endTime = calendar.date(byAdding: .minute, value: durationTime, to: startTime) //calculate end time given start time and duration
        
        if let endTime = endTime {
            newEvent.endDate = endTime
        } //assign end date of event to end date calculated
        
        do { //tries to save event, in case of an error it prints the error in console
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
        } catch let err as NSError {
            let errorDescription = err.description
            print (errorDescription)
        }
    }
    
    func selectRandomTimeSlot() -> Int {
        let randomIndex = Int(arc4random_uniform(UInt32(scheduleWithIntervalArray.count)))
        return randomIndex
    }
    
    func createNewEventInOpening(name: String, duration: Int) {
        var scheduled = false //variable to see if an event is scheduled
        while scheduled == false {
            let randomSlot = selectRandomTimeSlot()
            let scheduleStart = scheduleWithIntervalArray[randomSlot].startOfTimeSlot
            createEvent(name: name, startTime: scheduleStart, duration: duration)
                scheduledEventCount += 1 //add to the event counter
                scheduled = true //make it true so that no more events are scheduled from this search
                print (" Slot num:\(randomSlot) and event scheduled starting at \(scheduleStart) with title \(name) ")
        }
        }
    
    func findTimeAndScheduleEvent(name: String, frequency: Int, duration: Int, span: Int) {
       scheduledEventCount = 0 // no events are scheduled
       while scheduledEventCount < frequency { //while the number of events are less than the number desired
            pullEventInfo(span: span) //pulls event info for the given number of days
            findAllOpenings(duration: duration)//finds all openings in the event pull
            createNewEventInOpening(name: name, duration: duration)  //creates a new event in a random opening
       }
        }
}


