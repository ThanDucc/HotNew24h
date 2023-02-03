//
//  LocalizedString.swift
//  HotNew24h
//
//  Created by ThanDuc on 12/01/2023.
//

import Foundation

extension String {
    func LocalizedString(str: String) -> String {
        let path = Bundle.main.path(forResource: str, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
