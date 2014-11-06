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
  var collectionView: UICollectionView!
  var collectionViewLayout: UICollectionViewFlowLayout!
  let kCellIdentifier = "CollectionCell"
  var transactions: [PFObject]?
  
  override func viewDidLoad() {
    NSLog("viewDidLoad")
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    collectionViewLayout = UICollectionViewFlowLayout()
    collectionViewLayout.minimumInteritemSpacing = 0.0
    collectionViewLayout.minimumLineSpacing = 1.0
    collectionViewLayout.estimatedItemSize = CGSizeMake(view.bounds.width, 240.0)
    
    collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
    collectionView.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: kCellIdentifier)
    collectionView.dataSource = self
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.delegate = self
    
    view.addSubview(collectionView)
    
    let views = ["collection": collectionView]
    
    let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    view.addConstraints(hConstraint)
    let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[collection]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    view.addConstraints(vConstraint)

    view.backgroundColor = UIColor.brownColor()

    
    let query = PFQuery(className: "Transaction")
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]!, error: NSError!) -> Void in
      if error == nil {
        NSLog("Retrieved \(objects.count) items")
        self.transactions = (objects as [PFObject])
        self.collectionView.reloadData()
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension TransactionsViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return transactions?.count ?? 0
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as CollectionViewCell
    let transaction = self.transactions![indexPath.row]
    cell.body.text = (transaction["description"] as String)
    return cell
  }
}

extension TransactionsViewController: UICollectionViewDelegate {
}