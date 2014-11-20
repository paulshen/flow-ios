//
//  DashboardViewController.swift
//  Flow
//
//  Created by Paul Shen on 11/10/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController {
  var wrapperView: UIView!
  var wrapperScrollView: UIScrollView!
  
  var recentTransactionVC: RecentTransactionsViewController!
  
  var addTransactionVC: AddTransactionViewController!
  var addTransactionView: UIView!
  var addTransactionTapRecognizer: UITapGestureRecognizer!
  var addTransactionSwipeRecognizer: UISwipeGestureRecognizer!
  
  var isShowingAddTransaction = false
  
  override func loadView() {
    super.loadView()
    
    wrapperView = UIView(frame: view.bounds)
    wrapperView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
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
    
    addTransactionVC = AddTransactionViewController()
    addChildViewController(addTransactionVC)
    addTransactionView = addTransactionVC.view
    addTransactionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    wrapperView.addSubview(addTransactionView)
    
    wrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[addTransaction]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["addTransaction": addTransactionView]))
    wrapperView.addConstraint(NSLayoutConstraint(item: addTransactionView, attribute: .Top, relatedBy: .Equal, toItem: wrapperView, attribute: .Top, multiplier: 1.0, constant: view.bounds.height - 180))
    wrapperView.addConstraint(NSLayoutConstraint(item: addTransactionView, attribute: .Bottom, relatedBy: .Equal, toItem: wrapperView, attribute: .Bottom, multiplier: 1.0, constant: 0))
    
    addTransactionVC.didMoveToParentViewController(self)
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
    
    wrapperScrollView = UIScrollView(frame: view.frame)
    wrapperScrollView.addSubview(wrapperView)
    wrapperScrollView.scrollEnabled = false
    wrapperScrollView.alwaysBounceVertical = true
    wrapperScrollView.delegate = self
    automaticallyAdjustsScrollViewInsets = false
    
    wrapperScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[main]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["main": wrapperView]))
    wrapperScrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[main]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["main": wrapperView]))
    
    view.addSubview(wrapperScrollView)
    view.addConstraint(NSLayoutConstraint(item: wrapperView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1.0, constant: 0))
    view.addConstraint(NSLayoutConstraint(item: addTransactionView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: view, attribute: .Height, multiplier: 1.0, constant: 0))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func onAddTransactionTap(sender: UIGestureRecognizer!) {
    addTransactionVC.transitionToFullViewWithDuration(0.5)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.wrapperScrollView.contentOffset.y = self.addTransactionView.frame.origin.y
    }) { (finished) -> Void in
      self.wrapperScrollView.contentInset.top = -self.addTransactionView.frame.origin.y
      self.wrapperScrollView.scrollEnabled = true
      
      self.addTransactionTapRecognizer.enabled = false
      self.addTransactionSwipeRecognizer.enabled = false
      self.addTransactionVC.userInteractionEnabled = true
      
      self.isShowingAddTransaction = true
    }
  }
  
  func onSwipeUp(sender: UISwipeGestureRecognizer!) {
    onAddTransactionTap(sender)
  }
  
  func closeAddTransactionView() {
    view.endEditing(true)
    wrapperScrollView.contentInset.top = 0
    addTransactionVC.transitionToPeekViewWithDuration(0.5)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.wrapperScrollView.contentOffset.y = 0
      }) { (finished) -> Void in
        self.wrapperScrollView.scrollEnabled = false
        
        self.addTransactionTapRecognizer.enabled = true
        self.addTransactionSwipeRecognizer.enabled = true
        self.addTransactionVC.userInteractionEnabled = false
        
        self.isShowingAddTransaction = false
    }
  }
}

extension DashboardViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if isShowingAddTransaction && scrollView.contentOffset.y < addTransactionView.frame.origin.y - 50 {
      closeAddTransactionView()
    }
  }
}