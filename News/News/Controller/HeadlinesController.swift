//
//  HeadlinesController.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftyJSON

class HeadlinesController: ButtonBarPagerTabStripViewController {
    
    var suggests: [String] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isSearching: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    @IBOutlet weak var headlineTableView: UITableView!
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = UIColor.init(red: 61.0/255.0, green: 122.0/255.0, blue: 213.0/255.0, alpha: 1.0)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = UIColor.init(red: 79.0/255.0, green: 126.0/255.0, blue: 193.0/255.0, alpha: 1.0)
        }
        
        super.viewDidLoad()
        
        // add search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter keyword.."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // hide tableview
        headlineTableView.delegate = self
        headlineTableView.dataSource = self
        headlineTableView.isHidden = true
        view.bringSubviewToFront(headlineTableView)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let world = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "world")
        let business = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "business")
        let politics = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "politics")
        let sports = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sports")
        let technology = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "technology")
        let science = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "science")
        return [world, business, politics, sports, technology, science]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showResult" {
             let vc = segue.destination as! SearchResultController
             let cell = sender as! UITableViewCell
             let row = headlineTableView.indexPath(for: cell)!.row
             vc.keyword = suggests[row]
        }
    }

}

extension HeadlinesController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggest", for: indexPath)
        cell.textLabel?.text = suggests[indexPath.row]
        return cell
    }
    
    
}

extension HeadlinesController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if isSearching {
            headlineTableView.isHidden = false
        } else {
            headlineTableView.isHidden = true
        }
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
                self.headlineTableView.reloadData()
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

extension HeadlinesController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
        selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchText(searchBar.text!)
    }
}
