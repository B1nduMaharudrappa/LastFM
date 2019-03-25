//
//  AlbumDetail.swift
//  TestTask
//
//  Created by Bindu on 18.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import Foundation

struct AlbumDetail: Decodable {
    let albumInfo: AlbumDesc?
    
    private enum CodingKeys: String, CodingKey {
        case albumInfo = "album"
    }
}

struct AlbumDesc: Decodable {
    let albumName: String?
    let artistName: String?
    let albumImage: [AlbumImage]?
    let tracksList: TrackList?
    private enum CodingKeys: String, CodingKey {
        case albumName = "name"
        case artistName = "artist"
        case albumImage = "image"
        case tracksList = "tracks"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        albumName = try values.decode(String.self, forKey: .albumName)
        artistName = try values.decode(String.self, forKey: .artistName)
        albumImage = try values.decode([AlbumImage].self, forKey: .albumImage)
        tracksList = try values.decode(TrackList.self, forKey: .tracksList)
    }
}

struct TrackList: Decodable {
    let tracks: [Tracks]?
    private enum CodingKeys: String, CodingKey {
        case tracks = "track"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tracks = try values.decode([Tracks].self, forKey: .tracks)
    }
}

struct Tracks: Decodable {
    let trackName: String?
    let trackUrl: URL?
    
    private enum CodingKeys: String, CodingKey {
        case trackName = "name"
        case trackUrl = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        trackName = try values.decode(String.self, forKey: .trackName)
        trackUrl = try values.decode(URL.self, forKey: .trackUrl)
    }
    
}

struct AlbumImage: Decodable {
    let text: String?
    var imageSize: String?
    private enum CodingKeys: String, CodingKey {
        case text = "#text"
        case imageSize = "size"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
        imageSize = try values.decode(String.self, forKey: .imageSize)
    }
}
