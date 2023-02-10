//
//  ModelData.swift
//  HelloIOS
//
//  Created by ThanDuc on 10/02/2023.
//
import Foundation

// MARK: - NewsData
class NewsData: Codable {
    let data: DataClass

    init(data: DataClass) {
        self.data = data
    }
}

// MARK: - DataClass
class DataClass: Codable {
    let news: [Newspaper]
    let code: Int

    init(news: [Newspaper], code: Int) {
        self.news = news
        self.code = code
    }
}

// MARK: - News
class Newspaper: Codable {
    let id: Int
    let name: String
    let link: String
    let endpoint: String
    let category: [Category]

    init(id: Int, name: String, link: String, endpoint: String, category: [Category]) {
        self.id = id
        self.name = name
        self.link = link
        self.endpoint = endpoint
        self.category = category
    }
}

// MARK: - Category
class Category: Codable {
    let id: Int
    let name, path: String

    init(id: Int, name: String, path: String) {
        self.id = id
        self.name = name
        self.path = path
    }
}
