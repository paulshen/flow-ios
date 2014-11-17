//
//  Categories.swift
//  Flow
//
//  Created by Paul Shen on 11/14/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse

class Categories {
  
  var categories: [PFObject]?
  var callbacks: [[PFObject] -> Void] = []
  var isFetching = false
  
  class var sharedInstance: Categories {
    struct Static {
      static let instance = Categories()
    }
    return Static.instance
  }
  
  func fetchCategoriesWithCallback(callback: [PFObject] -> Void) -> Void {
    if let categories = categories {
      callback(categories)
    } else {
      callbacks.append(callback)
      if !isFetching {
        isFetching = true
        fetchCategories()
      }
    }
  }
  
  private func fetchCategories() {
    let query = PFQuery(className: "Category")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]!, error: NSError!) -> Void in
      if error == nil {
        NSLog("Retrieved \(objects.count) items")
        self.categories = (objects as [PFObject])
        for callback in self.callbacks {
          callback(self.categories!)
        }
      }
    }
  }
}