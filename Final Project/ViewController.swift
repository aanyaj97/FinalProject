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
    

    @IBAction func runCode(_ sender: UIButton) {
        
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
//put it in a separate file - sep 9
//try to write a test - sep 9
