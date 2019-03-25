//
//  Created by APPSfactory GmbH
//  Copyright © 2018 Appsfactory GmbH. All rights reserved.
//

import UIKit

public enum AFLogLevel: Int {
	
    case verbose
    case debug
    case info
    case warning
    case error
}


// main logging logic
public class AFLog: NSObject {
	
    /// Default is .verbose
    ///
    /// Will output logLevels greater than or equal the defined level
    public var logLevel = AFLogLevel.verbose
    
    /// Will output logs in viewWillAppear
    ///
    /// marked with "🔵"
    public var isUiLoggingEnabled: Bool = true
    
    ///
    var hideOutput = true
    
    
	// MARK: - LOG Methods
	
	// swiftlint:disable identifier_name
	
    /// Print verbose Logs -> marked with "🚩"
    public func V(_ items: Any?=nil, functionName: String = #function, fileName: String = #file, line: Int = #line) {
		
        // hide output
        if self.hideOutput == true {
			return
		}
        
        if self.logLevel.rawValue <= AFLogLevel.verbose.rawValue {
            self.writeOutput("🚩 | " + self.createOutputString(items, fileName: fileName, functionName: functionName, line: line))
        }
    }
    
    
    /// print debug Logs -> marked with "🚀"
    public func D(_ items: Any?=nil, functionName: String = #function, fileName: String = #file, line: Int = #line) {
		
        // hide output
        if self.hideOutput == true {
			return
		}
        
        if self.logLevel.rawValue <= AFLogLevel.debug.rawValue {
            self.writeOutput("🚀 | " + self.createOutputString(items, fileName: fileName, functionName: functionName, line: line))
        }
    }
    
    
    /// print info Logs -> marked with "ℹ️"
    public func I(_ items: Any?=nil, functionName: String = #function, fileName: String = #file, line: Int = #line) {
		
        // hide output
        if self.hideOutput == true {
			return
		}
        
        if self.logLevel.rawValue <= AFLogLevel.info.rawValue {
            self.writeOutput("ℹ️ | " + self.createOutputString(items, fileName: fileName, functionName: functionName, line: line))
        }
    }
    
    
    /// print warning Logs -> marked with "⚠️"
    public func W(_ items: Any?=nil, functionName: String = #function, fileName: String = #file, line: Int = #line) {
		
        // hide output
        if self.hideOutput == true {
			return
		}
        
        if self.logLevel.rawValue <= AFLogLevel.warning.rawValue {
            self.writeOutput("⚠️ | " + self.createOutputString(items, fileName: fileName, functionName: functionName, line: line))
        }
    }
    
    
    /// print error Logs -> marked with "⛔️"
    public func E(_ items: Any?=nil, functionName: String = #function, fileName: String = #file, line: Int = #line) {
		
		// hide output
        if self.hideOutput == true {
			return
		}
        
        if self.logLevel.rawValue <= AFLogLevel.error.rawValue {
            self.writeOutput("⛔️ | " +  self.createOutputString(items, fileName: fileName, functionName: functionName, line: line))
        }
    }
    
    
    // UI Logs
    func U(_ string: String) {
		
        // hide output
        if self.hideOutput == true {
			return
		}
        
        if self.isUiLoggingEnabled {
            self.writeOutput("🔵 | " + string)
        }
    }
	// swiftlint:enable identifier_name
    
    
	// MARK: - Output
    
    fileprivate func createOutputString(_ items: Any?, fileName: String, functionName: String, line: Int) -> String {
		
		var output = String()
        
        if let nameComps = URL(string: fileName)?.lastPathComponent.components(separatedBy: "."), nameComps.count > 0 {
            output = "\(nameComps[0]) | "
        }
        
        output += "\(functionName) | \(line) | "
        
        if let out = items {
            output += "\(out)"
        }
        
        return output
    }
    
    
    func writeOutput(_ output: String) {
        // overridden in subclass
    }
}
