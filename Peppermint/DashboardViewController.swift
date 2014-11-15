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
  
  var addTransactionSection: UIView!
  var addTransactionHeader: UILabel!
  var descriptionButton: UITextView!
  
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
    
    let recentTransactionsSection = loadRecentTransactionsSection()
    wrapperView.addSubview(recentTransactionsSection)
    wrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[recentTransactions]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["recentTransactions": recentTransactionsSection]))
    wrapperView.addConstraint(NSLayoutConstraint(item: recentTransactionsSection, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 100))
    
    addTransactionVC = AddTransactionViewController(nibName: "AddTransactionViewController", bundle: NSBundle.mainBundle())
    let addTransactionNavVC = UINavigationController()
    addTransactionNavVC.navigationBarHidden = true
    addTransactionNavVC.addChildViewController(addTransactionVC)
    addChildViewController(addTransactionNavVC)
    
    addTransactionView = addTransactionNavVC.view
    wrapperView.addSubview(addTransactionView)
    
    addTransactionView.frame = CGRectMake(0, view.bounds.height - 200, view.bounds.width, view.bounds.height)
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
  
  func loadRecentTransactionsSection() -> UIView {
    let recentTransactionsSection = UIView()
    recentTransactionsSection.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let recentTransactionsHeader = UILabel()
    recentTransactionsHeader.text = "RECENT TRANSACTIONS"
    recentTransactionsHeader.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    recentTransactionsHeader.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    recentTransactionsHeader.setTranslatesAutoresizingMaskIntoConstraints(false)
    recentTransactionsSection.addSubview(recentTransactionsHeader)
    
    recentTransactionsSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[header]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["header": recentTransactionsHeader]))
    
    let recentTransactionsTableView = RecentTransactionsTableView(frame: CGRectZero)
    recentTransactionsTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
    recentTransactionsSection.addSubview(recentTransactionsTableView)
    recentTransactionsSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["table": recentTransactionsTableView]))
    recentTransactionsSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[header]-10-[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["header": recentTransactionsHeader, "table": recentTransactionsTableView]))
    
    return recentTransactionsSection
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onAddTransactionTap(sender: UIGestureRecognizer!) {
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      let delta = self.addTransactionView.frame.origin.y
      self.wrapperView.frame.origin.y -= delta
    }) { (finished) -> Void in
      self.addTransactionTapRecognizer.enabled = false
      self.addTransactionSwipeRecognizer.enabled = false
      self.addTransactionVC.userInteractionEnabled = true
    }
  }
  
  func onSwipeUp(sender: UISwipeGestureRecognizer!) {
    onAddTransactionTap(sender)
  }
  
  func closeAddTransactionView() {
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.wrapperView.frame.origin.y = 0
      }) { (finished) -> Void in
        self.addTransactionTapRecognizer.enabled = true
        self.addTransactionSwipeRecognizer.enabled = true
        self.addTransactionVC.userInteractionEnabled = false
    }
  }
}