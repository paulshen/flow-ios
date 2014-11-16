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
  
  var tableViewHeightConstraint: NSLayoutConstraint!
  
  override func loadView() {
    super.loadView()
    
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    
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
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[header]-10-[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["header": recentTransactionsHeader, "table": tableView]))
    
    tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
    tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
    view.addConstraint(tableViewHeightConstraint)
    
    Transactions.sharedInstance.fetchTransactionsWithCallback {
      transactions in
      self.transactions = transactions
      self.tableView.reloadData()
    }
  }

  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentSize" && object as? UITableView == tableView {
      tableViewHeightConstraint.constant = tableView.contentSize.height
    }
  }
}

extension RecentTransactionsViewController: UITableViewDataSource {
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

extension RecentTransactionsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
}