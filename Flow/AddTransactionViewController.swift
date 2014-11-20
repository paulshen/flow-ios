//
//  AddTransactionViewController.swift
//  Flow
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
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var priceInput: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var descriptionPlaceholder: UILabel!
  @IBOutlet weak var dateInput: UITextField!
  
  var kbSize: CGSize!
  var priceInputFocused = false
  var datePicker = UIDatePicker()
  var dateFormatter = NSDateFormatter()
  
  var category: PFObject? {
    didSet {
      if let category = category {
        categoryButton.setTitle((category["name"] as String), forState: UIControlState.Normal)
      } else {
        categoryButton.setTitle("Category", forState: UIControlState.Normal)
      }
    }
  }
  
  var userInteractionEnabled: Bool = true {
    didSet {
      mainView?.userInteractionEnabled = userInteractionEnabled
      descriptionInput?.userInteractionEnabled = userInteractionEnabled
      dateInput?.userInteractionEnabled = userInteractionEnabled
    }
  }
  
  var dismissCallback: (() -> Void)?

  var mainView: UIView!
  
  override init() {
    super.init(nibName: "AddTransactionViewController", bundle: NSBundle.mainBundle())
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    categoryButton.alpha = 0
    cancelButton.alpha = 0
    
    initializeDateInput()
    
    descriptionInput.textContainerInset = UIEdgeInsetsZero
    descriptionInput.tag = 1
    priceInput.tag = 2
    descriptionInput.delegate = self
    priceInput.delegate = self
    
    categoryButton.addTarget(self, action: Selector("onCategoryButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    saveButton.addTarget(self, action: Selector("onSaveButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.addTarget(self, action: Selector("onCancelButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    saveButton.contentEdgeInsets = UIEdgeInsetsMake(12, 0, 12, 0)
    saveButton.layer.borderColor = UIColor.whiteColor().CGColor
    saveButton.layer.borderWidth = 2
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTap:"))
    view.addGestureRecognizer(tapRecognizer)
    view.userInteractionEnabled = userInteractionEnabled
    
    registerForKeyboardNotifications()
  }
  
  func initializeDateInput() {
    datePicker.datePickerMode = UIDatePickerMode.Date
    datePicker.date = NSDate()
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
  
  func transitionToFullViewWithDuration(duration: NSTimeInterval) {
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((duration - 0.25) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      self.descriptionInput.becomeFirstResponder()
      return
    }
    UIView.animateWithDuration(duration, animations: { () -> Void in
      self.categoryButton.alpha = 1
      self.cancelButton.alpha = 1
    })
  }
  
  func transitionToPeekViewWithDuration(duration: NSTimeInterval) {
    descriptionInput.text = ""
    descriptionPlaceholder.hidden = false
    
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    UIView.animateWithDuration(duration, animations: { () -> Void in
      self.categoryButton.alpha = 0
      self.cancelButton.alpha = 0
      }, completion: { (finished) in
        self.category = nil
        self.priceInput.text = "$0.00"
        self.datePicker.date = NSDate()
        self.dateInput.text = self.dateFormatter.stringFromDate(self.datePicker.date)
    })
  }
  
  func registerForKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    let info = notification.userInfo!
    kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
  }
  
  func keyboardWillBeHidden(notification: NSNotification) {
  }
  
  func onTap(sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  func onCategoryButtonPressed(sender: UIButton!) {
    let categoryVC = SelectCategoryViewController(categoryChangeCallback: {
      (category: PFObject) in
      self.category = category
      self.navigationController?.popViewControllerAnimated(true)
    })
    navigationController?.pushViewController(categoryVC, animated: true)
  }
  
  func onSaveButtonPressed(sender: UIButton!) {
    let transaction = PFObject(className: "Transaction")
    transaction["description"] = descriptionInput.text
    transaction["amount"] = NSString(string: priceInput.text.stringByReplacingOccurrencesOfString("$", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)).doubleValue
    let dateFlags = NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit
    let calendar = NSCalendar.currentCalendar()
    let dateComponents = calendar.components(dateFlags, fromDate: datePicker.date)
    dateComponents.timeZone = NSTimeZone(abbreviation: "UTC")
    transaction["date"] = calendar.dateFromComponents(dateComponents)
    if let category = category {
      transaction["category"] = PFObject(withoutDataWithClassName: "Category", objectId: category.objectId)
    }
    transaction.saveInBackgroundWithBlock {
      (success: Bool, error: NSError!) -> Void in
      Transactions.sharedInstance.reloadData()
      self.dismissCallback?()
      return
    }
  }
  
  func onCancelButtonPressed(sender: UIButton!) {
    dismissCallback?()
  }
  
  func onDateInputChanged(sender: UIDatePicker!) {
    dateInput.text = dateFormatter.stringFromDate(datePicker.date)
  }
  
  func onDateInputDonePressed(sender: UIBarButtonItem!) {
    dateInput.resignFirstResponder()
  }
}

extension AddTransactionViewController: UITextViewDelegate, UITextFieldDelegate {
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
  
  func textFieldDidBeginEditing(textField: UITextField) {
    if textField == priceInput {
      if !priceInputFocused {
        priceInput.text = "$"
        priceInputFocused = true
      }
    }
  }
}

class UITextFieldCursorless: UITextField {
  override func caretRectForPosition(position: UITextPosition!) -> CGRect {
    return CGRectZero
  }
  
  override func editingRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectInset(bounds, 0, 0.5)
  }
}