//
//  ArtistData.swift
//  TestTask
//
//  Created by Bindu on 12.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import UIKit

struct Artist: Decodable {
    let result: Results?
    
    private enum CodingKeys: String, CodingKey {
        case result = "results"
    }
}

struct Results: Decodable {
    let artistMatches: ArtistMatches?
    private enum CodingKeys: String, CodingKey {
        case artistMatches = "artistmatches"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        artistMatches = try values.decode(ArtistMatches.self, forKey: .artistMatches)
    }
}

struct ArtistMatches: Decodable {
    let artists: [ArtistDetails]?
    private enum CodingKeys: String, CodingKey {
        case artists = "artist"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        artists = try values.decode([ArtistDetails].self, forKey: .artists)
    }
}

struct ArtistDetails: Decodable {
    let artistName: String?
    let artistUrl: URL?
    
    private enum CodingKeys: String, CodingKey {
        case artistName = "name"
        case artistUrl = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        artistName = try values.decode(String.self, forKey: .artistName)
        artistUrl = try values.decode(URL.self, forKey: .artistUrl)
    }
    
}
