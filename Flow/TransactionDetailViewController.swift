//
//  TransactionDetailViewController.swift
//  Flow
//
//  Created by Paul Shen on 11/18/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse
import UIKit

class TransactionDetailViewController: UIViewController {
  @IBOutlet weak var descriptionPlaceholder: UILabel!
  @IBOutlet weak var descriptionInput: UITextView!
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var priceInput: UITextField!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var dateInput: UITextFieldCursorless!
  
  var datePicker = UIDatePicker()
  var dateFormatter = NSDateFormatter()
  
  var transaction: PFObject!
  var category: PFObject? {
    didSet {
      if let category = category {
        categoryButton.setTitle((category["name"] as String), forState: UIControlState.Normal)
      } else {
        categoryButton.setTitle("Category", forState: UIControlState.Normal)
      }
    }
  }
  
  var mainView: UIView!
  var wrapperScrollView: UIScrollView!
  
  convenience init(transaction: PFObject) {
    self.init(nibName: "TransactionDetailViewController", bundle: NSBundle.mainBundle())
    self.transaction = transaction
  }
  
  override func viewDidLoad() {
    descriptionPlaceholder.hidden = true
    descriptionInput.textContainerInset = UIEdgeInsetsZero
    descriptionInput.tag = 1
    descriptionInput.delegate = self
    descriptionInput.text = transaction["description"] as String
    priceInput.tag = 2
    priceInput.text = NSString(format: "$%.2f", transaction["amount"] as Double)
    initializeDateInput()
    
    if let tempCategory = transaction["category"] as? PFObject {
      tempCategory.fetchIfNeededInBackgroundWithBlock({ (category, error) -> Void in
        self.category = category
      })
    }
    
//    categoryButton.addTarget(self, action: Selector("onCategoryButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    editButton.contentEdgeInsets = UIEdgeInsetsMake(12, 0, 12, 0)
    editButton.layer.borderColor = UIColor.blackColor().CGColor
    editButton.layer.borderWidth = 2
    editButton.addTarget(self, action: Selector("onEditButtonPressed:"), forControlEvents: .TouchUpInside)
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTap:"))
    view.addGestureRecognizer(tapRecognizer)
    
    mainView = view
    automaticallyAdjustsScrollViewInsets = false
    wrapperScrollView = UIScrollView(frame: view.frame)
    wrapperScrollView.alwaysBounceVertical = true
    wrapperScrollView.delegate = self
    wrapperScrollView.addSubview(mainView)
    
    let views = ["mainView": mainView]
    wrapperScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[mainView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    wrapperScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[mainView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    wrapperScrollView.addConstraint(NSLayoutConstraint(item: mainView, attribute: .Width, relatedBy: .Equal, toItem: wrapperScrollView, attribute: .Width, multiplier: 1.0, constant: 0))
    view = wrapperScrollView
    
    userInteractionEnabled = false
  }
  
  func initializeDateInput() {
    datePicker.datePickerMode = UIDatePickerMode.Date
    datePicker.date = transaction["date"] as NSDate
    datePicker.addTarget(self, action: Selector("onDateInputChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    dateFormatter.dateFormat = "MM/dd/yyyy"
    dateInput.text = dateFormatter.stringFromDate(datePicker.date)
    dateInput.inputView = datePicker
    let dateInputToolbar = UIToolbar()
    dateInputToolbar.items = [
      UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
      UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("onDateInputDonePressed:"))]
    dateInputToolbar.sizeToFit()
    dateInput.inputAccessoryView = dateInputToolbar
  }
  
  override func viewWillAppear(animated: Bool) {
    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
  }
  
  override func viewWillDisappear(animated: Bool) {
    UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
  }
  
  func onEditButtonPressed(button: UIButton!) {
    isEditing = true
  }
  
  var isEditing: Bool = false {
    didSet {
      userInteractionEnabled = isEditing
      
      if isEditing {
        editButton.setTitle("SAVE", forState: .Normal)
      } else {
        editButton.setTitle("EDIT", forState: .Normal)
      }
    }
  }
  
  var userInteractionEnabled: Bool = true {
    didSet {
      descriptionInput.userInteractionEnabled = userInteractionEnabled
      categoryButton.userInteractionEnabled = userInteractionEnabled
      dateInput.userInteractionEnabled = userInteractionEnabled
      priceInput.userInteractionEnabled = userInteractionEnabled
    }
  }
  
  func onTap(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  func onDateInputChanged(sender: UIDatePicker!) {
    dateInput.text = dateFormatter.stringFromDate(datePicker.date)
  }
  
  func onDateInputDonePressed(sender: UIBarButtonItem!) {
    dateInput.resignFirstResponder()
  }
}

extension TransactionDetailViewController: UITextViewDelegate, UITextFieldDelegate {
  func textViewDidChange(textView: UITextView) {
    descriptionPlaceholder.hidden = textView.text != ""
  }
  
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

extension TransactionDetailViewController: UIScrollViewDelegate {
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView.contentOffset.y < -50 {
      presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
  }
}