//
//  AlbumsList.swift
//  TestTask
//
//  Created by Bindu on 17.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import Foundation

struct Albums: Decodable {
    let albums: TopAlbums?
    
    private enum CodingKeys: String, CodingKey {
        case albums = "topalbums"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        albums = try values.decode(TopAlbums.self, forKey: .albums)
    }
}

struct TopAlbums: Decodable {
    let albumList: [AlbumDetails]?
    
    private enum CodingKeys: String, CodingKey {
        case albumList = "album"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        albumList = try values.decode([AlbumDetails].self, forKey: .albumList)
    }
    
}

struct AlbumDetails: Decodable {
    let albumName: String?
    let url: URL?
    let image: [AlbumImages]?
    var mbid: String?
    var isAlbumDataSaved: Bool = false
    private enum CodingKeys: String, CodingKey {
        case albumName = "name"
        case url = "url"
        case image = "image"
        case mbid = "mbid"
    }

   init(from decoder: Decoder) throws {
       let values = try decoder.container(keyedBy: CodingKeys.self)
        albumName = try values.decode(String.self, forKey: .albumName)
        url = try values.decode(URL.self, forKey: .url)
        mbid = try values.decodeIfPresent(String.self, forKey: .mbid)
        image = try values.decode([AlbumImages].self, forKey: .image)
    }
}

struct AlbumImages: Decodable {
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
