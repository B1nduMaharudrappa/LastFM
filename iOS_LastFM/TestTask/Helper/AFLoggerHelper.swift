//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import AFUtils

let LOG = AFLogger.shared

class AFLoggerHelper {
	
	class func configureLogger() {
		
		guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else {
			return
		}
		
		#if CONFIGURATION_Debug
			LOG.activate(withOnscreenOutput: true)
		#endif
	}
}
