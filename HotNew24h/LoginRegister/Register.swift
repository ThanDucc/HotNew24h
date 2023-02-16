//
//  Register.swift
//  HotNew24h
//
//  Created by ThanDuc on 31/01/2023.
//

import Foundation

class Register {
    
    func registerAccount(userId: String, language: String) {
        DispatchQueue.global().async {
            DatabaseManager.shared.insertAnUser(phoneNumber: userId)
        }
        
        DispatchQueue.global().async {
            DatabaseManager.shared.createCategory(phoneNumber: userId)
        }
    }
    
}
