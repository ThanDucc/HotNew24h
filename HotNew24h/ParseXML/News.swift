//
//  News.swift
//  HotNew24h
//
//  Created by ThanDuc on 29/12/2022.
//

import Foundation

class News {
    var title: String
    var pubDate: String
    var imgLink: String
    var link: String
    var description: String
    var htmlString: String
    var isFavourite: Bool?

    init(title: String, pubDate: String, link: String, description: String, imgLink: String, htmlString: String) {
        self.title = title
        self.pubDate = pubDate
        self.link = link
        self.description = description
        self.imgLink = imgLink
        self.htmlString = htmlString
    }
}

