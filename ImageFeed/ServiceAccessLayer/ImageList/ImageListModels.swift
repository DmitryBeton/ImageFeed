//
//  ImageListModels.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 08.10.2025.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let regularImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let altDescription: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case altDescription = "alt_description"
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct LikeResponse: Decodable {
    let photo: LikePhoto
}

struct LikePhoto: Decodable {
    let id: String
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case likedByUser = "liked_by_user"
    }
}
