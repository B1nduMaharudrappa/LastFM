//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import UIKit

public final class NotificationObserveHelper: NSObject {
	
	let notificationCenter: NotificationCenter
	let token: Any
	
	
	// MARK: - Initializer
	
	public init(notificationCenter: NotificationCenter = .default, token: Any) {
		
		self.notificationCenter = notificationCenter
		self.token              = token
	}
	
	
	// MARK: - Life cycle
	
	deinit {
		self.notificationCenter.removeObserver(self.token)
	}
}


// MARK: - NotificationCenter

public extension NotificationCenter {
	
	public func observe(name: NSNotification.Name?, object: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NotificationObserveHelper {
		
		let token = self.addObserver(forName: name, object: object, queue: queue, using: block)
		return NotificationObserveHelper(notificationCenter: self, token: token)
	}
}
