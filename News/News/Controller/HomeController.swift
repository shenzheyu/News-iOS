//
//  HomeController.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Toast_Swift

class HomeController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    let locationManager = CLLocationManager()
    let weather = Weather()
    var articles: [Article] = []
    var suggests: [String] = []
    let weatherAppid = "0cdfcdb26626ad213283e572ba722929"
    let guardianAppid = "e635f283-c7d0-4762-bf39-c713fa65f063"
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isSearching: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // show spinner
        SwiftSpinner.show("Loading Home Page..")
        
        // get weather
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
        
        // get headline
        homeTableView.delegate = self
        homeTableView.dataSource = self
        requestHeadlines()
    
        // add refresh
        homeTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshHeadlineData(_:)), for: .valueChanged)
        
        // add search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter keyword.."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let localLocation = locations[0]
        getCity(location: localLocation)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! ArticleDetailController
            let cell = sender as! ArticleCell
            let row = homeTableView.indexPath(for: cell)!.row
            vc.articleID = articles[row].articleID
        } else if segue.identifier == "showResult" {
            let vc = segue.destination as! SearchResultController
            let cell = sender as! UITableViewCell
            let row = homeTableView.indexPath(for: cell)!.row
            vc.keyword = suggests[row]
        }
    }

}

extension HomeController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getCity(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if error == nil {
                if let firstLocation = placemarks?[0] {
                    self.weather.city = firstLocation.locality!
                    self.weather.area = firstLocation.administrativeArea!
                    let params = ["q": self.weather.city, "units": "metric", "appid": self.weatherAppid]
                    self.getWeather(params: params)
                }
            }
        })
    }
    
    func getWeather(params: [String: String]) {
        Alamofire.request("https://api.openweathermap.org/data/2.5/weather", parameters: params).responseJSON { response in
            if let json = response.result.value {
                let weather = JSON(json)
                self.createWeather(weatherJSON: weather)
                self.homeTableView.reloadData()
            }
        }
    }
    
    func createWeather(weatherJSON: JSON) {
        weather.temp = Int(round(weatherJSON["main", "temp"].doubleValue))
        weather.summary = weatherJSON["weather", 0, "main"].stringValue
    }
    
    
}

extension HomeController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isSearching {
            if section == 0 {
                return 1
            } else {
                return articles.count
            }
        } else {
            return suggests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isSearching {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "weather", for: indexPath) as! WeatherCell
                
                cell.cityLabel.text = weather.city
                cell.stateLabel.text = weather.state
                cell.tempLabel.text = "\(weather.temp)˚C"
                cell.conditionLabel.text = weather.summary
                cell.conditionImage.image = UIImage(named: weather.image)
                cell.conditionImage.layer.cornerRadius = 10
                cell.conditionImage.layer.masksToBounds = true

                cell.contentView.sendSubviewToBack(cell.conditionImage)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath) as! ArticleCell
                
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggest", for: indexPath)
            cell.textLabel?.text = suggests[indexPath.row]
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isSearching {
            return 2
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isSearching {
            if indexPath.section == 0 {
                return 107
            } else {
                return 118
            }
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        homeTableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView.init()
        headView.backgroundColor = UIColor.init(white: 1, alpha: 1)
        return headView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init()
        footerView.backgroundColor = UIColor.init(white: 1, alpha: 1)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
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
                    self.homeTableView.reloadData()
                        
                }
                
            }

            return UIMenu(title: "menu", children: [share, bookmark])
        }
    }
    
    func requestHeadlines() {
        Alamofire.request("https://csci571-homework9-news-api.ue.r.appspot.com/articles/home").responseJSON{ response in
            if let json = response.result.value {
                let articlesJSON = JSON(json)["articles"]
                self.createHeadlines(articlesJSON: articlesJSON)
                self.homeTableView.reloadData()
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

    
}

extension HomeController {
    @objc func refreshHeadlineData(_ sender: Any) {
        updateHeadlines()
    }
    
    func updateHeadlines() {
        Alamofire.request("https://csci571-homework9-news-api.ue.r.appspot.com/articles/home").responseJSON{ response in
            if let json = response.result.value {
                let articlesJSON = JSON(json)["articles"]
                self.createHeadlines(articlesJSON: articlesJSON)
                self.homeTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
}

extension HomeController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        searchText(searchBar.text!)
    }
    
    func searchText(_ searchText: String) {
        let headers = ["Ocp-Apim-Subscription-Key": "dd9f1e3ac20e450696f601093186050d"]
        let params = ["q": searchText]
        Alamofire.request("https://csci571-homework8.cognitiveservices.azure.com/bing/v7.0/suggestions", parameters: params, headers: headers).responseJSON { response in
            if let json = response.result.value {
                let suggest = JSON(json)
                self.createSuggest(suggestJSON: suggest)
                self.homeTableView.reloadData()
            }
        }
    }
    
    func createSuggest(suggestJSON: JSON) {
        let searchSuggestions = suggestJSON["suggestionGroups", 0, "searchSuggestions"]
        suggests.removeAll()
        for searchSuggestion in searchSuggestions {
            suggests.append(searchSuggestion.1["displayText"].stringValue )
        }
    }
}

extension HomeController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
        selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchText(searchBar.text!)
    }
}

extension HomeController: addBookmarkDelegate {
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
            self.homeTableView.reloadData()
                
        }
    }
}
