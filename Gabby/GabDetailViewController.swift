//
//  GabDetailViewController.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/13/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

class GabDetailViewController: UIViewController {
    
    var gab : Gab?

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Gab Detail"
    }
    
    override func viewWillAppear(animated: Bool) {
        textLabel.text = gab?.text
    }
    @IBAction func doSomething(sender: AnyObject) {
    }
}
