//
//  SelectCategoryViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/13/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse
import UIKit

class SelectCategoryViewController: UIViewController {
  let kCellIdentifier = "Cell"
  var tableView: UITableView!
  var categories: [PFObject]?
  var categoryChangeCallback: (String) -> Void
  
  init(categoryChangeCallback: (String) -> Void) {
    self.categoryChangeCallback = categoryChangeCallback
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView = UITableView(frame: view.bounds, style: .Plain)
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
    tableView.delegate = self
    tableView.dataSource = self
    view.addSubview(tableView)
    
    let query = PFQuery(className: "Category")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]!, error: NSError!) -> Void in
      if error == nil {
        NSLog("Retrieved \(objects.count) items")
        self.categories = (objects as [PFObject])
        self.tableView.reloadData()
      }
    }
  }
}

extension SelectCategoryViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let category = categories![indexPath.row]
    categoryChangeCallback(category["name"] as String)
  }
}

extension SelectCategoryViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
    
    cell.textLabel.text = (categories![indexPath.row]["name"] as String)
    return cell
  }
}