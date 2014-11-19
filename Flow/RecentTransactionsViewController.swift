//
//  RecentTransactionsTableView.swift
//  Flow
//
//  Created by Paul Shen on 11/12/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse
import UIKit

class RecentTransactionsViewController: UIViewController {
  var tableView: UITableView!
  let kCellIdentifier = "TransactionCell"
  var transactions: [PFObject]?
  
  var inMiniMode: Bool
  var tableViewHeightConstraint: NSLayoutConstraint!
  var viewMoreButton: UIButton?
  
  var animator: UIViewControllerTransitioningDelegate?

  init(inMiniMode: Bool) {
    self.inMiniMode = inMiniMode
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    
    view.backgroundColor = UIColor.whiteColor()
    if inMiniMode {
      view.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    let recentTransactionsHeader = UILabel()
    recentTransactionsHeader.text = "RECENT TRANSACTIONS"
    recentTransactionsHeader.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    recentTransactionsHeader.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    recentTransactionsHeader.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(recentTransactionsHeader)
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[header]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["header": recentTransactionsHeader]))
    
    tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
    tableView.registerClass(TransactionTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 45.5
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorColor = UIColor.clearColor()
    
    view.addSubview(tableView)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["table": tableView]))
    
    if inMiniMode {
      viewMoreButton = UIButton()
      if let viewMoreButton = viewMoreButton {
        viewMoreButton.setTitle("VIEW MORE", forState: UIControlState.Normal)
        viewMoreButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        viewMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        viewMoreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        viewMoreButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20)
        viewMoreButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        viewMoreButton.addTarget(self, action: Selector("onViewMoreTap:"), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(viewMoreButton)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[button]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["button": viewMoreButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[header]-10-[table]-10-[button]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["header": recentTransactionsHeader, "table": tableView, "button": viewMoreButton]))
      }
      
      tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
      tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
      view.addConstraint(tableViewHeightConstraint)
    } else {
      view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[header]-10-[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["header": recentTransactionsHeader, "table": tableView]))
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTapClose:"))
      recentTransactionsHeader.addGestureRecognizer(tapRecognizer)
      recentTransactionsHeader.userInteractionEnabled = true
    }
    
    view.layoutIfNeeded()
    
    Transactions.sharedInstance.fetchTransactionsWithCallback {
      transactions in
      self.transactions = transactions
      self.tableView.reloadData()
    }
  }

  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if inMiniMode && keyPath == "contentSize" && object as? UITableView == tableView {
      tableViewHeightConstraint.constant = tableView.contentSize.height
    }
  }
  
  func onViewMoreTap(sender: UIButton!) {
    let fullRecentVC = RecentTransactionsViewController(inMiniMode: false)
    animator = ViewMoreRecentTransactionsAnimator()
    fullRecentVC.transitioningDelegate = animator
    presentViewController(fullRecentVC, animated: true, completion: nil)
  }
  
  func onTapClose(sender: UISwipeGestureRecognizer!) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension RecentTransactionsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let numTransactions = self.transactions?.count {
      if inMiniMode {
        return min(numTransactions, 2)
      }
      return numTransactions
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as TransactionTableViewCell
    let transaction = transactions![indexPath.row]
    cell.body.text = (transaction["description"] as String)
    cell.price.text = NSString(format: "$%.2f", transaction["amount"] as Double)
    cell.updateConstraintsIfNeeded()
    return cell
  }
}

extension RecentTransactionsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedTransaction = transactions![indexPath.row]
    
    // temp example
    let transactionDetailVC = TransactionDetailViewController(transaction: selectedTransaction)
    
    var selectedRowRect = CGRectOffset(tableView.rectForRowAtIndexPath(indexPath), 0, tableView.convertPoint(CGPointZero, toView: nil).y)
    animator = ViewTransactionDetailAnimator(rectToExpand: CGRectOffset(selectedRowRect, 0, -2))
    transactionDetailVC.transitioningDelegate = animator
    
    presentViewController(transactionDetailVC, animated: true, completion: nil)
  }
}

class ViewMoreRecentTransactionsAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
  var isPresenting = true
  var topExpander: UIView!
  var bottomExpander: UIView!
  var rectToExpand: CGRect!
  var miniTableViewOffset: CGPoint!
  var tableViewDelta: CGFloat!
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    isPresenting = true
    return self
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    isPresenting = false
    return self
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UIViewController!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as UIViewController!
    
    let container = transitionContext.containerView()
    container.backgroundColor = UIColor.whiteColor()
    
    let duration = transitionDuration(transitionContext)
    
    if isPresenting {
      let fromVC = fromVC as UINavigationController
      let toVC = toVC as RecentTransactionsViewController
      
      let dashboardVC = fromVC.viewControllers[0] as DashboardViewController
      let fromRecentTransactionVC = dashboardVC.recentTransactionVC
      
      rectToExpand = fromRecentTransactionVC.viewMoreButton!.convertRect(fromRecentTransactionVC.viewMoreButton!.bounds, toView: container)
      
      let topExpanderHeight = rectToExpand.origin.y
      topExpander = UIView(frame: CGRectMake(0, 0, container.bounds.size.width, topExpanderHeight))
      topExpander.clipsToBounds = true
      topExpander.addSubview(fromVC.view.snapshotViewAfterScreenUpdates(false))
      
      let bottomExpanderTop = CGRectGetMaxY(rectToExpand)
      let bottomExpanderHeight = container.bounds.size.height - bottomExpanderTop
      bottomExpander = UIView(frame: CGRectMake(0, bottomExpanderTop, container.bounds.size.width, bottomExpanderHeight))
      let bottomExpanderSnapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
      bottomExpanderSnapshot.frame.origin = CGPointMake(0, -bottomExpanderTop)
      bottomExpander.clipsToBounds = true
      bottomExpander.addSubview(bottomExpanderSnapshot)
      
      let toView = toVC.view
      toView.alpha = 0
      container.addSubview(toView)
      
      miniTableViewOffset = fromRecentTransactionVC.tableView.convertPoint(CGPointZero, toView: container)
      let targetTableViewOffset = toVC.tableView.convertPoint(CGPointZero, toView: container)
      tableViewDelta = miniTableViewOffset.y - targetTableViewOffset.y
      
      toView.frame.origin.y = tableViewDelta
      
      fromVC.view.removeFromSuperview()
      container.addSubview(topExpander)
      container.addSubview(bottomExpander)
      
      UIView.animateWithDuration(0.1, animations: { () -> Void in
        fromVC.view.alpha = 0
      }, completion: { (finished) -> Void in
        UIView.animateWithDuration(duration - 0.1, animations: { () -> Void in
          self.topExpander.frame.origin.y = -self.tableViewDelta
          self.bottomExpander.frame.origin.y = container.bounds.height
          toView.frame.origin.y = 0
          toView.alpha = 1
          }, completion: { (finished) -> Void in
            self.topExpander.removeFromSuperview()
            self.bottomExpander.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
      })
    } else {
      let fromVC = fromVC as RecentTransactionsViewController
      toVC.view.alpha = 0
      
      // If the table view is not scrolled at the top, hide the rows from the topExpander
      if fromVC.tableView.contentOffset != CGPointZero {
        topExpander.frame.size.height = miniTableViewOffset.y
      }
      
      container.addSubview(toVC.view)
      container.addSubview(fromVC.view)
      container.addSubview(topExpander)
      container.addSubview(bottomExpander)
      
      UIView.animateWithDuration(duration - 0.1, animations: { () -> Void in
        fromVC.view.frame.origin.y -= self.topExpander.frame.origin.y
        fromVC.view.alpha = 0
        self.topExpander.frame.origin.y = 0
        self.bottomExpander.frame.origin.y = CGRectGetMaxY(self.rectToExpand)
      })
      
      UIView.animateWithDuration(0.2, delay: duration - 0.2, options: UIViewAnimationOptions(0), animations: { () -> Void in
        toVC.view.alpha = 1
        }, completion: { (finished) -> Void in
          self.topExpander.removeFromSuperview()
          self.bottomExpander.removeFromSuperview()
          transitionContext.completeTransition(true)
      })
    }
  }
}

class ViewTransactionDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
  var rectToExpand: CGRect
  var topExpander: UIView!
  var bottomExpander: UIView!
  var rectPlaceholder: UIView!
  
  var isPresenting = true

  init(rectToExpand: CGRect) {
    self.rectToExpand = rectToExpand
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    isPresenting = true
    return self
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    isPresenting = false
    return self
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    let container = transitionContext.containerView()
    container.backgroundColor = UIColor.whiteColor()
    
    let duration = transitionDuration(transitionContext)
    let bottomExpanderTop = CGRectGetMaxY(rectToExpand)
    
    if isPresenting {
      let topExpanderHeight = rectToExpand.origin.y
      topExpander = UIView(frame: CGRectMake(0, 0, container.bounds.size.width, topExpanderHeight))
      topExpander.clipsToBounds = true
      topExpander.addSubview(fromVC.view.snapshotViewAfterScreenUpdates(false))
      
      let bottomExpanderHeight = container.bounds.size.height - bottomExpanderTop
      bottomExpander = UIView(frame: CGRectMake(0, bottomExpanderTop, container.bounds.size.width, bottomExpanderHeight))
      let bottomExpanderSnapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
      bottomExpanderSnapshot.frame.origin.y = -bottomExpanderTop
      bottomExpander.clipsToBounds = true
      bottomExpander.addSubview(bottomExpanderSnapshot)
      
      rectPlaceholder = UIView(frame: rectToExpand)
      let rectPlaceholderSnapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
      rectPlaceholderSnapshot.frame.origin.y = -rectToExpand.origin.y
      rectPlaceholder.clipsToBounds = true
      rectPlaceholder.addSubview(rectPlaceholderSnapshot)
      
      let toView = toVC.view
      toView.frame.origin.y = topExpanderHeight
      toView.alpha = 0
      container.addSubview(toView)
      
      fromVC.view.removeFromSuperview()
      container.addSubview(topExpander)
      container.addSubview(bottomExpander)
      container.addSubview(rectPlaceholder)
      
      UIView.animateWithDuration(duration, animations: { () -> Void in
        self.topExpander.frame.origin.y = -topExpanderHeight
        self.rectPlaceholder.frame.origin.y = 0
        self.bottomExpander.frame.origin.y = container.bounds.height
        self.rectPlaceholder.alpha = 0
        toView.frame.origin.y = 0
        toView.alpha = 1
        }, completion: { (finished) -> Void in
          self.topExpander.removeFromSuperview()
          self.bottomExpander.removeFromSuperview()
          transitionContext.completeTransition(true)
      })
    } else {
      container.addSubview(topExpander)
      container.addSubview(bottomExpander)
      container.addSubview(rectPlaceholder)
      
      let fromView = fromVC.view
      
      UIView.animateWithDuration(duration, animations: { () -> Void in
        fromView.frame.origin.y -= self.topExpander.frame.origin.y
        fromView.alpha = 0
        self.topExpander.frame.origin.y = 0
        self.rectPlaceholder.frame.origin.y = self.rectToExpand.origin.y
        self.rectPlaceholder.alpha = 1
        self.bottomExpander.frame.origin.y = bottomExpanderTop
      }, completion: { (finished) -> Void in
        self.topExpander.removeFromSuperview()
        self.rectPlaceholder.removeFromSuperview()
        self.bottomExpander.removeFromSuperview()
        transitionContext.completeTransition(true)
      })
    }
  }
}