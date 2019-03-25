//
//  Created by APPSfactory GmbH
//  Copyright © 2017 Appsfactory GmbH. All rights reserved.
//

import UIKit

public extension UIView {
	
	/// Load view from nib
	public class func loadFromNib<T: UIView>() -> T {
		
		let nibName: String = String(describing: T.self)
		
		guard let view = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as? T else {
			fatalError("UIView \(T.self) isn't in main bundle")
		}
		
		return view
	}
}
