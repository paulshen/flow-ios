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

class RecentTransactionsTableView: UIView {
  var tableView: UITableView!
  let kCellIdentifier = "TransactionCell"
  var transactions: [PFObject]?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.redColor()
    
    tableView = UITableView(frame: frame, style: UITableViewStyle.Plain)
    tableView.registerClass(TransactionTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 40.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.separatorColor = UIColor.clearColor()
    tableView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
    self.addSubview(tableView)
    
    tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    
    let query = PFQuery(className: "Transaction")
    query.orderByDescending("date")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]!, error: NSError!) -> Void in
      if error == nil {
        NSLog("Retrieved \(objects.count) items")
        self.transactions = (objects as [PFObject])
        self.tableView.reloadData()
      }
    }
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func intrinsicContentSize() -> CGSize {
    return tableView.contentSize
  }
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentSize" && object as? UITableView == tableView {
      self.invalidateIntrinsicContentSize()
    }
  }
}

extension RecentTransactionsTableView: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let numTransactions = self.transactions?.count {
      return min(numTransactions, 2)
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

extension RecentTransactionsTableView: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
}