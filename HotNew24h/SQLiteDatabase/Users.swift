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
    
    init(id: Int, phoneNumber: String, language: String) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.language = language
    }
}
