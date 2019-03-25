//
//  Created by APPSfactory GmbH
//  Copyright © 2017 Appsfactory GmbH. All rights reserved.
//

import UIKit

public extension Array {
	
	/// Element at the given index if it exists.
	///
	/// - Parameter index: index of element.
	/// - Returns: optional element (if exists).
	public func item(at index: Int) -> Element? {
		
		if 0..<self.count ~= index {
			return self[index]
		}
		
		return nil
	}
	
    
	/// Return a random item from array
    public func randomItem() -> Element? {
		
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self.item(at: index)
	}
}
