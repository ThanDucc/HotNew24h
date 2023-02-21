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
        
    func getData(completion: @escaping(Bool) -> Void) {
        let url = Bundle.main.url(forResource: fileName, withExtension: ".txt")
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url!)
                let newsData = try? JSONDecoder().decode(NewsData.self, from: data)
                DispatchQueue.main.async {
                    self.newsData = newsData
                    completion(true)
                }
            } catch {
                print("Error to parse JSON")
            }
        }
    }
}
