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
  @IBOutlet weak var categoryButton: UIButton!
  @IBOutlet weak var priceInput: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var descriptionPlaceholder: UILabel!
  
  var priceInputFocused = false
  
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
    }
  }
  
  var dismissCallback: (() -> Void)?

  var mainView: UIView!
  var wrapperScrollView: UIScrollView!
  var tapRecognizer: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    categoryButton.alpha = 0
    cancelButton.alpha = 0
    
    descriptionInput.textContainerInset = UIEdgeInsetsZero
    descriptionInput.tag = 1
    priceInput.tag = 2
    descriptionInput.delegate = self
    priceInput.delegate = self
    
    categoryButton.addTarget(self, action: Selector("onCategoryButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    saveButton.addTarget(self, action: Selector("onSaveButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    cancelButton.addTarget(self, action: Selector("onCancelButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTap:"))
    view.addGestureRecognizer(tapRecognizer)
    
    mainView = view
    mainView.userInteractionEnabled = userInteractionEnabled
    
    automaticallyAdjustsScrollViewInsets = false
    wrapperScrollView = UIScrollView(frame: view.frame)
    wrapperScrollView.addSubview(mainView)
    view = wrapperScrollView
    
    registerForKeyboardNotifications()
  }
  
  override func viewWillAppear(animated: Bool) {
    wrapperScrollView.contentSize = view.bounds.size
    mainView.frame = view.bounds
  }
  
  func showHiddenElementsWithDuration(duration: NSTimeInterval) {
    UIView.animateWithDuration(duration, animations: { () -> Void in
      self.categoryButton.alpha = 1
      self.cancelButton.alpha = 1
    })
  }
  
  func hideHiddenElementsWithDuration(duration: NSTimeInterval) {
    UIView.animateWithDuration(duration, animations: { () -> Void in
      self.categoryButton.alpha = 0
      self.cancelButton.alpha = 0
    })
  }
  
  func registerForKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    let info = notification.userInfo!
    let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue().size
    
    let contentInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0)
    wrapperScrollView.contentInset = contentInsets
  }
  
  func keyboardWillBeHidden(notification: NSNotification) {
    wrapperScrollView.contentInset = UIEdgeInsetsZero
    wrapperScrollView.scrollIndicatorInsets = UIEdgeInsetsZero
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
    let dateComponents = calendar.components(dateFlags, fromDate: NSDate())
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
      
      // Defer so wrapperScrollView.contentInset is set
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.wrapperScrollView.setContentOffset(CGPointMake(0, self.wrapperScrollView.contentInset.bottom), animated: true)
      })
    }
  }
}