//
//  CategoryDatabase.swift
//  HotNew24h
//
//  Created by ThanDuc on 10/02/2023.
//

import Foundation

class CategoryDatabase {
    internal init(phoneNumber: String, name: String, isHidden: String, position: Int, linkCategory: String, type: String) {
        self.phoneNumber = phoneNumber
        self.name = name
        self.isHidden = isHidden
        self.position = position
        self.linkCategory = linkCategory
        self.type = type
    }
    
    var phoneNumber: String
    var name: String
    var isHidden: String
    var position: Int
    var linkCategory: String
    var type: String
}
