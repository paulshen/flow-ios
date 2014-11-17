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
    
    if inMiniMode {
      tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
      tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
      view.addConstraint(tableViewHeightConstraint)
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
      presentViewController(fullRecentVC, animated: true) { () -> Void in
        
      }
    }
  }
}