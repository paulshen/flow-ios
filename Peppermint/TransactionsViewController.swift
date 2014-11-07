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
  
  var headerViewOwner = TransactionsHeaderViewOwner()
  var headerView: UIView!
  
  var collectionView: UICollectionView!
  var collectionViewLayout: UICollectionViewFlowLayout!
  let kCellIdentifier = "CollectionCell"
  var transactions: [PFObject]?
  
  override func viewDidLoad() {
    NSLog("viewDidLoad")
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    NSBundle.mainBundle().loadNibNamed("TransactionsHeaderView", owner: headerViewOwner, options: nil)
    headerView = headerViewOwner.root
    headerView.backgroundColor = UIColor.orangeColor()
    headerView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(headerView)
    
    let headerAddButton = headerViewOwner.addButton
    headerAddButton.addTarget(self, action: "addButtonTapped:", forControlEvents: .TouchUpInside)
    
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
    
    let views = ["header": headerView, "collection": collectionView]
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[header]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collection]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    
    let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[header(70)][collection]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
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
  
  func addButtonTapped(sender:UIButton!) {
    NSLog("tapped")
    NSLog("%@", sender)
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
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    headerViewOwner.labelView.text = String(indexPath.row)
  }
}