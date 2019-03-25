//
//  AppUpdateService.swift
//  
//
//  Created by Christoph G. on 22.01.16.
//  Copyright © 2016 Christoph G. All rights reserved.
//

import UIKit
import SystemConfiguration

public class AFAppUpdate {
    
    public enum UpdateType {
        case force              // AppStore or close the app
        case forceApiOnly       // AppStore or close the app without iTunes version check
        case hint               // AppStore or cancel action
        case hintApiOnly        // AppStore or cancel action without iTunes version check
        case hintOnly           // only popup without any actions
        case hintOnlyApiOnly    // only popup without any actions and iTunes version check
    }
    
    fileprivate enum ServiceResult {
        case success(needsUpdate: Bool, version: String)
        case failure()
    }
    
    public typealias AppUpdateCheckCompletion = (Bool) -> Void
    fileprivate typealias AppInfo = (identifier: String, version: String)
    fileprivate typealias AppUpdateCompletion = (ServiceResult) -> Void
    
    fileprivate let appInfos: AppInfo = {
        
        guard let bundle = Bundle.main.infoDictionary,
            let identifier = bundle["CFBundleIdentifier"] as? String,
            let version = bundle["CFBundleShortVersionString"] as? String else { return (identifier: "", version: "") }
        
        return (identifier: identifier, version: version)
    }()
    
    fileprivate var appStoreURL: URL?
    fileprivate var alertStyle          = UIAlertControllerStyle.alert
    fileprivate var cancelStyle         = UIAlertActionStyle.cancel
    fileprivate var title               = "New Version"
    fileprivate var message             = "Version %@ is available on the AppStore."
    fileprivate var updateButtonTitle   = "Update"
    fileprivate var cancelButtonTitle: String?
    fileprivate var hasConnection: Bool {
        
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "itunes.apple.com") else { return false }
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        let success = SCNetworkReachabilityGetFlags(reachability, &flags)
        
        return (success && flags.contains(.reachable) && !(flags.contains(.connectionRequired)))
    }
    
    
    // MARK: - Init
    
    public init(title: String, message: String, updateButtonTitle: String, cancelButtonTitle: String? = nil, alertStyle: UIAlertControllerStyle = .alert, cancelStyle: UIAlertActionStyle = .cancel) {
        
        self.alertStyle         = alertStyle
        self.cancelStyle        = cancelStyle
        self.title              = title
        self.message            = message
        self.updateButtonTitle  = updateButtonTitle
        self.cancelButtonTitle  = cancelButtonTitle
    }
    
    
    // MARK: - Public
    
    
    /// starts checking for App Update
    ///
    /// - Parameters:
    ///   - type: defines actions of eventually shown alert, see `UpdateType`
    ///   - apiVersion: the min version to check against
    ///   - completion: result closure, contains information if dialog is shown (true) or no action was done by AFAppupdate (false)
    public func checkAppUpdate(_ type: UpdateType, apiVersion: String? = nil, completion: AppUpdateCheckCompletion? = nil) {
        
        if self.hasConnection
        {
            guard let apiVersion = apiVersion else
            {
                // non api check
                self.connectItunesStore(type, completion: { (result) in
                    completion?(result)
                })
                return
            }
            
            // api check
            switch (self.compareVersions(apiVersion))
            {
            case .orderedDescending:
                self.connectItunesStore(type, apiVersion: apiVersion, completion: { (result) in
                    completion?(result)
                })
            default:
                completion?(false)
            }
        }
        else
        {
            completion?(false)
        }
    }
    
    
    // MARK: - Helper
    
    fileprivate func connectItunesStore(_ type: UpdateType, apiVersion: String = "", completion: @escaping AppUpdateCheckCompletion) {
        
        self.compareItunesAppVersion(type, apiVersion: apiVersion) { (result) -> Void in
            
            switch result
            {
            case .failure():
                completion(false)
                
            case .success(let needsUpdate, let version):
                
                if needsUpdate
                {
                    self.showAlertUpdate(version, type: type)
                    completion(true)
                }
                else
                {
                    completion(false)
                }
            }
        }
    }
    
    fileprivate func compareItunesAppVersion(_ type: UpdateType, apiVersion: String = "", completion: @escaping AppUpdateCompletion) {
        
        guard let URL = URL(string: "https://itunes.apple.com/lookup?bundleId=\(self.appInfos.identifier)") else { return completion(ServiceResult.failure()) }
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
        
            guard let result = try? Data(contentsOf: URL)  else { return completion(ServiceResult.failure()) }
            guard let json = try? JSONSerialization.jsonObject(with: result, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] else { return completion(ServiceResult.failure()) }
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                guard let _ = json?["resultCount"] as? Int,
                    let details = (json?["results"] as? [AnyObject])?.first as? [String : AnyObject],
                    let appStoreURL = details["trackViewUrl"] as? String,
                    let latestVersion = details["version"] as? String else { return completion(ServiceResult.failure()) }
                
                switch (self.compareVersions(latestVersion))
                {
                case .orderedDescending:
                    // all UpdateType-cases
                    self.proceedResult(appStoreURL, version: latestVersion, completion: completion)
                    
                case .orderedAscending, .orderedSame:
                    // .Force, .Hint, .HintOnly
                    switch type
                    {
                    case .forceApiOnly, .hintApiOnly, .hintOnlyApiOnly:     self.proceedResult(appStoreURL, version: apiVersion, completion: completion)
                    default:                                                completion(ServiceResult.failure())
                    }
                }
            })
        }
    }
    
    fileprivate func compareVersions(_ version: String) -> ComparisonResult {
        return version.compare(self.appInfos.version, options: .numeric, range: nil, locale: nil)
    }
    
    fileprivate func proceedResult(_ appStoreURL: String, version: String, completion: AppUpdateCompletion) {
        
        self.appStoreURL = URL(string: appStoreURL.replacingOccurrences(of: "&uo=4", with: ""))
        completion(ServiceResult.success(needsUpdate: true, version: version))
    }
    
    
    // MARK: - AlertViewController
    
    fileprivate func showAlertUpdate(_ version: String, type: UpdateType) {
        
        let alertVC = self.alertUpdate(version, type: type)
        UIApplication.shared.delegate?.window??.rootViewController?.present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func alertUpdate(_ version: String, type: UpdateType) -> UIAlertController {
        
        let message         = (self.message.range(of: "%@") == nil) ? self.message : String(format: self.message, version)
        let alertVC         = UIAlertController(title: self.title, message: message, preferredStyle: self.alertStyle)
        
        if let cancelButtonTitle = self.cancelButtonTitle
            , type != .hintOnly &&
                type != .hintOnlyApiOnly
        {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: self.cancelStyle) { (_) -> Void in
                
                switch type
                {
                case .force, .forceApiOnly: exit(0)
                default:                    break
                }
            }
            
            alertVC.addAction(cancelAction)
        }
        
        let updateAction = UIAlertAction(title: self.updateButtonTitle, style: .default) { (_) -> Void in
            
            guard let appStoreURL = self.appStoreURL
                , UIApplication.shared.canOpenURL(appStoreURL) &&
                    type != .hintOnly &&
                    type != .hintOnlyApiOnly else { return }
            
            UIApplication.shared.openURL(appStoreURL)
            
            // if app update is forced, display dialog again (is automatically closed after user action)
            
            switch type
            {
            case .force, .forceApiOnly: self.showAlertUpdate(version, type: type)
            case .hint, .hintApiOnly, .hintOnly, .hintOnlyApiOnly: break
            }
        }
        alertVC.addAction(updateAction)
        
        return alertVC
    }
}
