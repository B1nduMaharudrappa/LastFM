//
//  RequestParams.swift
//  TestTask
//
//  Created by Bindu on 13.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum RequestParams {
    case body(_ : [String: Any]?)
    case url(_ : [String: Any]?)
}

public enum UserRequests {
    
    case request
    
    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)
}
