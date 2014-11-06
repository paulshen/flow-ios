//
//  CollectionViewCell.swift
//  Peppermint
//
//  Created by Paul Shen on 11/5/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
  
  var body = UILabel()
  var border = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    body.numberOfLines = 0
    body.setTranslatesAutoresizingMaskIntoConstraints(false)
    border.backgroundColor = UIColor.blackColor()
    border.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    contentView.addSubview(body)
    contentView.addSubview(border)
    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    contentView.backgroundColor = UIColor.whiteColor()
    let contentViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[content]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["content": contentView])
    addConstraints(contentViewConstraints)
    
    let views = ["body": body, "border": border]
    
    let bodyHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[body]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    contentView.addConstraints(bodyHConstraints)
    let borderHConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[border]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    contentView.addConstraints(borderHConstraints)
    
    let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-120-[body]-120-[border(1)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views)
    contentView.addConstraints(vConstraints)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes! {
    super.preferredLayoutAttributesFittingAttributes(layoutAttributes)
    let attr = layoutAttributes.copy() as UICollectionViewLayoutAttributes
    let size = body.sizeThatFits(CGSize(width: attr.frame.size.width, height: CGFloat.max))
    attr.frame = CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(attr.frame), height: size.height + 241.0)
    return attr
  }
}