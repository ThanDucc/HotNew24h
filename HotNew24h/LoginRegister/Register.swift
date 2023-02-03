//
//  Register.swift
//  HotNew24h
//
//  Created by ThanDuc on 31/01/2023.
//

import Foundation

class Register {
    var list: [String] = ["Home", "World", "News", "Education", "Sports", "Health", "Science", "Technology", "Business", "Entertainment"]
    var listKeyUrl: [String] = ["tin-moi-nhat", "the-gioi", "thoi-su", "giao-duc", "the-thao", "suc-khoe", "khoa-hoc", "nhip-song-so", "kinh-doanh", "giai-tri"]

    func getStringList(list: [String]) -> String {
        var stringList = ""
        for i in 0..<list.count - 1 {
            stringList = stringList + list[i] + "|"
        }
        stringList += list[list.count-1]
        return stringList
    }
    
    func registerAccount(userId: String) {
        let stringList = self.getStringList(list: self.list)
        let stringListKeyUrl = self.getStringList(list: self.listKeyUrl)
        
        if !DatabaseManager.shared.checkPhoneNumber(phoneNumber: userId) {
            DatabaseManager.shared.insertAnUser(phoneNumber: userId, language: "en", category: stringList, keyCategory: stringListKeyUrl)
        }
    }
    
}
