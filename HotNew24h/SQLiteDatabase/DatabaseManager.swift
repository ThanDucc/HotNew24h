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
    
    var usersQueue: FMDatabaseQueue!
    var categoryQueue: FMDatabaseQueue!
    var favouriteQueue: FMDatabaseQueue!
    var seenQueue: FMDatabaseQueue!
    
    let DATABASE_NAME = "USERS_DATA"
    
    let USERS_TABLE = "users"
    let ID = "id"
    let PHONE_NUMBER = "phone_number"
    let LANGUAGE = "language"
    
    let FAVOURITE_TABLE = "favourite"
    let SEEN_TABLE = "seen"
    
    let TITTLE = "tittle"
    let PUB_DATE = "pubDate"
    let IMG_LINK = "imgLink"
    let LINK = "link"
    let DESCRIPTION = "description"
    let HTML_STRING = "html_string"
    
    let CATEGORY_TABLE = "category"
    let NAME = "name"
    let IS_HIDDEN = "is_hidden"
    let POSITION = "position"
    let LINK_CATEGORY = "link_category"
    let TYPE = "type"
    
    init() {
        usersQueue = FMDatabaseQueue(path: getDatabasePath())
        categoryQueue = FMDatabaseQueue(path: getDatabasePath())
        favouriteQueue = FMDatabaseQueue(path: getDatabasePath())
        seenQueue = FMDatabaseQueue(path: getDatabasePath())
    }
    
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
    
    // create database
    func createDatabase() {
        if database == nil {
            if !FileManager.default.fileExists(atPath: getDatabasePath()) {
                database = FMDatabase(path: getDatabasePath())
            }
        }
    }
    
    func createTables() {
        if database.open() {
            let queryUsersTable = "CREATE TABLE IF NOT EXISTS " + USERS_TABLE + " (" + ID + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " + PHONE_NUMBER + " TEXT NOT NULL, " + LANGUAGE + " TEXT NOT NULL)"
            
            let queryFavouriteTable = "CREATE TABLE IF NOT EXISTS " + FAVOURITE_TABLE + " (" + PHONE_NUMBER + " TEXT NOT NULL, " + TITTLE + " TEXT NOT NULL, " + PUB_DATE + " TEXT NOT NULL, " + DESCRIPTION + " TEXT NOT NULL, " + IMG_LINK + " TEXT NOT NULL, " + HTML_STRING + " TEXT NOT NULL, " + LINK + " TEXT NOT NULL)"
            
            let querySeenTable = "CREATE TABLE IF NOT EXISTS " + SEEN_TABLE + " (" + PHONE_NUMBER + " TEXT NOT NULL, " + TITTLE + " TEXT NOT NULL, " + PUB_DATE + " TEXT NOT NULL, " + DESCRIPTION + " TEXT NOT NULL, " + IMG_LINK + " TEXT NOT NULL, " + HTML_STRING + " TEXT NOT NULL, " + LINK + " TEXT NOT NULL, " + ID + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL)"

            let queryCategoryTable = "CREATE TABLE IF NOT EXISTS " + CATEGORY_TABLE + " (" + PHONE_NUMBER + " TEXT NOT NULL, " + NAME + " TEXT NOT NULL, " + IS_HIDDEN + " TEXT NOT NULL, " + POSITION + " TEXT NOT NULL, " + LINK_CATEGORY + " TEXT NOT NULL, " + TYPE + " TEXT NOT NULL)"
            
            do {
                try database.executeUpdate(queryUsersTable, values: nil)
                try database.executeUpdate(queryFavouriteTable, values: nil)
                try database.executeUpdate(querySeenTable, values: nil)
                try database.executeUpdate(queryCategoryTable, values: nil)
            } catch let err {
                print("Execute query failed. error: \(err.localizedDescription)")
            }
        }
    }
    
    func fetchUserData() -> [Users] {
        var listUsers: [Users] = []

        if database.open() {
            usersQueue.inTransaction { db, rollback in
                let querySelect = "SELECT * FROM " + USERS_TABLE
                do {
                    let result = try db.executeQuery(querySelect, values: nil)
                    while result.next() {
                        let user = Users(id: Int(result.int(forColumnIndex: 0)), phoneNumber: result.string(forColumnIndex: 1)!,language: result.string(forColumnIndex: 2)!)
                        listUsers.append(user)
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }

        return listUsers
    }
    
    func checkPhoneNumber(phoneNumber: String) -> Bool {
        if database.open() {
            var check = false
            usersQueue.inTransaction { db, rollback in
                let querySelect = "SELECT COUNT(*) FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    let result = try db.executeQuery(querySelect, values: nil)
                    while result.next() {
                        if result.int(forColumnIndex: 0) != 0 {
                            check = true
                        }
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
            return check
        }
        database.close()
        return false
    }
    
    func insertAnUser(phoneNumber: String, language: String) {
        if database.open() {
            usersQueue.inTransaction { db, rollback in
                let queryInsert = "INSERT INTO " + USERS_TABLE + " (" + PHONE_NUMBER + " ," + LANGUAGE + ") VALUES (?, ?)"
                do {
                    try db.executeUpdate(queryInsert, values: [phoneNumber, language])
                    db.commit()
                } catch let err {
                    print("Insert failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func getLanguage(phoneNumber: String) -> String {
        var language = ""
        if database.open() {
            usersQueue.inTransaction { db, rollback in
                let querySelect = "SELECT * FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    let result = try db.executeQuery(querySelect, values: nil)
                    while result.next() {
                        let lang = result.string(forColumnIndex: 2)!
                        language = lang
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
        
        return language
    }
    
    func deleteUserRow(phoneNumber: String) {
        if database.open() {
            usersQueue.inTransaction { db, rollback in
                let queryDelete = "DELETE FROM " + USERS_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Delete failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func updateLanguage(phoneNumber: String, language: String) {
        if database.open() {
            usersQueue.inTransaction { db, rollback in
                let queryDelete = "UPDATE " + USERS_TABLE + " SET " + LANGUAGE + " = '" + language + "' WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Update failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func createCategory(phoneNumber: String) {
        if database.open() {
            categoryQueue.inTransaction { db, rollback in
                let queryInsert = "INSERT INTO " + CATEGORY_TABLE + " (" + PHONE_NUMBER + " ," + NAME + " ," + IS_HIDDEN + " ," + POSITION + " ," + LINK_CATEGORY + " ," + TYPE + ") VALUES (?, ?, ?, ?, ?, ?)"

                let parseJson = ParseJson()
                parseJson.getData()

                let newsData = parseJson.newsData
                if newsData?.data.code == 200 {
                    let news: [Newspaper] = newsData!.data.news
                    for i in 0..<news.count {
                        for j in 0..<news[i].category.count {
                            try! db.executeUpdate(queryInsert, values: [phoneNumber, news[i].category[j].name, "false", j.description, news[i].link + news[i].category[j].path + news[i].endpoint, news[i].name])
                        }
                    }
                } else {
                    print("Get data from API failed")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }

    
    func getListCategory(phoneNumber: String, type: String) -> [CategoryDatabase] {
        var listCategory: [CategoryDatabase] = []
        if database.open() {
            categoryQueue.inTransaction { db, rollback in
                let querySelect = "SELECT * FROM " + CATEGORY_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "' AND " + TYPE + " = '" + type + "'"
                do {
                    let result = try db.executeQuery(querySelect, values: nil)
                    while result.next() {
                        let category = CategoryDatabase(phoneNumber: result.string(forColumnIndex: 0)!, name: result.string(forColumnIndex: 1)!, isHidden: result.string(forColumnIndex: 2)!, position: Int(result.int(forColumnIndex: 3)), linkCategory: result.string(forColumnIndex: 4)!, type: result.string(forColumnIndex: 5)!)
                        listCategory.append(category)
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
        listCategory = listCategory.sorted { $0.position < $1.position }
        
        return listCategory
    }
    
    func updateCategory(phoneNumber: String, position: Int, isHidden: String, name: String, type: String) {
        if database.open() {
            categoryQueue.inTransaction { db, rollback in
                let queryDelete = "UPDATE " + CATEGORY_TABLE + " SET " + POSITION + " = '" + String(position) + "', " + IS_HIDDEN + " = '" + isHidden + "' WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "' AND " + TYPE + " = '" + type + "' AND " + NAME + " = '" + name + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Update positon failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func deleteCategory(phoneNumber: String) {
        if database.open() {
            categoryQueue.inTransaction { db, rollback in
                let queryDelete = "DELETE FROM " + CATEGORY_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Delete failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func addToFavourite(phoneNumber: String, title: String, pubDate: String, description: String, imgLink: String, htmlString: String, link: String) {
        if database.open() {
            favouriteQueue.inTransaction { db, rollback in
                let queryInsert = "INSERT INTO " + FAVOURITE_TABLE + " (" + PHONE_NUMBER + " ," + TITTLE + " ," + PUB_DATE + " ," + DESCRIPTION + " ," + IMG_LINK + " ," + HTML_STRING + " ," + LINK + ") VALUES (?, ?, ?, ?, ?, ?, ?)"
                do {
                    try db.executeUpdate(queryInsert, values: [phoneNumber, title, pubDate, description, imgLink, htmlString, link])
                } catch let err {
                    print("Insert failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func getFavouriteList(phoneNumber: String, page: Int) -> [News] {
        var listNews: [News] = []
        if database.open() {
            favouriteQueue.inTransaction { db, rollback in
                let querySelect = "SELECT * FROM " + FAVOURITE_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'" + " LIMIT " + String(page) + ", 10"
                do {
                    let result = try db.executeQuery(querySelect, values: nil)
                    while result.next() {
                        let news = News(title: result.string(forColumnIndex: 1)!, pubDate: result.string(forColumnIndex: 2)!, link: result.string(forColumnIndex: 6)!, description: result.string(forColumnIndex: 3)!, imgLink: result.string(forColumnIndex: 4)!, htmlString: result.string(forColumnIndex: 5)!)
                        listNews.append(news)
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
        return listNews
    }
    
    func checkFavourite(tittle: String, phoneNumber: String) -> Bool {
        var check = false
        if database.open() {
            favouriteQueue.inTransaction { db, rollback in
                let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
                let queryCheck = "SELECT COUNT(*) FROM " + FAVOURITE_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    let result = try db.executeQuery(queryCheck, values: nil)
                    while result.next() {
                        if result.int(forColumnIndex: 0) != 0 {
                            check = true
                        }
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
        return check
    }
    
    func deleteFavouriteRow(tittle: String, phoneNumber: String) {
        if database.open() {
            favouriteQueue.inTransaction { db, rollback in
                let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
                let queryDelete = "DELETE FROM " + FAVOURITE_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Delete failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func deleteFavouriteRow(phoneNumber: String) {
        if database.open() {
            favouriteQueue.inTransaction { db, rollback in
                let queryDelete = "DELETE FROM " + FAVOURITE_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Delete failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func addToSeen(phoneNumber: String, title: String, pubDate: String, description: String, imgLink: String, htmlString: String, link: String) {
        if database.open() {
            seenQueue.inTransaction { db, rollback in
                let queryInsert = "INSERT INTO " + SEEN_TABLE + " (" + PHONE_NUMBER + " ," + TITTLE + " ," + PUB_DATE + " ," + DESCRIPTION + " ," + IMG_LINK + " ," + HTML_STRING + " ," + LINK + ") VALUES (?, ?, ?, ?, ?, ?, ?)"
                do {
                    try db.executeUpdate(queryInsert, values: [phoneNumber, title, pubDate, description, imgLink, htmlString, link])
                } catch let err {
                    print("Insert failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func getSeenList(phoneNumber: String, page: Int) -> [News] {
        var listNews: [News] = []
        if database.open() {
            seenQueue.inTransaction { db, rollback in
                let querySelect = "SELECT * FROM " + SEEN_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'" + "ORDER BY " + ID + " DESC" + " LIMIT " + String(page) + ", 10"
                do {
                    let result = try db.executeQuery(querySelect, values: nil)
                    while result.next() {
                        let news = News(title: result.string(forColumnIndex: 1)!, pubDate: result.string(forColumnIndex: 2)!, link: result.string(forColumnIndex: 6)!, description: result.string(forColumnIndex: 3)!, imgLink: result.string(forColumnIndex: 4)!, htmlString: result.string(forColumnIndex: 5)!)
                        listNews.append(news)
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
        return listNews
    }
    
    func checkSeen(tittle: String, phoneNumber: String) -> Bool {
        var check = false
        if database.open() {
            seenQueue.inTransaction { db, rollback in
                let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
                let queryCheck = "SELECT COUNT(*) FROM " + SEEN_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    let result = try db.executeQuery(queryCheck, values: nil)
                    while result.next() {
                        if result.int(forColumnIndex: 0) != 0 {
                            check = true
                        }
                    }
                } catch let err {
                    print("Fetch failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
        return check
    }
    
    func deleteSeenRow(tittle: String, phoneNumber: String) {
        if database.open() {
            seenQueue.inTransaction { db, rollback in
                let Tittle = tittle.replacingOccurrences(of: "'", with: "\\\\")
                let queryDelete = "DELETE FROM " + SEEN_TABLE + " WHERE " + TITTLE + " = '" + Tittle + "' AND " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Delete failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
    func deleteSeenRow(phoneNumber: String) {
        if database.open() {
            seenQueue.inTransaction { db, rollback in
                let queryDelete = "DELETE FROM " + SEEN_TABLE + " WHERE " + PHONE_NUMBER + " = '" + phoneNumber + "'"
                do {
                    try db.executeUpdate(queryDelete, values: nil)
                } catch let err {
                    print("Delete failed, error: \(err.localizedDescription)")
                    rollback.pointee = true
                }
            }
        }
        database.close()
    }
    
}

