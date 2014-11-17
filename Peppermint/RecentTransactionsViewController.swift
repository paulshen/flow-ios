//
//  RecentTransactionsTableView.swift
//  Peppermint
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
  var rectToAnimate: CGRect?

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
    tableView.estimatedRowHeight = 40.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorColor = UIColor.clearColor()
    
    let metrics = [
      "topMargin": inMiniMode ? 0 : 30
    ]
    
    view.addSubview(tableView)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["table": tableView]))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topMargin-[header]-10-[table]|", options: NSLayoutFormatOptions(0), metrics: metrics, views: ["header": recentTransactionsHeader, "table": tableView]))
    view.layoutIfNeeded()
    
    if inMiniMode {
      tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
      tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
      view.addConstraint(tableViewHeightConstraint)
    } else {
      let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("onTapClose:"))
      view.addGestureRecognizer(tapRecognizer)
    }
    
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
  
  func onTapClose(sender: UISwipeGestureRecognizer!) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
    })
  }
}

extension RecentTransactionsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let numTransactions = self.transactions?.count {
      if inMiniMode {
        return min(numTransactions, 2) + 1
      }
      return numTransactions
    }
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as TransactionTableViewCell
    
    if inMiniMode && indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1 {
      cell.body.text = "View More"
    } else {
      cell.body.text = (transactions![indexPath.row]["description"] as String)
    }
    
    cell.updateConstraintsIfNeeded()
    return cell
  }
}

extension RecentTransactionsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if inMiniMode && indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1  {
      let fullRecentVC = RecentTransactionsViewController(inMiniMode: false)
      fullRecentVC.transitioningDelegate = self
      rectToAnimate = tableView.rectForRowAtIndexPath(indexPath)
      presentViewController(fullRecentVC, animated: true) { () -> Void in
        
      }
    }
  }
}

extension RecentTransactionsViewController: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
}

extension RecentTransactionsViewController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as UINavigationController
    let dashboardVC = fromVC.viewControllers[0] as DashboardViewController
    let fromRecentTransactionVC = dashboardVC.recentTransactionVC
    let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as RecentTransactionsViewController
    
    let container = transitionContext.containerView()
    container.backgroundColor = UIColor.whiteColor()
    
    let tableViewOffset = tableView.convertPoint(CGPointZero, toView: nil)
    
    let topExpanderHeight = tableViewOffset.y + rectToAnimate!.origin.y
    let topExpander = UIView(frame: CGRectMake(0, 0, container.bounds.size.width, topExpanderHeight))
    topExpander.clipsToBounds = true
    topExpander.addSubview(fromVC.view.snapshotViewAfterScreenUpdates(false))
    
    let bottomExpanderTop = tableViewOffset.y + rectToAnimate!.origin.y + rectToAnimate!.size.height
    let bottomExpanderHeight = container.bounds.size.height - bottomExpanderTop
    let bottomExpander = UIView(frame: CGRectMake(0, bottomExpanderTop, container.bounds.size.width, bottomExpanderHeight))
    let bottomExpanderSnapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
    bottomExpanderSnapshot.frame.origin = CGPointMake(0, -bottomExpanderTop)
    bottomExpander.clipsToBounds = true
    bottomExpander.addSubview(bottomExpanderSnapshot)
    
    let toView = toVC.view
    toView.alpha = 0
    container.addSubview(toView)
    
    let targetTableViewOffset = toVC.tableView.convertPoint(CGPointZero, toView: nil)
    let tableViewDelta = tableViewOffset.y - targetTableViewOffset.y
    
    toView.frame.origin.y = tableViewDelta
    
    fromVC.view.removeFromSuperview()
    container.addSubview(topExpander)
    container.addSubview(bottomExpander)
    
    let duration = transitionDuration(transitionContext)
    UIView.animateWithDuration(duration, animations: { () -> Void in
      topExpander.frame.origin.y = -tableViewDelta
      bottomExpander.frame.origin.y = container.bounds.height
      toView.frame.origin.y = 0
      toView.alpha = 1
      }, completion: { (finished) -> Void in
        topExpander.removeFromSuperview()
        bottomExpander.removeFromSuperview()
        transitionContext.completeTransition(true)
    })
  }
}