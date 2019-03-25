//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import Foundation

struct Constants {
        static let baseUrl = "https://ws.audioscrobbler.com/2.0/?"
        static let apiKey = "7604c367d40d25a5fdc2d6e32f517185"
}

protocol EndPointType {
    var baseURL: URL { get }
    var httpMethod: HTTPMethod { get }
    var task: UserRequests { get }
    var headers: HTTPHeaders? { get }
}
