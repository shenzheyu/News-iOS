//
//  HeadlinesScienceController.swift
//  News
//
//  Created by Zheyu Shen on 5/7/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftyJSON
import SwiftSpinner

class HeadlinesScienceController: UITableViewController {

    var articles: [Article] = []
    let guardianAppid = "e635f283-c7d0-4762-bf39-c713fa65f063"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show("Loading SCIENCE Headlines..")
        requestHeadlines()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath) as! ArticleWithMarginCell
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        if articles[indexPath.row].image != "" {
            let url = URL(string: articles[indexPath.row].image)
            let data = try! Data(contentsOf: url!)
            let newImage = UIImage(data: data)
            cell.articleImage.image = newImage
        } else {
            cell.articleImage.image = UIImage(named: "default-guardian")
        }
        cell.articleImage.layer.cornerRadius = 10
        cell.articleImage.layer.masksToBounds = true
        cell.titleLabel.text = "\(articles[indexPath.row].title)"
        cell.dateLabel.text = articles[indexPath.row].time
        cell.sectionLabel.text = "| \(articles[indexPath.row].section)"
        
        if articles[indexPath.row].bookmark {
            cell.bookmarkImage.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            cell.bookmarkImage.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        
        cell.delegate = self
        cell.articleID = articles[indexPath.row].articleID
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

            // Create an action for sharing
            let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter")) { action in
                let tweetText = "Check out this Article!"
                let tweetUrl = self.articles[indexPath.row].url
                let tweetHashtags = "CSCI_571_NewsApp"
                let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)&hashtags=\(tweetHashtags)"
                let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                let url = URL(string: escapedShareString)
                UIApplication.shared.openURL(url!)
            }
            
            let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { action in
                if !self.articles[indexPath.row].bookmark {
                    let defaults = UserDefaults.standard
                    if let decodedData = defaults.object(forKey: "bookmark") {
                        do {
                            let decoder = JSONDecoder()
                            var savedArticles = try decoder.decode([Article].self, from: decodedData as! Data)
                            savedArticles.append(self.articles[indexPath.row])
                            let encoder = JSONEncoder()
                            let encodedData = try encoder.encode(savedArticles)
                            defaults.set(encodedData, forKey: "bookmark")
                        } catch {
                            print("\(error)")
                        }
                        
                    } else {
                        do {
                            var savedArticles: [Article] = []
                            savedArticles.append(self.articles[indexPath.row])
                            let encoder = JSONEncoder()
                            let encodedData = try encoder.encode(savedArticles)
                            defaults.set(encodedData, forKey: "bookmark")
                        } catch {
                            print("\(error)")
                        }
                    }
                    self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
                    self.tableView.reloadData()
                }
                
            }

            return UIMenu(title: "menu", children: [share, bookmark])
        }
    }
    
    
    func requestHeadlines() {
        Alamofire.request("https://csci571-homework9-news-api.ue.r.appspot.com/articles/science").responseJSON{ response in
            if let json = response.result.value {
                let articlesJSON = JSON(json)["articles"]
                self.createHeadlines(articlesJSON: articlesJSON)
                self.tableView.reloadData()
                SwiftSpinner.hide()
            }
        }
    }
    
    func createHeadlines(articlesJSON: JSON) {
        articles.removeAll()
        
        for articleJSON in articlesJSON {
            let article = Article()
            if articleJSON.1["image"].stringValue != "" {
                article.image = articleJSON.1["image"].stringValue
            }
            article.title = articleJSON.1["title"].stringValue
            article.section = articleJSON.1["section"].stringValue
            article.articleID = articleJSON.1["id"].stringValue
            article.time = getTime(date: articleJSON.1["date"].stringValue)
            article.url = articleJSON.1["url"].stringValue
            articles.append(article)
        }
    }
    
    func getTime(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone.init(abbreviation: "GMT")
        let pubDate = dateFormatter.date(from: date)!
        let currentDate = Date()
        
        let components : NSCalendar.Unit = [.second, .minute, .hour]
        let difference = (Calendar.current as NSCalendar).components(components, from: pubDate, to: currentDate, options: [])
        
        var res = ""
        if difference.hour! > 0 {
            res = "\(difference.hour!)h ago"
        } else if difference.minute! > 0 {
            res = "\(difference.minute!)m ago"
        } else {
            res = "\(difference.second!)s ago"
        }

        return res
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! ArticleDetailController
            let cell = sender as! ArticleWithMarginCell
            let row = tableView.indexPath(for: cell)!.row
            vc.articleID = articles[row].articleID
        }
    }

}

extension HeadlinesScienceController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SCIENCE")
    }
}


extension HeadlinesScienceController: addBookmarkDelegate {
    func addBookmark(articleID: String) {
        var article: Article = Article()
        for art in articles {
            if art.articleID == articleID {
                article = art
                break
            }
        }
        if !article.bookmark {
            let defaults = UserDefaults.standard
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
            self.tableView.reloadData()
                
        }
    }
}
