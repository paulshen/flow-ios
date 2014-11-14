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
  
  var searchController: UISearchController!
  var tableView: UITableView!
  var categories: [PFObject]?
  var filteredCategories: [PFObject]!
  
  var categoryChangeCallback: (PFObject) -> Void
  
  init(categoryChangeCallback: (PFObject) -> Void) {
    self.categoryChangeCallback = categoryChangeCallback
    super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.searchBar.frame = CGRectMake(0, 0, view.bounds.width, 44)
    searchController.dimsBackgroundDuringPresentation = false
    view.addSubview(searchController.searchBar)
    
    tableView = UITableView(frame: CGRectMake(0, 44, view.bounds.width, view.bounds.height - 44), style: .Plain)
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
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

extension SelectCategoryViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Set searchController.active before callback for animation
    let searchControllerActive = searchController.active
    searchController.active = false
    if (searchControllerActive) {
      categoryChangeCallback(filteredCategories[indexPath.row])
    } else {
      categoryChangeCallback(categories![indexPath.row])
    }
  }
}

extension SelectCategoryViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (searchController.active) {
      return filteredCategories.count
    } else {
      return categories?.count ?? 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
    
    if (searchController.active) {
      cell.textLabel.text = (filteredCategories[indexPath.row]["name"] as String)
    } else {
      cell.textLabel.text = (categories![indexPath.row]["name"] as String)
    }
    return cell
  }
}

extension SelectCategoryViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if (searchController.searchBar.text == "") {
      filteredCategories = categories
    } else {
      filteredCategories = categories?.filter({ (category) -> Bool in
        let categoryName = NSString(string: category["name"] as String)
        return categoryName.containsString(self.searchController.searchBar.text)
      })
    }
    tableView.reloadData()
  }
}