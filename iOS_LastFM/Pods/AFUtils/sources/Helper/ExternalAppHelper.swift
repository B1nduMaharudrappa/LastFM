//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import UIKit
import MessageUI

public class ExternalAppHelper {
	
	/// Open call with prompt
	///
	/// - Parameter number: telefon number
	/// - Return: Call app was opened successful
	public class func openCall(with number: String) -> Bool {
		
		let url = URL(string: "telprompt://".appending(number))
		return ExternalAppHelper.openURL(with: url)
	}
	
    
	/// Open the system settings
	/// - Return: System settings was opened successful
	public class func openSystemSettings() -> Bool {
		
		let url = URL(string: UIApplicationOpenSettingsURLString)
		return ExternalAppHelper.openURL(with: url)
	}
	
    
	/// Open iOS mail app
	///
	/// - Parameters:
	///   - email: Recipient mail.
	///   - subject: Subject of the mail.
	///   - body: Body of the mail.
	/// - Return: Mail app was opened successful
	public class func sendMailViaApp(for email: String, subject: String, body: String) -> Bool {
		
		let mailString = "message://".appending(email).appending("?subject=").appending(subject).appending("&body=").appending(body)
		guard let coded = mailString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
			return false
		}
		
		let url = URL(string: coded)
		return ExternalAppHelper.openURL(with: url)
	}
	
    
	/// Open mail composer
	///
	/// - Parameters:
	///   - emails: Array of recipient mails.
	///   - subject: Subject of the mail.
	///   - body: Body of the mail.
	/// - Return: Mail composer was opened successful
	public class func sendMailViaComposer(for emails: [String], subject: String, body: String) -> Bool {
		
		if MFMailComposeViewController.canSendMail() {
			
			let vc = MFMailComposeViewController()
			vc.setToRecipients(emails)
			vc.setSubject(subject)
			vc.setMessageBody(body, isHTML: false)
			
			UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
			return true
		}
		
		return false
	}
	
	
	// MARK: - Helper
	
	class private func openURL(with URL: URL?) -> Bool {
		
		guard let URL = URL,
			UIApplication.shared.canOpenURL(URL) == true else {
			return false
		}
		
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(URL, options: [:], completionHandler: nil)
		} else {
			UIApplication.shared.openURL(URL)
		}
		
		return true
	}
}
