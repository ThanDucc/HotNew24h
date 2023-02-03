//
//  Users.swift
//  HotNew24h
//
//  Created by ThanDuc on 03/01/2023.
//

import Foundation

class Users {
    var id: Int
    var phoneNumber: String
    var language: String
    var category: String
    var keyCategory: String
    
    init(id: Int, phoneNumber: String, language: String, category: String, keyCategory: String) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.language = language
        self.category = category
        self.keyCategory = keyCategory
    }
}
