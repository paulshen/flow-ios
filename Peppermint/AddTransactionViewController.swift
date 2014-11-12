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
  var tapRecognizer: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    descriptionInput.textContainer.lineFragmentPadding = 0
    descriptionInput.textContainerInset = UIEdgeInsetsZero
    descriptionInput.tag = 1
    priceInput.tag = 2
    descriptionInput.delegate = self
    priceInput.delegate = self
    
    saveButton.addTarget(self, action: Selector("onSaveButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.addTarget(self, action: Selector("onCancelButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("onSwipeDown:"))
    swipeDownRecognizer.direction = .Down
    view.addGestureRecognizer(swipeDownRecognizer)
    
    tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTap:"))
    view.addGestureRecognizer(tapRecognizer)
  }
  
  func onSwipeDown(sender: UISwipeGestureRecognizer) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func onTap(sender: UITapGestureRecognizer) {
    view.endEditing(true)
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

extension AddTransactionViewController: UITextViewDelegate, UITextFieldDelegate {
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if NSString(string: text).rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet()).location == NSNotFound {
      return true
    }
    
    let nextTag = textView.tag + 1
    let nextResponder = textView.superview?.viewWithTag(nextTag)
    if let nextResponder = nextResponder {
      nextResponder.becomeFirstResponder()
    } else {
      textView.resignFirstResponder()
    }
    return false
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let nextTag = textField.tag + 1
    let nextResponder = textField.superview?.viewWithTag(nextTag)
    if let nextResponder = nextResponder {
      nextResponder.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    return false
  }
}