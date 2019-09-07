//
//  IGStructFavouriteChannels.swift
//  iGap
//
//  Created by hossein nazari on 9/1/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

struct FavouriteChannelHomeItem: Decodable {
    enum `Type`: String, Decodable {
        case ad = "advertisement"
        case normalCategory = "channelNormalCategory"
        case featuredCategory = "channelFeaturedCategory"
    }
    
    struct Info: Decodable {
        var title: String?
        var englishTitle: String?
        var looped: Bool?
        var playbackTime: Int?
        
        var orderBy: String?
        var sort: String?
        
        var scale: String?
        var scaleFloat: Float {
            guard let parts = scale?.components(separatedBy: ":").compactMap({return Float($0)}) , parts.count == 2  else {return 1}
            return parts[0] / parts[1]
        }
        
        enum CodingKeys: String, CodingKey {
            case looped, title, scale, sort
            case englishTitle = "title_en"
            case playbackTime = "playback_time"
            case orderBy = "order_by"
        }
    }
    
    var id: String?
    var type: Type
    var info: Info?
    var dataCount: Int = 0
    var slides: [FavouriteChannelsAddSlide]?
    var channels: [FavouriteChannelsCategoryChannel]?
    var categories: [FavouriteChannelsNormalCategory]?
    
    enum CodingKeys: String, CodingKey {
        case id, type, info, slides, channels, categories
        case dataCount = "data_count"
    }
}

struct FavouriteChannelsAddSlide: Decodable {
    var id: String?
    var title: String?
    var englishTitle: String?
    // convert to int
    var actionType: Int?
    var actionLink: String = ""
    var imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case englishTitle = "title_en"
        case actionType = "action_type"
        case actionLink = "action_link"
        case imageURL = "image_url"
    }
}

struct FavouriteChannelsCategoryChannel: Decodable {
    enum `Type`: String, Decodable {
        case Public = "PUBLIC"
        case Private = "PRIVATE"
    }
    
    var id: String?
    var title: String?
    var englishTitle: String?
    var slug: String!
    var type: Type?
    var icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, slug, icon, type
        case englishTitle = "title_en"
    }
}

struct FavouriteChannelsNormalCategory: Decodable {
    var id: String?
    var title: String?
    var englishTitle: String?
    var slug: String?
    var icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, slug, icon
        case englishTitle = "title_en"
    }
}

struct FavouriteChannelCategoryInfo: Decodable {
    struct Info: Decodable {
        var id: String
        var icon: String?
        var title: String?
        var englishTitle: String?
        var type: String?
        var slug: String?
        
        var updatedAt: String?
        var hasAd: Bool?
        
        var advertisement: FavouriteChannelsCategoryInfoAdvertisment?
        
        enum CodingKeys: String, CodingKey {
            case id, icon, title, type, slug, updatedAt, advertisement
            case englishTitle = "title_en"
            case hasAd = "has_ad"
        }
    }
    
    struct Pagination: Decodable {
        var totalDocs: Int?
        var limit: Int?
        var hasPrevPage: Bool?
        var hasNextPage: Bool?
        var page: Int?
        var totalPages: Int?
        var pagingCounter: Int?
        var prevPage: Bool?
        var nextPage: Int?
    }
    
    var info: Info?
    var channels: [FavouriteChannelCategoryInfoChannel]?
    var pagination: Pagination?
    
    enum CodingKeys: String, CodingKey {
        case info, channels, pagination
    }
}

struct FavouriteChannelCategoryInfoChannel: Decodable {
    enum `Type`: String, Decodable {
        case Public = "PUBLIC"
        case Private = "PRIVATE"
    }
    
    var type: Type?
    var categories: [String]?
    var title: String?
    var slug: String?
    var icon: String?
    var id: String?
    var englishTitle: String?
}

struct FavouriteChannelsCategoryInfoAdvertisment: Decodable {
    var slides: [FavouriteChannelsAddSlide]?
    var looped: Bool?
    var title: String?
    var scale: String?
    var __v: Int?
    var id: String?
    var playbackTime: Int?
    var englishTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case slides, looped, title, scale, __v, id
        case playbackTime = "playback_time"
        case englishTitle = "title_en"
    }
}

struct FavouriteChannelsArray<T : Decodable>: Decodable {
    var data: [T] = []
}
