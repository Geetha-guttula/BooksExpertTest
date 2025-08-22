//
//  NewsListModel.swift
//  NewsAppplication
//
//  Created by hb on 18/03/25.
//

import Foundation

struct NewsListModel: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

enum NewsItemType {
    case NewsList
    case SvedNewsList
}

// MARK: - Article
struct Article: Codable  , Hashable , Identifiable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    var id : String = UUID().uuidString
    var isSavedLocally :Bool = false
    var author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    var isBookmarked: String?
    //    var isBookmarked: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case author , title , description , url , urlToImage , publishedAt
        case isBookmarked  = "content"
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Source
struct Source: Codable , Hashable {
    let id: String?
    let name: String?
}
