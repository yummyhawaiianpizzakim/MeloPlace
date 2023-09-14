//
//  SpotifyUserProfileDTO.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation

struct SpotifyUserProfileDTO: Codable {
    var country, displayName, email: String
//    var explicitContent: SpotifyUserProfileExplicitContent
//    var externalUrls: SpotifyUserProfileExternalUrls
//    var followers: SpotifyUserProfileFollowers
//    var href
    var id: String
    var images: [SpotifyUserProfileImage]
    var product, type, uri: String

    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
//        case explicitContent = "explicit_content"
//        case externalUrls = "external_urls"
//        case followers, href
        case id, images, product, type, uri
    }
}

//// MARK: - ExplicitContent
//struct SpotifyUserProfileExplicitContent: Codable {
//    var filterEnabled, filterLocked: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case filterEnabled = "filter_enabled"
//        case filterLocked = "filter_locked"
//    }
//}
//
//// MARK: - ExternalUrls
//struct SpotifyUserProfileExternalUrls: Codable {
//    var spotify: String
//}
//
//// MARK: - Followers
//struct SpotifyUserProfileFollowers: Codable {
//    var href: String
//    var total: Int
//}

// MARK: - Image
struct SpotifyUserProfileImage: Codable {
    var url: String
    var height, width: Int
}

extension SpotifyUserProfileDTO {
    func toDomain() -> SpotifyUserProfile {
        return SpotifyUserProfile(
            id: self.id,
            name: self.displayName,
            email: self.email,
            imageURL: self.images.last?.url ?? "",
            imageWidth: self.images.last?.width ?? 0,
            imageHeight: self.images.last?.height ?? 0
        )
    }
}

struct SpotifyUserProfile {
    var id: String
    var name: String
    var email: String
    var imageURL: String
    var imageWidth: Int
    var imageHeight: Int
}
