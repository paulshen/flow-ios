//
//  TransactionsHeaderView.swift
//  Peppermint
//
//  Created by Paul Shen on 11/6/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import UIKit

class TransactionsHeaderView: UIView {
  @IBOutlet var root: UIView!
  @IBOutlet weak var labelView: UILabel!
  @IBOutlet weak var addButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    NSBundle.mainBundle().loadNibNamed("TransactionsHeaderView", owner: self, options: nil)
    root.frame = frame
    root.backgroundColor = UIColor.greenColor()
    addSubview(root)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}