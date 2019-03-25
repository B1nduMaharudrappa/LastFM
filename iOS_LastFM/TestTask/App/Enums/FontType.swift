//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import UIKit

enum FontType: String {
	case a = "A"
	case b = "B"
	
	var font: UIFont {
		
		switch self {
		case .a: return UIFont.systemFont(ofSize: 12)
		case .b: return UIFont.systemFont(ofSize: 14)
		}
	}
}
