//
//  TransactionTableViewCell.swift
//  Peppermint
//
//  Created by Paul Shen on 11/6/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell {
  
  var body = UILabel()
  var border = UIView()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    body.numberOfLines = 0
    body.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(body)
    
    border.backgroundColor = UIColor.grayColor()
    border.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(border)
    
    let views = ["body": body, "border": border]
    
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[body]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[border]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    
    let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[body]-[border(1)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    contentView.addConstraints(vConstraint)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
