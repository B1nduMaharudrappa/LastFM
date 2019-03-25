//
//  UIActivityIndicator.swift
//  TestTask
//
//  Created by Bindu Maharudrappa on 17.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//
import UIKit
import Foundation
import QuartzCore

extension BaseViewController {
    
    var activityIndicatorTag: Int {
        return 123
    }
    func startActivityIndicator(
        style: UIActivityIndicatorViewStyle = .gray,
        location: CGPoint? = nil) {
        
        //Ensure the UI is updated from the main thread
        //in case this method is called from a closure
        
        DispatchQueue.main.async {
            let loc = location ?? self.view.center
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            //Add the tag so we can find the view in order to remove it later
            
            activityIndicator.tag = self.activityIndicatorTag
            //Set the location
            
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            //Start animating and add the view
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        }
    }
    
    func stopActivityIndicator() {
        
        //Again, we need to ensure the UI is updated from the main thread!
        
        DispatchQueue.main.async {
            if let activityIndicator = self.view.subviews.filter({ $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}
