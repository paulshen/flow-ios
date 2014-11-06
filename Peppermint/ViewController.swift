//
//  ViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/5/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func loadView() {
    let screenRect = UIScreen.mainScreen().bounds
    let screenWidth = screenRect.size.width;
    let screenHeight = screenRect.size.height;
    view = UIView(frame: CGRectMake(0, 0, screenWidth, screenHeight))
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    view.backgroundColor = UIColor.brownColor()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}
