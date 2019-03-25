//
//  Created by APPSfactory GmbH
//  Copyright © 2017 Appsfactory GmbH. All rights reserved.
//

import Foundation

public extension NSObject {
	
	public class func delay(with delay: Double, closure: @escaping () -> Void) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
	
    
    public func delay(with delay: Double, closure: @escaping () -> Void) {
		NSObject.delay(with: delay, closure: closure)
	}
}
