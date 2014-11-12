//
//  DashboardViewController.swift
//  Peppermint
//
//  Created by Paul Shen on 11/10/14.
//  Copyright (c) 2014 PaulShen. All rights reserved.
//

import Foundation
import UIKit

class DashboardViewController: UIViewController {
  override func loadView() {
    super.loadView()
    
    let image = UIImage(named: "logo")
    let imageView = UIImageView(image: image)
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.backgroundColor = UIColor.whiteColor()
    view.addSubview(imageView)
    
    view.addConstraints([
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0),
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 30),
      NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 20.0)
    ])
    
    let addTransactionSection = UIView()
    addTransactionSection.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let addTransactionHeader = UILabel()
    addTransactionHeader.text = "ADD TRANSACTION"
    addTransactionHeader.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
    addTransactionHeader.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    addTransactionHeader.setTranslatesAutoresizingMaskIntoConstraints(false)
    addTransactionSection.addSubview(addTransactionHeader)
    
    let buttonLabel = UILabel()
    buttonLabel.text = "+"
    buttonLabel.textColor = UIColor.whiteColor()
    buttonLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 120.0)
    buttonLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let addButton = UIControl()
    addButton.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    addButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    addButton.addSubview(buttonLabel)
    
    addButton.addConstraints([
      NSLayoutConstraint(item: buttonLabel, attribute: .CenterX, relatedBy: .Equal, toItem: addButton, attribute: .CenterX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: buttonLabel, attribute: .CenterY, relatedBy: .Equal, toItem: addButton, attribute: .CenterY, multiplier: 1.0, constant: 0)
    ])
    
    addTransactionSection.addSubview(addButton)
    addTransactionSection.userInteractionEnabled = true
    
    let addTransactionViews = [
      "button": addButton,
      "header": addTransactionHeader
    ]
    addTransactionSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[button]|", options: NSLayoutFormatOptions(0), metrics: nil, views: addTransactionViews))
    addTransactionSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[header]|", options: NSLayoutFormatOptions(0), metrics: nil, views: addTransactionViews))
    addTransactionSection.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[header]-10-[button(140)]|", options: NSLayoutFormatOptions(0), metrics: nil, views: addTransactionViews))
    
    addButton.addTarget(self, action: "addButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
    
    view.addSubview(addTransactionSection)

    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[addTransaction]-20-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["addTransaction": addTransactionSection]))
    view.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: addTransactionSection, attribute: .Bottom, multiplier: 1.0, constant: 20))
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func addButtonTapped(sender: UIControl!) {
    let addVC = AddTransactionViewController(nibName: "AddTransactionViewController", bundle: NSBundle.mainBundle())
    addVC.transitioningDelegate = self
    navigationController?.presentViewController(addVC, animated: true, completion: nil)
  }
}

extension DashboardViewController: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return Animator()
  }
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let container = transitionContext.containerView()
    let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    
    toView.alpha = 0
    container.addSubview(fromView)
    container.addSubview(toView)
    
    let duration = transitionDuration(transitionContext)
    
    UIView.animateWithDuration(duration, animations: {
      toView.alpha = 1
      }, completion: { finished in
        transitionContext.completeTransition(true)
    })
  }
}
