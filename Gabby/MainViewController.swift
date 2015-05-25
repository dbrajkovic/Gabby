//
//  ViewController.swift
//  Gabby
//
//  Created by Dan Brajkovic on 4/22/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var messageView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        myButton .setTitle("Post", forState: UIControlState.Normal)
        messageView.text = ""
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = false
    }

    @IBAction func postGab(sender: AnyObject) {
        
        var postsTVC = self.childViewControllers.first as! PostsTableViewController
        if let context = DataManager.sharedManager.managedObjectContext {
            var gab: Gab = NSEntityDescription.insertNewObjectForEntityForName("Gab", inManagedObjectContext: context) as! Gab
            gab.setValue(messageView.text, forKey: "text")
            gab.setValue("dbrajkovic", forKey: "username")
            gab.setValue(NSDate(), forKey: "createdAt")
            DataManager.sharedManager.saveContext()
            
            messageView.text = nil
            messageView.resignFirstResponder()
        }
        
        
    }

}

