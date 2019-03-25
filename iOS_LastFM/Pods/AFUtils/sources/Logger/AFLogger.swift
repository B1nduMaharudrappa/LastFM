//
//  Created by APPSfactory GmbH
//  Copyright © 2018 Appsfactory GmbH. All rights reserved.
//

import Foundation
#if os(iOS)
import MessageUI
#endif

// swiftlint:disable type_body_length

#if os(iOS)
public class AFLogger: AFLog {
	
// MARK: - Singleton
    
    public static var shared: AFLogger = AFLogger()
    
    
// MARK: - Const

	private enum Const {
		
		static let directoryPath       = "/Logs"
		static let currrentLogFileName = "current_session.log"
		static let prevLogFileName     = "prev_session.log"
		static let buttonTitleEnable   = "Enable File Logging"
		static let buttonTitleClose    = "Close"
		static let buttonTitleMail     = "Mail"
		static let buttonTitleShare    = "Share"
		static let buttonTitleCurrent  = "Show Current Log"
		static let buttonTitlePrev     = "Show Prev Log"
		static let buttonTitleTouch    = "Touch"
		static let buttonTitleLogLevel = "Level"
	}
    
    
	// MARK: - Properties
    
    public typealias ResetBlock = () -> Void
    
    /// Duration for long press on screen
    ///
    /// Default is 2s
    public var longPressDuration = 2.0
    
    /// Preset e-mail addresses for mail recipients
    public var mailRecipients: [String]?
    
    /// Set to true to hide logging options
    ///
    /// Default is false
    public var sendMailOnly = false
    
    /// Set to true to hide options to open Logfiles in TextView
    ///
    /// Default is false
    public var disableOnscreenLogfiles = false
    
    fileprivate var containerView: UIView?
    fileprivate var textView: UITextView?
    fileprivate var alertActions: [UIAlertAction]?
    fileprivate var resetBlock: ResetBlock?
    
    fileprivate var isFileLoggingActive = false
    fileprivate var isCurrentLogVisible = false
    
    
	// MARK: - Activate
	
    ///
    public func activate(withOnscreenOutput enabled: Bool) {
		
        UIViewController.startSwizzle()
        
        self.hideOutput = false
        
        if enabled {
			
            guard let window = UIApplication.shared.windows.last else {
				return
			}
            
            // add longpress recognizer
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
            longPress.minimumPressDuration = self.longPressDuration
            window.addGestureRecognizer(longPress)
        }
        
        if self.isDebbugingInProcess() {
            return
        }
            
        self.enableFileLogging()
    }
    
    
    /// add custom alert actions to logging alertView
    public func addAlertAction(_ alertAction: UIAlertAction) {
		
        if self.alertActions == nil {
			
            self.alertActions = [UIAlertAction]()
            self.alertActions?.append(alertAction)
            return
        }
        
        self.alertActions?.append(alertAction)
    }
    
    
    /// process additional actions when "reset"-button is pressed
    /// app will be closed after button press
    public func additionalResetActions(_ resetBlock: @escaping ResetBlock) {
        self.resetBlock = resetBlock
    }
    
    
    /// get last n-bytes from the Log-file of the previous session
    /// should be used to upload crash info to HockeyApp
    public func getCrashLog(withBytes maxSize: Int) -> String! {
		
        guard let data = self.prevLogData() else {
			return "No LOG available"
		}
		
        guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			return "No LOG available"
		}
        
        if string.lengthOfBytes(using: String.Encoding.utf8) > maxSize {
			
            let index = string.index(string.endIndex, offsetBy: -maxSize)
            let substring = string[index...]
            return String(substring)
        }
        
        return string
    }
    
    
    /// Open the alert view manually
    public func openAlertViewManually() {
        self.showAlertView()
    }
    

	// MARK: - On screen output
    
    @objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
		
        if recognizer.state == UIGestureRecognizerState.began {
			
            if self.containerView != nil {
				
                self.touchButtonTapped()
            } else {
                self.showAlertView()
            }
        }
    }
    
    
    fileprivate func updateTextView(_ output: String) {
		
        guard let textView = self.textView else {
			return
		}
        
        if self.isCurrentLogVisible == false {
            return
        }
        
        var shouldScrollDown = false
        if textView.contentOffset.y >= textView.contentSize.height - textView.frame.size.height - 20 {
            shouldScrollDown = true
        }
        
        textView.text.append("\n" + output)
        
        if shouldScrollDown {
			
            // workaround for textView offset
            textView.isScrollEnabled = false
            textView.contentOffset = CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude)
            textView.isScrollEnabled = true
        }
    }
    
    
    fileprivate func showAlertView() {
		
        let title = "\(self.bundleAppDisplayName())"
        let message = "v\(self.bundleShortVersion()) Build \(self.bundleBuildVersion())"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if self.sendMailOnly {
			
            // send mail
            alertController.addAction(UIAlertAction(title: Const.buttonTitleMail, style: .default, handler: { (_) -> Void in
                
                self.sendMail()
            }))
			
		} else {
			
			if !self.isFileLoggingActive {
				
				// enable file logging (debugger currently attached)
                alertController.addAction(UIAlertAction(title: Const.buttonTitleEnable, style: .default, handler: { (_) -> Void in
                    
                    self.enableFileLogging()
                    self.showAlertView()
                }))
            } else {
				
                if self.disableOnscreenLogfiles == false {
					
                    // show current logfile
                    if let logData = self.currentLogData() {
						
                        alertController.addAction(UIAlertAction(title: Const.buttonTitleCurrent, style: .default, handler: { (_) -> Void in
                            
                            self.isCurrentLogVisible = true
                            self.showLog(logData)
                        }))
                    }
                    
                    // show prev logfile
                    if let logData = self.prevLogData() {
						
                        alertController.addAction(UIAlertAction(title: Const.buttonTitlePrev, style: .default, handler: { (_) -> Void in
                            
                            self.showLog(logData)
                            
                        }))
                    }
                }
                
                // send mail
                alertController.addAction(UIAlertAction(title: Const.buttonTitleMail, style: .default, handler: { (_) -> Void in
                    
                    self.sendMail()
                }))
                
                // share
                alertController.addAction(UIAlertAction(title: Const.buttonTitleShare, style: .default, handler: { (_) -> Void in
                    
                    self.share()
                }))
            }
            
            // add custom actions
            if let actions = self.alertActions {
				
                for action in actions {
                    alertController.addAction(action)
                }
            }
            
            // reset app content
            alertController.addAction(UIAlertAction(title: "Reset App Content", style: .destructive, handler: { (_) in
                
                self.resetAppContent()
            }))
        }
        
        // cancel
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let presentedVC = self.rootVC().presentedViewController {
			
            presentedVC.present(alertController, animated: true, completion: nil)
        } else {
            self.rootVC().present(alertController, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func sendMail() {
		
        if !MFMailComposeViewController.canSendMail() {
			
            let alert = UIAlertController(title: nil, message: "Please setup your E-Mail account", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(alert, animated: true) {}
            self.closeButtonTapped()
            return
        }
        
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        vc.setToRecipients(self.mailRecipients)
        let prodName = self.bundleAppDisplayName()
        vc.setSubject(prodName + ": Logfiles")
        self.rootVC().present(vc, animated: true, completion: nil)
        
        if let cData = self.currentLogData() {
			
            vc.addAttachmentData(cData, mimeType: "text/plain", fileName: Const.currrentLogFileName)
        }
        
        if let pData = self.prevLogData() {
            vc.addAttachmentData(pData, mimeType: "text/plain", fileName: Const.prevLogFileName)
        }
    }
    
    
    fileprivate func share() {
		
        var fileURLs = [Any]()
        
        if let url = self.currentLogFilePath() {
            fileURLs.append(url)
        }
        
        if let url = self.prevLogFilePath() {
            fileURLs.append(url)
        }
        
        let shareSheet = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
        shareSheet.setValue("Logfiles", forKey: "subject")
        shareSheet.excludedActivityTypes = [UIActivityType.addToReadingList,
                                            UIActivityType.message,
                                            UIActivityType.assignToContact,
                                            UIActivityType.postToFlickr,
                                            UIActivityType.postToTencentWeibo,
                                            UIActivityType.postToVimeo]
        
        if let v = UIApplication.shared.keyWindow?.rootViewController?.view {
			
            shareSheet.popoverPresentationController?.sourceView = v
            shareSheet.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height, width: 1, height: 1)
            UIApplication.shared.keyWindow?.rootViewController?.present(shareSheet, animated: true, completion: nil)
        }
    }
    
    
    fileprivate func showLog(_ data: Data) {
		
        // add container to window
        self.containerView = UIView(frame: UIScreen.main.bounds)
        self.containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.containerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        UIApplication.shared.keyWindow?.addSubview(self.containerView!)
        
        // add textView
        self.textView = UITextView(frame: CGRect(x: 0,
                                                 y: 40,
                                                 width: self.containerView!.bounds.width,
                                                 height: self.containerView!.bounds.height - 40))
        self.textView?.backgroundColor = UIColor.clear
        self.textView?.textColor = UIColor.white
        self.textView?.isEditable = false
        self.textView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.textView?.textContainerInset = UIEdgeInsets.zero
        self.textView?.textContainer.lineFragmentPadding = 0
        self.containerView?.addSubview(self.textView!)
        
        let logText = String(data: data, encoding: String.Encoding.utf8)
        self.textView?.text = logText
        
		let range: NSRange = NSRange(location: self.textView!.text.count - 1, length: 1)
        self.textView?.scrollRangeToVisible(range)
        self.textView?.isScrollEnabled = false
        self.textView?.isScrollEnabled = true
        
        // add buttons
        var buttons = [UIButton]()
        
        let closeButton = self.addDefaultButton(Const.buttonTitleClose, action: #selector(self.closeButtonTapped))
        buttons.append(closeButton)
        
        let touchButton = self.addDefaultButton(Const.buttonTitleTouch, action: #selector(self.touchButtonTapped))
        buttons.append(touchButton)
        
        let levelButton = self.addDefaultButton(Const.buttonTitleLogLevel, action: #selector(self.levelButtonTapped))
        buttons.append(levelButton)
        
        let sendButton = self.addDefaultButton(Const.buttonTitleShare, action: #selector(self.shareButtonTapped))
        buttons.append(sendButton)
        
        // set vertical constraints
        for button in buttons {
			
            self.containerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[button(==20)]",
                                                                              options: NSLayoutFormatOptions(rawValue: 0),
                                                                              metrics: nil,
                                                                              views: ["button": button]))
        }
        
        // set horizontal constraints
        let views = ["view1": closeButton, "view2": touchButton, "view3": levelButton, "view4": sendButton]
        self.containerView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1][view2(==view1)][view3(==view2)][view4(==view3)]|",
                                                                          options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    
    @objc func closeButtonTapped() {
		
		if self.containerView == nil {
			return
		}
        
        self.isCurrentLogVisible = false
        self.containerView?.removeFromSuperview()
        self.containerView = nil
    }
    
    
    func sendButtonTapped() {
		
        self.closeButtonTapped()
        self.sendMail()
    }
    
    
    @objc func shareButtonTapped() {
		
        self.closeButtonTapped()
        self.share()
    }
    
    
    @objc func levelButtonTapped() {
		
        let alert = UIAlertController(title: "Log Level", message: "Select new Log Level", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Verbose", style: .default, handler: { (_) -> Void in
            
            self.logLevel = .verbose
        }))
        
        alert.addAction(UIAlertAction(title: "Debug", style: .default, handler: { (_) -> Void in
            
            self.logLevel = .debug
        }))
        
        alert.addAction(UIAlertAction(title: "Info", style: .default, handler: { (_) -> Void in
            
            self.logLevel = .info
        }))
        
        alert.addAction(UIAlertAction(title: "Warning", style: .default, handler: { (_) -> Void in
            
            self.logLevel = .warning
        }))
        
        alert.addAction(UIAlertAction(title: "Error", style: .default, handler: { (_) -> Void in
            
            self.logLevel = .error
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let window = UIApplication.shared.windows.last {
			
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func touchButtonTapped() {
		
        guard let containerView = self.containerView else {
            return
        }
        
        // disable user interaction in logger
        if self.containerView?.isUserInteractionEnabled == true {
			
            self.containerView?.isUserInteractionEnabled = false
            self.containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            for view in containerView.subviews where view is UIButton {
				
				view.isHidden = true
            }
		// enable user interaction in logger
        } else {
			
            self.containerView?.isUserInteractionEnabled = true
            self.containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            
            for view in containerView.subviews where view is UIButton {
				
                view.isHidden = false
            }
        }
    }
    
    
    override func writeOutput(_ output: String) {
		
        if self.isFileLoggingActive == true {
			
            NSLog(output)
            DispatchQueue.main.async {
                self.updateTextView(output)
            }
        } else {
            print(output)
        }
    }
    
    
	// MARK: - Reset App Content
    
    fileprivate func resetAppContent() {
		
        // reset userdefaults
        if let domainName = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domainName)
        }
        
        // remove folder content
        self.deleteContentInDirectory(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        self.deleteContentInDirectory(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])
        self.deleteContentInDirectory(NSSearchPathForDirectoriesInDomains(.allLibrariesDirectory, .userDomainMask, true)[0])
        
        // clear url cache
        URLCache.shared.removeAllCachedResponses()
        
        // custom additions
        if let resetBlock = self.resetBlock {
            resetBlock()
        }
        
        exit(0)
    }
    
    
    fileprivate func deleteContentInDirectory(_ dirPath: String) {
		
        let fileMgr = FileManager()
        if let directoryContents = try? fileMgr.contentsOfDirectory(atPath: dirPath) {
			
            for path in directoryContents {
				
                let fullPath = (dirPath as NSString).appendingPathComponent(path)
                do {
                    try fileMgr.removeItem(atPath: fullPath)
                } catch {
                    //
                }
            }
        }
    }
    
    
    fileprivate func addDefaultButton(_ title: String, action: Selector) -> UIButton {
		
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: action, for: .touchUpInside)
        self.containerView?.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    
	// MARK: - (File) Logging
    
    fileprivate func enableFileLogging() {
		
        self.isFileLoggingActive = true
        self.redirectLogToDocuments()
        self.writeOutput("------------------------------")
        self.writeOutput("ℹ️ Device:  \(UIDevice.modelName)")
        self.writeOutput("ℹ️ App:     \(self.bundleAppDisplayName())")
        self.writeOutput("ℹ️ Version: \(self.bundleShortVersion())")
        self.writeOutput("ℹ️ Build:   \(self.bundleBuildVersion())")
        self.writeOutput("ℹ️ iOS:     \(UIDevice.current.systemVersion)")
        self.writeOutput("------------------------------")
    }
    
    
    /// Redirect NSLog output to file
    fileprivate func redirectLogToDocuments() {
		
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first! + Const.directoryPath
        let pathForCurrentLog = documentsDirectory + ("/" + Const.currrentLogFileName)
        let pathForPrevLog = documentsDirectory + ("/" + Const.prevLogFileName)
        
        if !FileManager.default.fileExists(atPath: documentsDirectory) {
            // create "Logs"-directory if needed
            do {
                try FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // Error - handle if required
            }
            
            // create logfile for current session
            FileManager.default.createFile(atPath: pathForCurrentLog, contents: nil, attributes: nil)
            
            // create logfile for prev session
            FileManager.default.createFile(atPath: pathForPrevLog, contents: nil, attributes: nil)
			
		} else {
            // remove prev session
            do {
                try FileManager.default.removeItem(atPath: pathForPrevLog)
				
			} catch {
                // Error - handle if required
            }
            
            // copy current session as prev session
            do {
                try FileManager.default.moveItem(atPath: pathForCurrentLog, toPath: pathForPrevLog)
			} catch {
                // Error - handle if required
            }
            
            // create logfile for current session
            FileManager.default.createFile(atPath: pathForCurrentLog, contents: nil, attributes: nil)
        }
        
        // redirect log output to file
        freopen(pathForCurrentLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    
    fileprivate func isDebbugingInProcess() -> Bool {
		
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    
    fileprivate func filePathInDocDir(_ string: String) -> String {
		
        let searchPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentFolderPath = searchPaths[0]
        let filePath = (documentFolderPath as NSString).appendingPathComponent(string)
        return filePath
    }
    
    
    fileprivate func currentLogFilePath() -> URL? {
		
		let currentLogFilePath = self.filePathInDocDir(Const.directoryPath + "/" + Const.currrentLogFileName)
        if FileManager.default.fileExists(atPath: currentLogFilePath) {
            return URL(fileURLWithPath: currentLogFilePath)
        }
        
        return nil
    }
	
	
    public func currentLogData() -> Data? {
		
        if let url = self.currentLogFilePath() {
			
			if let data = try? Data(contentsOf: url) {
                return data
            }
        }
        
        return nil
    }
    
    
    fileprivate func prevLogFilePath() -> URL? {
		
		let prevLogFilePath = self.filePathInDocDir(Const.directoryPath + "/" + Const.prevLogFileName)
        if FileManager.default.fileExists(atPath: prevLogFilePath) {
            return URL(fileURLWithPath: prevLogFilePath)
        }
        
        return nil
    }

    
    public func prevLogData() -> Data? {
		
        if let url = self.prevLogFilePath() {
			
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }
        
        return nil
    }
    
    
	// MARK: - HELPER
    
    private func bundleAppDisplayName() -> String {
		
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
			
            return displayName
			
        } else {
			
			guard let string = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleNameKey)) as? String else {
				return ""
			}
            return string
        }
    }
    
    
    private func bundleBuildVersion() -> String {
		
		guard let string = Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as? String else {
			return ""
		}
		
        return string
    }
    
    
    private func bundleShortVersion() -> String {
		
		guard let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
			return ""
		}
        return versionString
    }
    
    
    fileprivate func rootVC() -> UIViewController {
        return (UIApplication.shared.keyWindow?.rootViewController)!
    }
}


// MARK: - MFMailComposeViewControllerDelegate

extension AFLogger: MFMailComposeViewControllerDelegate {
	
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
#endif


// MARK: - TVOS

#if os(tvOS)
public class AFLogger: AFLog {
	// MARK: - Singleton
	
	public static var shared: AFLogger = AFLogger()
	
	
	// MARK: - Activate
	
	public func activate() {
		self.hideOutput = false
	}
	
	
	override func writeOutput(_ output: String) {
		print(output)
	}
}
#endif

// swiftlint:enable type_body_length
