//
//  NetworkConnectionManager.swift
//  TestTask
//
//  Created by Bindu on 13.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import Foundation

class NetworkManager {

    static let environment: NetworkEnvironment = .staging
    
    enum NetworkResponse: String {
        case success
        case authenticationError = "You need to be authenticated first."
        case badRequest = "Bad request"
        case outdated = "The url you requested is outdated."
        case failed = "Network request failed."
        case noData = "Response returned with no data to decode."
        case unableToDecode = "We could not decode the response."
    }
    
    enum Result<String> {
        case success
        case failure(String)
    }

    static func getArtistNameList(artistName: String?, completion: @escaping (_ artist: Results?, _ error: String?) -> Void) {
        let baseVCObj = BaseViewController()
        baseVCObj.startActivityIndicator()
        let router = Router<LastFMApi>()
        router.request(.artistNameList(name: artistName!)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = NetworkManager.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        _ = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        let apiResponse = try JSONDecoder().decode(Artist.self, from: responseData)
                        completion(apiResponse.result, nil)
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    static func getArtistAlbumList(artistName: String?, completion: @escaping (_ albums: TopAlbums?, _ error: String?) -> Void) {
        let baseVCObj = BaseViewController()
        baseVCObj.startActivityIndicator()
        let router = Router<LastFMApi>()
        router.request(.artistAlbums(name: artistName!)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = NetworkManager.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        _ = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        
                        let apiResponse = try JSONDecoder().decode(Albums.self, from: responseData)
                        print(apiResponse)
                        completion(apiResponse.albums, nil)
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    static func getAlbumDetails(artistName: String?, albumName: String?, completion: @escaping (_ albumInfo: AlbumDesc?, _ error: String?) -> Void) {
        let baseVCObj = BaseViewController()
        baseVCObj.startActivityIndicator()
        let router = Router<LastFMApi>()
        router.request(.albumDescription(artistName: artistName!, albumName: albumName!)) { data, response, error in
            if error != nil {
                completion(nil, "Please check your network connection.")
            }
            if let response = response as? HTTPURLResponse {
                let result = NetworkManager.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let jsondata = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        print(jsondata)
                        let apiResponse = try JSONDecoder().decode(AlbumDetail.self, from: responseData)
                        print(apiResponse)
                        completion(apiResponse.albumInfo, nil)
                    } catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }
    }
    
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
}
