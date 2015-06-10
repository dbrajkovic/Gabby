//
//  ComposeTweetViewController.swift
//  Gabby
//
//  Created by Dan Brajkovic on 6/3/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBAction func showImagePicker(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alertController = UIAlertController(title: "Choose your source", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cameraAction = UIAlertAction(title: "Use Camera", style: UIAlertActionStyle.Default) { (action : UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        let libraryAction = UIAlertAction(title: "Use Library", style: UIAlertActionStyle.Default) { (action : UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self .presentViewController(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(libraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action : UIAlertAction!) -> Void in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.imageView.image = image
        self .dismissViewControllerAnimated(true, completion: nil)
    }
}
