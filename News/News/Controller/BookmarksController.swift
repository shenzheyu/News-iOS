//
//  BookmarksController.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit

class BookmarksController: UIViewController {
    
    var articles: [Article] = []

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noLabel.isHidden = true
        view.bringSubviewToFront(noLabel)

        collectionView.delegate = self
        collectionView.dataSource = self
        getBookmarks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getBookmarks()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BookmarksController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "article", for: indexPath) as! ArticleCollectionCell
        
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
        cell.dateLabel.text = parseTime(originalTime: articles[indexPath.row].time)
        cell.sectionLabel.text = "| \(articles[indexPath.row].section)"
        
        cell.delegate = self
        cell.articleID = articles[indexPath.row].articleID
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in

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
                
                self.articles.remove(at: indexPath.row)
                do {
                    let defaults = UserDefaults.standard
                    let encoder = JSONEncoder()
                    let encodedData = try encoder.encode(self.articles)
                    defaults.set(encodedData, forKey: "bookmark")
                } catch {
                    print("\(error)")
                }
                
                self.view.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
                if self.articles.isEmpty {
                    self.noLabel.isHidden = false
                }
                collectionView.reloadData()
                
            }

            return UIMenu(title: "menu", children: [share, bookmark])
        }
    }
    
    func parseTime(originalTime: String) -> String {
        var time = ""
        if originalTime.hasSuffix("ago") {
            let length = originalTime.count
            if let sIndex = originalTime.firstIndex(of: "s"){
                let timeStamp = Double(originalTime.substring(to: sIndex))!
                let timeInterval = TimeInterval.init(timeStamp)
                let now = Date()
                let prev = now - timeInterval
                let datefommater = DateFormatter()
                datefommater.dateFormat = "dd MMM"
                time = datefommater.string(from: prev)
            }
            if let mIndex = originalTime.firstIndex(of: "m") {
                let timeStamp = Double(originalTime.substring(to: mIndex))!
                let timeInterval = TimeInterval.init(timeStamp * 60)
                let now = Date()
                let prev = now - timeInterval
                let datefommater = DateFormatter()
                datefommater.dateFormat = "dd MMM"
                time = datefommater.string(from: prev)
            }
            if let hIndex = originalTime.firstIndex(of: "h"){
                let timeStamp = Double(originalTime.substring(to: hIndex))!
                let timeInterval = TimeInterval.init(timeStamp * 60 * 60)
                let now = Date()
                let prev = now - timeInterval
                let datefommater = DateFormatter()
                datefommater.dateFormat = "dd MMM"
                time = datefommater.string(from: prev)
            }
        } else {
            let dateFomatter = DateFormatter()
            dateFomatter.dateFormat = "dd MMM yyyy"
            let date = dateFomatter.date(from: originalTime)!
            dateFomatter.dateFormat = "dd MMM"
            time = dateFomatter.string(from: date)
        }
        return time
    }
    
}

extension BookmarksController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 220)
    }
    
}

extension BookmarksController {
    func getBookmarks() {
        let defaults = UserDefaults.standard
        if let decodedData = defaults.object(forKey: "bookmark") {
            noLabel.isHidden = true
            do {
                let decoder = JSONDecoder()
                articles = try decoder.decode([Article].self, from: decodedData as! Data)
                collectionView.reloadData()
            } catch {
                print("\(error)")
            }
        }
        if articles.isEmpty {
            noLabel.isHidden = false
        }
    }
}

extension BookmarksController: removeBookmarkDelegate {
    func removeBoomark(ArticleID: String) {
        for i in 0..<articles.count {
            let article = articles[i]
            if article.articleID == ArticleID {
                articles.remove(at: i)
                break
            }
        }
        
        do {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(articles)
            defaults.set(encodedData, forKey: "bookmark")
        } catch {
            print("\(error)")
        }
        
        self.view.makeToast("Article removed from Bookmarks", duration: 3.0, position: .bottom)
        if articles.isEmpty {
            noLabel.isHidden = false
        }
        collectionView.reloadData()

    }
    
    
}
