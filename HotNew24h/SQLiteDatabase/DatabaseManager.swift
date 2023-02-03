//
//  DatabaseManager.swift
//  HotNew24h
//
//  Created by ThanDuc on 03/01/2023.
//

import Foundation
import FMDB

class DatabaseManager {
    public static let shared = DatabaseManager()
    var database: FMDatabase!
    
    let DATABASE_NAME = "USERS_DATA"
    
    let USERS_TABLE = "users"
    let ID = "id"
    let PHONE_NUMBER = "phone_number"
    let LANGUAGE = "language"
    let CATEGORY = "category"
    let KEY_CATEGORY = "key_category"
    
    let FAVOURITE_TABLE = "favourite"
    let SEEN_TABLE = "seen"
    
    let TITTLE = "tittle"
    let PUB_DATE = "pubDate"
    let IMG_LINK = "imgLink"
    let LINK = "link"
    let DESCRIPTION = "description"
    let HTML_STRING = "html_string"
    
    // create path to save database
    func getDatabasePath() -> String {
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = directoryPath.first!.appendingPathComponent(DATABASE_NAME + ".db")
        return path.description
    }
    
    // case database had in app
    func getPathOfExistDB() -> String? {
        if let path = Bundle.main.path(forResource: DATABASE_NAME, ofType: ".db") {
            return path
        }
        return nil
    }
    
    // tao database
    func createDatabase() {
        if database == nil {
            if !FileManager.default.fileExists(atPath: getDatabasePath()) {
                database = FMDatabase(path: getDatabasePath())
            }
        }
    }
    
    // Create table
    func createTables() {
        if database.open() {
            let queryUsersTable = "CREATE TABLE IF NOT EXISTS " + USERS_TABLE + " (" + ID + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " + PHONE_NUMBER + " TEXT NOT NULL, " + LANGUAGE + " TEXT NOT NULL, " + CATEGORY + " TEXT NOT NULL, " + KEY_CATEGORY + " TEXT NOT NULL)"
            
            let queryFavouriteTable = "CREATE TABLE IF NOT EXISTS " + FAVOURITE_TABLE + " (" + PHONE_NUMBER + " TEXT NOT NULL, " + TITTLE + " TEXT NOT NULL, " + PUB_DATE + " TEXT NOT NULL, " + DESCRIPTION + " TEXT NOT NULL, " + IMG_LINK + " TEXT NOT NULL, " + HTML_STRING + " TEXT NOT NULL, " + LINK + " TEXT NOT NULL)"
            
            let querySeenTable = "CREATE TABLE IF NOT EXISTS " + SEEN_TABLE + " (" + PHONE_NUMBER + " TEXT NOT NULL, " + TITTLE + " TEXT NOT NULL, " + PUB_DATE + " TEXT NOT NULL, " + DESCRIPTION + " TEXT NOT NULL, " + IMG_LINK + " TEXT NOT NULL, " + HTML_STRING + " TEXT NOT NULL, " + LINK + " TEXT NOT NULL, " + ID + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)"

            do {
                try database.executeUpdate(queryUsersTable, values: nil)
                try database.executeUpdate(queryFavouriteTable, values: nil)
                try database.executeUpdate(querySeenTable, values: nil)
            } catch let err {
                print("Execute query failed. error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func fetchUserData() -> [Users] {
        var listUsers: [Users] = []

        if database.open() {
            let querySelect = "SELECT * FROM " + USERS_TABLE
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    let user = Users(id: Int(result.int(forColumnIndex: 0)), phoneNumber: result.string(forColumnIndex: 1)!,language: result.string(forColumnIndex: 2)!, category: result.string(forColumnIndex: 3)!, keyCategory: result.string(forColumnIndex: 4)!)
                    listUsers.append(user)
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()

        return listUsers
    }
    
    func checkPhoneNumber(phoneNumber: String) -> Bool {
        if database.open() {
            let querySelect = "SELECT COUNT(*) FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    if result.int(forColumnIndex: 0) != 0 {
                        return true
                    }
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        return false
    }
    
    func insertAnUser(phoneNumber: String, language: String, category: String, keyCategory: String) {
        if database.open() {
            let queryInsert = "INSERT INTO " + USERS_TABLE + " (" + PHONE_NUMBER + " ," + LANGUAGE + " ," + CATEGORY + " ," + KEY_CATEGORY + ") VALUES (?, ?, ?, ?)"
            do {
               try database.executeUpdate(queryInsert, values: [phoneNumber, language, category, keyCategory])
            } catch let err {
               print("Insert failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func getListCategory(phoneNumber: String) -> [String] {
        var listCategory: [String] = []
        
        if database.open() {
            let querySelect = "SELECT * FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    let stringList = result.string(forColumnIndex: 3)!
                    listCategory = stringList.components(separatedBy: "|")
                    return listCategory
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        
        return listCategory
    }
    
    func getListKeyUrl(phoneNumber: String) -> [String] {
        var listKeyUrl: [String] = []
        
        if database.open() {
            let querySelect = "SELECT * FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    let stringList = result.string(forColumnIndex: 4)!
                    listKeyUrl = stringList.components(separatedBy: "|")
                    return listKeyUrl
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        
        return listKeyUrl
    }
    
    func getLanguage(phoneNumber: String) -> String {
        if database.open() {
            let querySelect = "SELECT * FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    let language = result.string(forColumnIndex: 2)!
                    return language
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        
        return ""
    }
    
    func deleteUserRow(phoneNumber: String) {
        if database.open() {
            let queryDelete = "DELETE FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
               try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Delete failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func updateLanguage(phoneNumber: String, language: String) {
        if database.open() {
            let queryDelete = "UPDATE " + USERS_TABLE + " SET " + LANGUAGE + " = '" + language + "' WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
               try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Update failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func updateCategory(phoneNumber: String, category: String, keyCategory: String) {
        if database.open() {
            let queryDelete = "UPDATE " + USERS_TABLE + " SET " + CATEGORY + " = '" + category + "', " + KEY_CATEGORY + " = '" + keyCategory + "' WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
               try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Update failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func addToFavourite(phoneNumber: String, title: String, pubDate: String, description: String, imgLink: String, htmlString: String, link: String) {
        if database.open() {
            let queryInsert = "INSERT INTO " + FAVOURITE_TABLE + " (" + PHONE_NUMBER + " ," + TITTLE + " ," + PUB_DATE + " ," + DESCRIPTION + " ," + IMG_LINK + " ," + HTML_STRING + " ," + LINK + ") VALUES (?, ?, ?, ?, ?, ?, ?)"
            do {
                try database.executeUpdate(queryInsert, values: [phoneNumber, title, pubDate, description, imgLink, htmlString, link])
            } catch let err {
               print("Insert failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func getFavouriteList(phoneNumber: String, page: Int) -> [News] {
        var listNews: [News] = []
        if database.open() {
            let querySelect = "SELECT * FROM " + FAVOURITE_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'" + " LIMIT " + String(page) + ", 10"
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    let news = News(title: result.string(forColumnIndex: 1)!, pubDate: result.string(forColumnIndex: 2)!, link: result.string(forColumnIndex: 6)!, description: result.string(forColumnIndex: 3)!, imgLink: result.string(forColumnIndex: 4)!, htmlString: result.string(forColumnIndex: 5)!)
                    listNews.append(news)
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        return listNews
    }
    
    func checkFavourite(tittle: String, phoneNumber: String) -> Bool {
        if database.open() {
            let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
            let queryCheck = "SELECT COUNT(*) FROM " + FAVOURITE_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                let result = try database.executeQuery(queryCheck, values: nil)
                while result.next() {
                    if result.int(forColumnIndex: 0) != 0 {
                        return true
                    }
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        return false
    }
    
    func deleteFavouriteRow(tittle: String, phoneNumber: String) {
        if database.open() {
            let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
            let queryDelete = "DELETE FROM " + FAVOURITE_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Delete failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func deleteFavouriteRow(phoneNumber: String) {
        if database.open() {
            let queryDelete = "DELETE FROM " + FAVOURITE_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Delete failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func addToSeen(phoneNumber: String, title: String, pubDate: String, description: String, imgLink: String, htmlString: String, link: String) {
        if database.open() {
            let queryInsert = "INSERT INTO " + SEEN_TABLE + " (" + PHONE_NUMBER + " ," + TITTLE + " ," + PUB_DATE + " ," + DESCRIPTION + " ," + IMG_LINK + " ," + HTML_STRING + " ," + LINK + ") VALUES (?, ?, ?, ?, ?, ?, ?)"
            do {
                try database.executeUpdate(queryInsert, values: [phoneNumber, title, pubDate, description, imgLink, htmlString, link])
            } catch let err {
               print("Insert failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func getSeenList(phoneNumber: String, page: Int) -> [News] {
        var listNews: [News] = []
        if database.open() {
            let querySelect = "SELECT * FROM " + SEEN_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'" + "ORDER BY " + ID + " DESC" + " LIMIT " + String(page) + ", 10"
            do {
                let result = try database.executeQuery(querySelect, values: nil)
                while result.next() {
                    let news = News(title: result.string(forColumnIndex: 1)!, pubDate: result.string(forColumnIndex: 2)!, link: result.string(forColumnIndex: 6)!, description: result.string(forColumnIndex: 3)!, imgLink: result.string(forColumnIndex: 4)!, htmlString: result.string(forColumnIndex: 5)!)
                    listNews.append(news)
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        return listNews
    }
    
    func checkSeen(tittle: String, phoneNumber: String) -> Bool {
        if database.open() {
            let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
            let queryCheck = "SELECT COUNT(*) FROM " + SEEN_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                let result = try database.executeQuery(queryCheck, values: nil)
                while result.next() {
                    if result.int(forColumnIndex: 0) != 0 {
                        return true
                    }
                }
            } catch let err {
               print("Fetch failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
        return false
    }
    
    func deleteSeenRow(tittle: String, phoneNumber: String) {
        if database.open() {
            let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
            let queryDelete = "DELETE FROM " + SEEN_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Delete failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
    func deleteSeenRow(phoneNumber: String) {
        if database.open() {
            let queryDelete = "DELETE FROM " + SEEN_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
            do {
                try database.executeUpdate(queryDelete, values: nil)
            } catch let err {
               print("Delete failed, error: \(err.localizedDescription)")
            }
        }
        database.close()
    }
    
}

