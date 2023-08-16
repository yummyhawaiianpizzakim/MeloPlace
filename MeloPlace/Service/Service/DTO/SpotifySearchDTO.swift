//
//  asd.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation

// MARK: - SpotifySearchDTO
struct SpotifySearchDTO: Codable {
    var tracks: Tracks
}

// MARK: - Tracks
struct Tracks: Codable {
    var href: String
    var items: [Item]
    var limit: Int
    var next: String
    var offset: Int
    var previous: JSONNull?
    var total: Int
}

// MARK: - Item
struct Item: Codable {
    var album: Album
    var artists: [Artist]
    var availableMarkets: [String]
    var discNumber, durationMS: Int
    var explicit: Bool
    var externalIDS: ExternalIDS
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var isLocal: Bool
    var name: String
    var popularity: Int
    var previewURL: String
    var trackNumber: Int
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalIDS = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name, popularity
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri
    }
}

// MARK: - Album
struct Album: Codable {
    var albumType: String
    var artists: [Artist]
    var availableMarkets: [String]
    var externalUrls: ExternalUrls
    var href: String
    var id: String
    var images: [Image]
    var name, releaseDate, releaseDatePrecision: String
    var totalTracks: Int
    var type, uri: String

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case totalTracks = "total_tracks"
        case type, uri
    }
}

// MARK: - Artist
struct Artist: Codable {
    var externalUrls: ExternalUrls
    var href: String
    var id, name, type, uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
    var spotify: String
}

// MARK: - Image
struct Image: Codable {
    var height: Int
    var url: String
    var width: Int
}

// MARK: - ExternalIDS
struct ExternalIDS: Codable {
    var isrc: String
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

extension SpotifySearchDTO {
    func toDomain() -> [Music] {
        let items = self.tracks.items
        let musics = items.map { item in
            
            return Music(id: item.id,
                         name: item.name,
                         URI: item.uri,
                         duration: item.durationMS,
                         artist: item.artists.first?.name ?? "",
                         album: item.album.name,
                         imageURL: item.album.images.first?.url ?? "",
                         imageWidth: item.album.images.first?.width ?? 0,
                         imageHeightL: item.album.images.first?.height ?? 0
                         
            )
        }
        
        return musics
    }
}
