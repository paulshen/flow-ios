//
//  NewTransactionViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/6/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import UIKit

class NewTransactionViewController: UIViewController {
  var swipeDownRecognizer: UISwipeGestureRecognizer!
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = UIColor.blueColor()
    let labelView = UILabel(frame: CGRectMake(30.0, 30.0, 200.0, 100.0))
    labelView.text = "Hello"
    view.addSubview(labelView)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "onSwipeDown:")
    swipeDownRecognizer.direction = .Down
    view.addGestureRecognizer(swipeDownRecognizer)
  }
  
  func onSwipeDown(sender: UISwipeGestureRecognizer) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}