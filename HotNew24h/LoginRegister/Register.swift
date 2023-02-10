//
//  Register.swift
//  HotNew24h
//
//  Created by ThanDuc on 31/01/2023.
//

import Foundation

class Register {
    
    func registerAccount(userId: String) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DatabaseManager.shared.insertAnUser(phoneNumber: userId, language: "en")
        DatabaseManager.shared.createCategory(phoneNumber: userId)
        dispatchGroup.leave()
    }
    
}
