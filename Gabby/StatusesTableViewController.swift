//
//  StatusesTableViewController.swift
//  Gabby
//
//  Created by Dan Brajkovic on 5/31/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

class StatusesTableViewController: UITableViewController {
    
    @IBInspectable var resource : String = "/statuses/home_timeline"
    
    var statuses: NSMutableArray = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let nib = UINib(nibName: "StatusTableViewCell", bundle: NSBundle.mainBundle())
        self.tableView.registerNib(nib, forCellReuseIdentifier: "StatusCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey("oauthToken") == nil || defaults.stringForKey("oauthTokenSecret") == nil {
            self.tabBarController!.performSegueWithIdentifier("SignInWithTwitterSegue", sender: nil);
        } else {
            let request = TwitterRESTClient.getRequest(resource, parameters: nil)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse!, responseData: NSData!, error: NSError!) in
                var JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers, error: nil)
                if let timeline: NSMutableArray = JSONObject as? NSMutableArray {
                    self.statuses = timeline
                    self.tableView.reloadData()
                }
            }
        }        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatusCell", forIndexPath: indexPath) as! StatusTableViewCell
        if let status = statuses[indexPath.row] as? NSDictionary {
            if let statusText = status["text"] as? String {
                cell.statusLabel.text = statusText
            }
            if let user = status["user"] as? NSDictionary {
                let name = user["name"] as! String
                cell.nameLabel.text = name
                let imageURLString = user["profile_image_url_https"] as! String
                let imageURL = NSURL(string: imageURLString)
                let imageData = NSData(contentsOfURL: imageURL!)
                let profileImage = UIImage(data: imageData!)
                cell.avatarView.image = profileImage
            }
            
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
