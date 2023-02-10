//
//  ParseJSON.swift
//  HelloIOS
//
//  Created by ThanDuc on 10/02/2023.
//

import Foundation

class ParseJson {
    
    var newsData: NewsData?
    let fileName = "News_json"
        
    func getData() {
        let url = Bundle.main.url(forResource: fileName, withExtension: ".txt")
        do {
            let data = try Data(contentsOf: url!)
            let newsData = try? JSONDecoder().decode(NewsData.self, from: data)
            self.newsData = newsData
        } catch {
            print("Error")
        }
    }
}
