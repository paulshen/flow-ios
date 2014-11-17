//
//  TransactionTableViewCell.swift
//  Flow
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
    
    self.selectionStyle = UITableViewCellSelectionStyle.None
    
    body.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    body.numberOfLines = 1
    body.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(body)
    
    border.backgroundColor = UIColor.blackColor()
    border.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.addSubview(border)
    
    let views = ["body": body, "border": border]
    
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[body]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[border]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    
    let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[body]-10-[border(1)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    contentView.addConstraints(vConstraint)
  }
  
  override func setHighlighted(highlighted: Bool, animated: Bool) {
    if highlighted {
      self.body.textColor = UIColor(red: 0.949, green: 0.227, blue: 0.396, alpha: 1.0)
    } else {
      self.body.textColor = UIColor.blackColor()
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
