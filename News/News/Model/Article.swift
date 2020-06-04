//
//  Article.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import Foundation

class Article: Codable{
    
    var image = ""
    var title = ""
    var time = ""
    var section = ""
    var articleID = ""
    var url = ""
    
    var bookmark: Bool {
        let defualt = UserDefaults.standard
        if let decodedData = defualt.object(forKey: "bookmark") {
            do {
                let decoder = JSONDecoder()
                let savedArticles = try decoder.decode([Article].self, from: decodedData as! Data)
                for article in savedArticles {
                    if articleID == article.articleID {
                        return true
                    }
                }
            } catch {
                print("\(error)")
            }
        }
        return false
    }
    
    
}
