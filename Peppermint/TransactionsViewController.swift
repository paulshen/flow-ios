//
//  ViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/5/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Parse
import UIKit

class TransactionsViewController: UIViewController {
  
  var headerView: TransactionsHeaderView!
  
  var tableView: UITableView!
  let kCellIdentifier = "TransactionCell"
  var transactions: [PFObject]?
  
  override func loadView() {
    super.loadView()
    
    headerView = TransactionsHeaderView(frame: CGRectMake(0, 0, view.bounds.width, 70.0))
    view.addSubview(headerView)
    
    let headerAddButton = headerView.addButton
    headerAddButton.addTarget(self, action: "addButtonTapped:", forControlEvents: .TouchUpInside)
    
    tableView = UITableView(frame: CGRectZero, style: .Plain)
    tableView.registerClass(TransactionTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 40.0
    tableView.separatorColor = UIColor.clearColor()
    tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(tableView)
    
    let views = ["header": headerView, "table": tableView]
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[header]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    
    let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[header(70)][table]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    view.addConstraints(vConstraint)

    
    let query = PFQuery(className: "Transaction")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]!, error: NSError!) -> Void in
      if error == nil {
        NSLog("Retrieved \(objects.count) items")
        self.transactions = (objects as [PFObject])
        self.tableView.reloadData()
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func addButtonTapped(sender:UIButton!) {
    NSLog("tapped")
    NSLog("%@", sender)
    
    let newVC = NewTransactionViewController()
    navigationController?.presentViewController(newVC, animated: true, completion: nil)
  }
}

extension TransactionsViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.transactions?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as TransactionTableViewCell
    cell.body.text = (transactions![indexPath.row]["description"] as String)
    cell.updateConstraintsIfNeeded()
    return cell as UITableViewCell
  }
}

extension TransactionsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    headerView.labelView.text = String(indexPath.row)
  }
}