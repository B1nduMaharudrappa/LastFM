//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
	
	// MARK: - Lifecycle
	
	deinit {
		LOG.V(type(of: self))
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		self.addObserver( selector: #selector(self.viewWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground.rawValue)
		self.addObserver( selector: #selector(self.viewDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground.rawValue)
		self.addObserver( selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow.rawValue)
		self.addObserver( selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide.rawValue)
		
		super.viewWillAppear(animated)
		
		// add custom stuff here
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		super.viewWillDisappear(animated)
		
		// add custom stuff here
	}
	
	
	// MARK: - Observer
	
	@objc func keyboardWillShow(notification: NSNotification) {
		// implement in subclass
	}
	
	
	@objc func keyboardWillHide(notification: NSNotification) {
		// implement in subclass
	}
	
	
	/// App will enter foreground (UIApplicationWillEnterForegroundNotification)
	@objc func viewWillEnterForeground() {
		// implement this in subclass
	}
	
	
	/// App did enter background (UIApplicationDidEnterBackgroundNotification)
	@objc func viewDidEnterBackground() {
		// implement this in subclass
	}
	
	
	// MARK: - Helper
	
	func addObserver( selector: Selector, name: String) {
		NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
	}
	
	
	func navBarHeight() -> CGFloat {
		
		if let frame = self.navigationController?.navigationBar.frame {
			
			let h = frame.height
			let y = frame.origin.y
			
			return h + y
		}
		
		return 0
	}
}
