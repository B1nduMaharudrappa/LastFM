//
//  Created by APPSfactory GmbH
//  Copyright © 2017 Appsfactory GmbH. All rights reserved.
//

import Foundation

public extension Double {
	
	/// Rounds the double to decimal places value
	///
	/// - Parameter places: count of decimal places
	/// - Returns: double value
	public func roundTo(places: Int) -> Double {
		
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
}
