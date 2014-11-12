//
//  AddTransactionViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/12/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse
import UIKit

class AddTransactionViewController: UIViewController {
  
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var descriptionInput: UITextView!
  @IBOutlet weak var priceInput: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!

  var swipeDownRecognizer: UISwipeGestureRecognizer!
  
  override func viewDidLoad() {
    descriptionInput.textContainer.lineFragmentPadding = 0
    descriptionInput.textContainerInset = UIEdgeInsetsZero
    
    saveButton.addTarget(self, action: Selector("onSaveButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.addTarget(self, action: Selector("onCancelButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "onSwipeDown:")
    swipeDownRecognizer.direction = .Down
    view.addGestureRecognizer(swipeDownRecognizer)
  }
  
  func onSwipeDown(sender: UISwipeGestureRecognizer) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func onSaveButtonPressed(sender: UIButton!) {
    let transaction = PFObject(className: "Transaction")
    transaction["description"] = descriptionInput.text
    transaction["amount"] = NSString(string: priceInput.text).doubleValue
    transaction.saveInBackgroundWithBlock {
      (success: Bool, error: NSError!) -> Void in
      self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
      return
    }
  }
  
  func onCancelButtonPressed(sender: UIButton!) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}