//
//  ParseXML_VNExpress.swift
//  HotNew24h
//
//  Created by ThanDuc on 13/01/2023.
//

import Foundation

class ParseXML_VNExpress: NSObject, XMLParserDelegate {

    var xmlParser: XMLParser!
        
    var currentParsedElement = ""
    var weAreInsideAnItem = false
        
    var news = News(title: "", pubDate: "", link: "", description: "", imgLink: "", htmlString: "")
    var listNews : [News] = []
        
    let formatter = DateFormatter()
    
    var tempTitle = ""
    var tempDateString = ""
    var tempDescription = ""
    var tempLink = ""
    
    func getEpisode(urlString: String, completion: @escaping (Bool) -> Void) {
        self.listNews = []
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error ?? "Error getting url data")
                    completion(false)
                } else {
                    if data != nil {
                        self.xmlParser = XMLParser(data: data!)
                        self.xmlParser.delegate = self
                        self.xmlParser.parse()
                        completion(true)
                    }
                }
            }
            .resume()
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            weAreInsideAnItem = true
            news = News(title: "", pubDate: "", link: "", description: "", imgLink: "", htmlString: "")
        }
        
        if weAreInsideAnItem {
            switch elementName {
                case "title":
                    currentParsedElement = elementName
                    tempTitle = ""
                case "pubDate":
                    currentParsedElement = elementName
                    tempDateString = ""
                case "link":
                    currentParsedElement = elementName
                    tempLink = ""
                case "description":
                    currentParsedElement = elementName
                    tempDescription = ""
                default:
                    break
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if weAreInsideAnItem {
            switch currentParsedElement {
                case "description":
                    tempDescription = tempDescription + string
                case "pubDate":
                    tempDateString = tempDateString + string
                case "title":
                    tempTitle = tempTitle + string
                case "link":
                    tempLink = tempLink + string
                default:
                    break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if weAreInsideAnItem {
            switch elementName {
                case "title":
                    currentParsedElement = ""
                case "pubDate":
                    currentParsedElement = ""
                case "description":
                    currentParsedElement = ""
                case "link":
                    currentParsedElement = ""
                default:
                    break
            }
        }
        if elementName == "item" {
            let img = tempDescription.components(separatedBy: "<img src=\"")

            var imgLink = ""
            if img.count > 1 {
                imgLink = img[1].components(separatedBy: "\" >")[0]
            }
            
            let des = tempDescription.components(separatedBy: ">")
            
            if des.count > 1 {
                tempDescription = des[4]
            } else {
                tempDescription = des[0]
            }
            
            news = News(title: tempTitle, pubDate: tempDateString, link: tempLink, description: tempDescription, imgLink: imgLink, htmlString: "")
            listNews.append(news)
            
            weAreInsideAnItem = false
        }
    }
}


