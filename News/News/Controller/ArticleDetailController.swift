//
//  ArticleDetailController.swift
//  News
//
//  Created by Zheyu Shen on 5/2/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class ArticleDetailController: UIViewController {
    
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleSection: UILabel!
    @IBOutlet weak var articleDate: UILabel!
    @IBOutlet weak var articleDescription: UILabel!
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    
    let articleDetail = ArticleDetail()
    var articleID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        SwiftSpinner.show("Loading Detailed article..")
        getArticleDetail()
    }
    
    @IBAction func shareTweet(_ sender: Any) {
        let tweetText = "Check out this Article!"
        let tweetUrl = articleDetail.url
        let tweetHashtags = "CSCI_571_NewsApp"
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)&hashtags=\(tweetHashtags)"
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: escapedShareString)
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func addBookmark(_ sender: Any) {
        if !articleDetail.bookmark {
            let defaults = UserDefaults.standard
            let article = Article()
            article.image = articleDetail.image
            article.title = articleDetail.title
            article.time = articleDetail.date
            article.section = articleDetail.section
            article.articleID = articleDetail.articleID
            article.url = articleDetail.url
            if let decodedData = defaults.object(forKey: "bookmark") {
                do {
                    let decoder = JSONDecoder()
                    var savedArticles = try decoder.decode([Article].self, from: decodedData as! Data)
                    savedArticles.append(article)
                    let encoder = JSONEncoder()
                    let encodedData = try encoder.encode(savedArticles)
                    defaults.set(encodedData, forKey: "bookmark")
                } catch {
                    print("\(error)")
                }
            } else {
                do {
                    var savedArticles: [Article] = []
                    savedArticles.append(article)
                    let encoder = JSONEncoder()
                    let encodedData = try encoder.encode(savedArticles)
                    defaults.set(encodedData, forKey: "bookmark")
                } catch {
                    print("\(error)")
                }
            }
            self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
            self.bookmarkButton.image = UIImage(systemName: "bookmark.fill")
        }
    }
    
    @IBAction func viewFullArticle(_ sender: Any) {
        if let url = URL(string: articleDetail.url){
            UIApplication.shared.openURL(url)
        }
    }
    
    func getArticleDetail() {
        let params = ["id": articleID]
        Alamofire.request("https://csci571-homework9-news-api.ue.r.appspot.com/detail/", parameters: params).responseJSON { response in
            if let json = response.result.value {
                let articleJSON = JSON(json)["article"]
                self.createArticle(articleJSON: articleJSON)
                self.updateUI()
            }
        }
    }
    
    func createArticle(articleJSON: JSON) {
        articleDetail.image = articleJSON["image"].stringValue
        articleDetail.section = articleJSON["section"].stringValue
        articleDetail.date = formateDate(originalDate: articleJSON["date"].stringValue)
        articleDetail.url = articleJSON["url"].stringValue
        articleDetail.title = articleJSON["title"].stringValue
        articleDetail.description = articleJSON["description"].stringValue
        articleDetail.articleID = articleID
    }
    
    func formateDate(originalDate: String) -> String {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        let date = dateFormatter1.date(from: originalDate)!
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd MMM yyyy"
        return dateFormatter2.string(from: date)
    }
    
    func updateUI() {
        if articleDetail.image != "" {
            let url = URL(string: articleDetail.image)
            let data = try! Data(contentsOf: url!)
            let newImage = UIImage(data: data)
            articleImage.image = newImage
        } else {
            articleImage.image = UIImage(named: "default-guardian")
        }
        articleTitle.text = articleDetail.title
        articleSection.text = articleDetail.section
        articleDate.text = articleDetail.date
        let htmlText = articleDetail.description
        let attrStr = try? NSMutableAttributedString.init(data: htmlText.data(using: String.Encoding.utf16)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        articleDescription.text = attrStr?.string
        
        navigationItem.title = articleDetail.title
        
        if articleDetail.bookmark {
            bookmarkButton.image = UIImage(systemName: "bookmark.fill")
        } else {
            bookmarkButton.image = UIImage(systemName: "bookmark")
        }
      
        SwiftSpinner.hide()
    }

}
