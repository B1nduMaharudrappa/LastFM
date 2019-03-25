//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import UIKit

public typealias SegueClosure = (UIViewController) -> Void
private var segueDict: [String: SegueClosure] = [:]

public extension UIViewController {
	
	public func performSegue(with identifier: String, sender: Any? = nil, segueClosure: SegueClosure?) {
		
		objc_sync_enter(self)
		type(of: self).swizzlePrepareForSegue()
		
		segueDict[identifier] = segueClosure
		self.performSegue(withIdentifier: identifier, sender: sender)
		
		type(of: self).swizzlePrepareForSegue()
		objc_sync_exit(self)
	}
	
    
	@objc func swizzledPrepareForSegue(_ segue: UIStoryboardSegue, sender: Any?) {
		
		self.swizzledPrepareForSegue(segue, sender: sender)
		
		if let identifier = segue.identifier,
			let segueHandler = segueDict[identifier] {
			
			segueHandler(segue.destination)
			segueDict.removeValue(forKey: identifier)
		}
	}
	
    
	private class func swizzlePrepareForSegue() {
		
		let originalSelector = #selector(UIViewController.prepare(for:sender:))
		let swizzledSelector = #selector(UIViewController.swizzledPrepareForSegue(_:sender:))
		
		let originalMethod = class_getInstanceMethod(self, originalSelector)
		let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
		
		method_exchangeImplementations(originalMethod!, swizzledMethod!)
	}
}
