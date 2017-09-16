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
    let eventController = EventController()

    @IBAction func runCode(_ sender: UIButton) {
        eventController.findTimeAndScheduleEvent(name: "Gym", frequency: 4, duration: 45, span: 3)
        
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



//Conditions that this program works on:
//1-user does not already have conflicting events (MAYBE)
//2-user does not have events that span over midnight (MAYBE)
//3-user does not have all-day events(MAYBE)
//problems 1 & 2 solved by assessing array prior to inputting time slots and converting to suitable array

//next steps is to create an event when the program finds an open slot
//put it in a separate file - sep 9
//try to write a test - sep 9

//MAJOR MAJOR FIX: IT IS SCHEDULING IN EACH TIME SLOT, NOT JUST THE FIRST ONE! - solved
//new problem: it is scheduling one per time slot but we want to be able to schedule 2 within a given time slot - solved


//add to github: enhancement: schedule only once per calendar day (make this an option) / evenly schedule per scheduling period
//enhancement: if scheduling within the same time slot, put a time gap in between
//
