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
      view.addGestureRecognizer(tapRecognizer)
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
    fullRecentVC.transitioningDelegate = self
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
    cell.body.text = (transactions![indexPath.row]["description"] as String)
    cell.updateConstraintsIfNeeded()
    return cell
  }
}

extension RecentTransactionsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
}

extension RecentTransactionsViewController: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewMoreRecentTransactionsAnimator()
  }
}

class ViewMoreRecentTransactionsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
    
    let rectToExpand = fromRecentTransactionVC.viewMoreButton!.convertRect(fromRecentTransactionVC.viewMoreButton!.bounds, toView: container)
    
    let topExpanderHeight = rectToExpand.origin.y
    let topExpander = UIView(frame: CGRectMake(0, 0, container.bounds.size.width, topExpanderHeight))
    topExpander.clipsToBounds = true
    topExpander.addSubview(fromVC.view.snapshotViewAfterScreenUpdates(false))
    
    let bottomExpanderTop = CGRectGetMaxY(rectToExpand)
    let bottomExpanderHeight = container.bounds.size.height - bottomExpanderTop
    let bottomExpander = UIView(frame: CGRectMake(0, bottomExpanderTop, container.bounds.size.width, bottomExpanderHeight))
    let bottomExpanderSnapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
    bottomExpanderSnapshot.frame.origin = CGPointMake(0, -bottomExpanderTop)
    bottomExpander.clipsToBounds = true
    bottomExpander.addSubview(bottomExpanderSnapshot)
    
    let toView = toVC.view
    toView.alpha = 0
    container.addSubview(toView)
    
    let fromTableViewOffset = fromRecentTransactionVC.tableView.convertPoint(CGPointZero, toView: container)
    let targetTableViewOffset = toVC.tableView.convertPoint(CGPointZero, toView: container)
    let tableViewDelta = fromTableViewOffset.y - targetTableViewOffset.y
    
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