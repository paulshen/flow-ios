//
//  DashboardViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/10/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController {
  var wrapperView: UIView!
  
  var recentTransactionVC: RecentTransactionsViewController!
  
  var addTransactionVC: AddTransactionViewController!
  var addTransactionView: UIView!
  var addTransactionTapRecognizer: UITapGestureRecognizer!
  var addTransactionSwipeRecognizer: UISwipeGestureRecognizer!
  
  override func loadView() {
    super.loadView()
    
    wrapperView = UIView(frame: view.bounds)
    
    let image = UIImage(named: "logo")
    let imageView = UIImageView(image: image)
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    wrapperView.backgroundColor = UIColor.whiteColor()
    wrapperView.addSubview(imageView)
    
    wrapperView.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: wrapperView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: wrapperView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 30),
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20.0)
      ])
    
    recentTransactionVC = RecentTransactionsViewController(inMiniMode: true)
    addChildViewController(recentTransactionVC)
    let recentTransactionsSection = recentTransactionVC.view
    wrapperView.addSubview(recentTransactionsSection)
    wrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[recentTransactions]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["recentTransactions": recentTransactionsSection]))
    wrapperView.addConstraint(NSLayoutConstraint(item: recentTransactionsSection, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 200))
    recentTransactionVC.didMoveToParentViewController(self)
    
    addTransactionVC = AddTransactionViewController(nibName: "AddTransactionViewController", bundle: NSBundle.mainBundle())
    let addTransactionNavVC = UINavigationController()
    addTransactionNavVC.navigationBarHidden = true
    addTransactionNavVC.addChildViewController(addTransactionVC)
    addChildViewController(addTransactionNavVC)
    
    addTransactionView = addTransactionNavVC.view
    wrapperView.addSubview(addTransactionView)
    
    addTransactionView.frame = CGRectMake(0, view.bounds.height - 180, view.bounds.width, view.bounds.height)
    addTransactionView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
    addTransactionNavVC.didMoveToParentViewController(self)
    addTransactionVC.userInteractionEnabled = false
    
    addTransactionVC.dismissCallback = {
      [unowned self] in
      self.closeAddTransactionView()
    };
    
    addTransactionTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onAddTransactionTap:"))
    addTransactionView.addGestureRecognizer(addTransactionTapRecognizer)
    
    addTransactionSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("onSwipeUp:"))
    addTransactionSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Up
    wrapperView.addGestureRecognizer(addTransactionSwipeRecognizer)
    
    wrapperView.frame.size.height = CGRectGetMaxY(addTransactionView.frame)
    view.addSubview(wrapperView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onAddTransactionTap(sender: UIGestureRecognizer!) {
    addTransactionVC.showHiddenElementsWithDuration(0.5)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      let delta = self.addTransactionView.frame.origin.y
      self.wrapperView.frame.origin.y -= delta
    }) { (finished) -> Void in
      self.addTransactionTapRecognizer.enabled = false
      self.addTransactionSwipeRecognizer.enabled = false
      self.addTransactionVC.userInteractionEnabled = true
      
      self.addTransactionVC.descriptionInput.becomeFirstResponder()
    }
  }
  
  func onSwipeUp(sender: UISwipeGestureRecognizer!) {
    onAddTransactionTap(sender)
  }
  
  func closeAddTransactionView() {
    view.endEditing(true)
    addTransactionVC.hideHiddenElementsWithDuration(0.5)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.wrapperView.frame.origin.y = 0
      }) { (finished) -> Void in
        self.addTransactionTapRecognizer.enabled = true
        self.addTransactionSwipeRecognizer.enabled = true
        self.addTransactionVC.userInteractionEnabled = false
    }
  }
}