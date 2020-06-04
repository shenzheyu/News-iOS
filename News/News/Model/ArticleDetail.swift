//
//  ArticleDetail.swift
//  News
//
//  Created by Zheyu Shen on 5/4/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import Foundation

class ArticleDetail {
    var title = ""
    var description = ""
    var date = ""
    var image = ""
    var url = ""
    var section = ""
    var articleID = ""
   
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
