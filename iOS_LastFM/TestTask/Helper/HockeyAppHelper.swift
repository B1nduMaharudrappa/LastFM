//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import Foundation
import HockeySDK

class HockeyAppHelper: NSObject {
	
	// MARK: - Configure
	
	func configureHockeyApp() {
		
		if !self.hockeyAppId.isEmpty {
			
			BITHockeyManager.shared().configure(withIdentifier: self.hockeyAppId, delegate: self)
			BITHockeyManager.shared().start()
			BITHockeyManager.shared().authenticator.authenticateInstallation()
		}
	}
}


// MARK: - BITHockeyManagerDelegate

extension HockeyAppHelper: BITHockeyManagerDelegate {
	
	func applicationLog(for crashManager: BITCrashManager!) -> String! {
		return LOG.getCrashLog(withBytes: 5000)
	}
}
