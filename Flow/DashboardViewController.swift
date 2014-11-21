//
//  DashboardViewController.swift
//  Flow
//
//  Created by Paul Shen on 11/10/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse
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
    wrapperView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: wrapperView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
    
    let analyticsView = loadAnalyticsView()
    analyticsView.setTranslatesAutoresizingMaskIntoConstraints(false)
    wrapperView.addSubview(analyticsView)
    wrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[analytics]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["analytics": analyticsView]))
    
    recentTransactionVC = RecentTransactionsViewController(inMiniMode: true)
    addChildViewController(recentTransactionVC)
    let recentTransactionsSection = recentTransactionVC.view
    wrapperView.addSubview(recentTransactionsSection)
    wrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[recentTransactions]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["recentTransactions": recentTransactionsSection]))
    recentTransactionVC.didMoveToParentViewController(self)
    
    wrapperView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[logo(20)]-20-[analytics]-20-[recent]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["logo": imageView, "analytics": analyticsView, "recent": recentTransactionsSection]))
    
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
  
  func loadAnalyticsView() -> UIView {
    let analyticsView = UIView()
    let totalSpendLabel = UILabel()
    
    totalSpendLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 84)
    totalSpendLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    totalSpendLabel.text = "$0"
    PFCloud.callFunctionInBackground("dashboarddata", withParameters: [:]) { (results, error) -> Void in
      let results = results as [String: AnyObject]
      let sortedYears = Array(results.keys).sorted({ (a, b) -> Bool in
        return a.toInt() < b.toInt()
      })
      for year in sortedYears {
        let monthData = results[year] as [String: NSNumber]
        let sortedMonths = Array(monthData.keys).sorted({ (a, b) -> Bool in
          return a.toInt() < b.toInt()
        })
        for month in sortedMonths {
          if let amount: NSNumber = monthData[month] {
            totalSpendLabel.text = String(format: "$%d", Int(amount))
          }
        }
      }
    }
    
    totalSpendLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    analyticsView.addSubview(totalSpendLabel)
    analyticsView.addConstraint(NSLayoutConstraint(item: totalSpendLabel, attribute: .CenterX, relatedBy: .Equal, toItem: analyticsView, attribute: .CenterX, multiplier: 1.0, constant: 0))
    analyticsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[spend]-30-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["spend": totalSpendLabel]))
    return analyticsView
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
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if isShowingAddTransaction && scrollView.contentOffset.y < addTransactionView.frame.origin.y - 50 {
      // Need async or the scroll view will snap to wrong position
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.closeAddTransactionView()
      })
    }
  }
}