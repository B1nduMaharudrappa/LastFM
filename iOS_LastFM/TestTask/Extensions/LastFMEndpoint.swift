//
//  LastFMEndpoint.swift
//  TestTask
//
//  Created by Bindu on 13.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case staging
}

public enum LastFMApi {
    case artistNameList(name:String)
    case artistAlbums(name:String)
    case albumDescription(artistName: String, albumName: String)
}

extension LastFMApi: EndPointType {
    
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .staging: return Constants.baseUrl
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: UserRequests {
        switch self {
        case .artistNameList(let name):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["method": "artist.search", "artist": name,
                                                      "api_key": Constants.apiKey, "format": "json"])
        case .artistAlbums(let name):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["method": "artist.gettopalbums", "artist": name,
                                                      "api_key": Constants.apiKey, "format": "json"])
            
        case .albumDescription(let artistName, let albumName):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["method": "album.getinfo", "api_key": Constants.apiKey,
                                                      "artist": artistName, "album": albumName, "format": "json"])
//        default:
//            return .request
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
