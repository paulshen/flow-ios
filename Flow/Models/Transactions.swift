//
//  Transactions.swift
//  Flow
//
//  Created by Paul Shen on 11/14/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import Parse

func ==(lhs: Transactions.Token, rhs: Transactions.Token) -> Bool {
  return lhs.value == rhs.value
}

class Transactions {
  
  struct Token: Hashable {
    let value: Int
    var hashValue: Int {
      return value
    }
  }
  
  var transactions: [PFObject]?
  var callbacks: [Token: [PFObject] -> Void] = [:]
  var nextToken = 1
  
  class var sharedInstance: Transactions {
    struct Static {
      static let instance = Transactions()
    }
    return Static.instance
  }
  
  func fetchTransactionsWithCallback(callback: [PFObject] -> Void) -> Token {
    let token = Token(value: nextToken++)
    callbacks[token] = callback
    
    if let transactions = transactions {
      callback(transactions)
    } else {
      fetchTransactions()
    }
    
    return token
  }
  
  func removeCallback(token: Token) {
    callbacks.removeValueForKey(token)
  }
  
  func reloadData() {
    fetchTransactions()
  }
  
  private func fetchTransactions() {
    let query = PFQuery(className: "Transaction")
    query.orderByDescending("date")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]!, error: NSError!) -> Void in
      if error == nil {
        NSLog("Retrieved \(objects.count) items")
        self.transactions = (objects as [PFObject])
        for (_, callback) in self.callbacks {
          callback(self.transactions!)
        }
      }
    }
  }
}