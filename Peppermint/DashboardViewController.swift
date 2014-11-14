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
  var addTransactionHeader: UILabel!
  
  override func loadView() {
    super.loadView()
    
    let image = UIImage(named: "logo")
    let imageView = UIImageView(image: image)
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(imageView)
    
    view.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 30),
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20.0)
      ])
    
    let recentTransactionsSection = loadRecentTransactionsSection()
    view.addSubview(recentTransactionsSection)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[recentTransactions]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["recentTransactions": recentTransactionsSection]))
    view.addConstraint(NSLayoutConstraint(item: recentTransactionsSection, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1.0, constant: 100))
    
    let addTransactionSection = loadAddTransactionSection()
    view.addSubview(addTransactionSection)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[addTransaction]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["addTransaction": addTransactionSection]))
    view.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: addTransactionSection, attribute: .Bottom, multiplier: 1.0, constant: 20))
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
  
  func loadAddTransactionSection() -> UIView {
    let addTransactionSection = UIView()
    addTransactionSection.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    addTransactionHeader = UILabel()
    addTransactionHeader.text = "ADD TRANSACTION"
    addTransactionHeader.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    addTransactionHeader.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    addTransactionHeader.setTranslatesAutoresizingMaskIntoConstraints(false)
    addTransactionSection.addSubview(addTransactionHeader)
    
    let buttonLabel = UILabel()
    buttonLabel.text = "+"
    buttonLabel.textColor = UIColor.whiteColor()
    buttonLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 120.0)
    buttonLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let addButton = UIControl()
    addButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    addButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    addButton.addSubview(buttonLabel)
    
    addButton.addConstraints([
      NSLayoutConstraint(item: buttonLabel, attribute: .CenterX, relatedBy: .Equal, toItem: addButton, attribute: .CenterX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: buttonLabel, attribute: .CenterY, relatedBy: .Equal, toItem: addButton, attribute: .CenterY, multiplier: 1.0, constant: 0)
      ])
    
    addTransactionSection.addSubview(addButton)
    addTransactionSection.userInteractionEnabled = true
    
    let addTransactionViews = [
      "button": addButton,
      "header": addTransactionHeader
    ]
    addTransactionSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[button]|", options: NSLayoutFormatOptions(0), metrics: nil, views: addTransactionViews))
    addTransactionSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[header]|", options: NSLayoutFormatOptions(0), metrics: nil, views: addTransactionViews))
    addTransactionSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[header]-10-[button(140)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: addTransactionViews))
    
    addButton.addTarget(self, action: "addButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    
    return addTransactionSection
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func addButtonTapped(sender: UIControl!) {
    let navigationVC = UINavigationController()
    let addVC = AddTransactionViewController(nibName: "AddTransactionViewController", bundle: NSBundle.mainBundle())
    
    navigationVC.navigationBarHidden = true
    navigationVC.viewControllers = [addVC]
    navigationVC.transitioningDelegate = self
    addVC.automaticallyAdjustsScrollViewInsets = false
    navigationController?.presentViewController(navigationVC, animated: true, completion: nil)
  }
}

extension DashboardViewController: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return Animator()
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return DismissAnimator()
  }
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let container = transitionContext.containerView()
    let fromVC = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as UINavigationController).viewControllers[0] as DashboardViewController
    let fromView = fromVC.view
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as UINavigationController
    let toAddVC = toVC.viewControllers[0] as AddTransactionViewController
    let toView = toVC.view
    
    container.backgroundColor = UIColor.whiteColor()
    toView.alpha = 0
    container.addSubview(fromView)
    container.addSubview(toView)
    
    let headerLabel = fromVC.addTransactionHeader
    let headerClone = headerLabel.snapshotViewAfterScreenUpdates(false)
    headerLabel.alpha = 0
    headerClone.frame.origin = headerLabel.convertPoint(CGPointZero, toView: nil)
    let headerTarget = toAddVC.headerLabel.convertPoint(CGPointZero, toView: nil)
    
    container.addSubview(headerClone)
    
    let duration = transitionDuration(transitionContext)
    
    UIView.animateWithDuration(duration / 3.0, animations: {
      fromView.alpha = 0
      }
    )
    
    UIView.animateWithDuration(duration / 2.0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      headerClone.frame.origin = headerTarget
      }, completion: { (finished) in
      }
    )
    
    UIView.animateWithDuration(duration / 2.0, delay: duration / 2.0, options: UIViewAnimationOptions(0), animations: {
      toView.alpha = 1
      }, completion: { (finished) in
        fromView.alpha = 1
        headerLabel.alpha = 1
        headerClone.removeFromSuperview()
        toAddVC.descriptionInput.becomeFirstResponder()
        transitionContext.completeTransition(true)
      }
    )
  }
}

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let container = transitionContext.containerView()
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as UINavigationController
    let fromView = fromVC.view
    let fromAddVC = fromVC.viewControllers[0] as AddTransactionViewController
    let toVC = (transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as UINavigationController).viewControllers[0] as DashboardViewController
    let toView = toVC.view
    
    fromView.endEditing(true)
    container.backgroundColor = UIColor.whiteColor()
    toView.alpha = 0
    container.addSubview(fromView)
    container.addSubview(toView)
    
    let headerLabel = fromAddVC.headerLabel
    let headerClone = headerLabel.snapshotViewAfterScreenUpdates(false)
    headerLabel.alpha = 0
    headerClone.frame.origin = headerLabel.convertPoint(CGPointZero, toView: nil)
    let headerTarget = toVC.addTransactionHeader.convertPoint(CGPointZero, toView: nil)
    
    container.addSubview(headerClone)
    
    let duration = transitionDuration(transitionContext)
    
    UIView.animateWithDuration(duration / 3.0, animations: {
      fromView.alpha = 0
      }
    )
    
    UIView.animateWithDuration(duration / 2.0, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      headerClone.frame.origin = headerTarget
      }, completion: { (finished) in
      }
    )
    
    UIView.animateWithDuration(duration / 2.0, delay: duration / 2.0, options: UIViewAnimationOptions(0), animations: {
      toView.alpha = 1
      }, completion: { (finished) in
        fromView.alpha = 1
        headerLabel.alpha = 1
        headerClone.removeFromSuperview()
        transitionContext.completeTransition(true)
      }
    )
  }
}