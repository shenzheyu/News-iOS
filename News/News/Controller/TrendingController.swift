//
//  TrendingController.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class TrendingController: UIViewController {
    
    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var searchTermInput: UITextField!
    
    var values: [Int] = []
    var keyword = "Coronavirus"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getValues(keyword: keyword)
    }
    
    @IBAction func searchTerm(_ sender: Any) {
        keyword = searchTermInput.text!
        getValues(keyword: keyword)
    }
    
    
    func getValues(keyword: String) {
        Alamofire.request("https://csci571-homework9-news-api.ue.r.appspot.com/trends/\(keyword)").responseJSON { response in
            if let json = response.result.value {
                let values = JSON(json)["values"]
                self.values.removeAll()
                for value in values {
                    self.values.append(value.1.intValue)
                }
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        var lineChartEntry = [ChartDataEntry]()
        for i in 0..<values.count {
            let value = ChartDataEntry(x: Double(i), y: Double(values[i]))
            lineChartEntry.append(value)
        }
        let line = LineChartDataSet(entries: lineChartEntry, label: "Trending Chart for \(keyword)")
        line.colors = [NSUIColor.init(red: 47.0/255.0, green: 124.0/225.0, blue: 246.0/255.0, alpha: 1.0)]
        line.circleHoleRadius = 0
        line.circleRadius = 4
        line.circleColors = [NSUIColor.init(red: 47.0/255.0, green: 124.0/225.0, blue: 246.0/255.0, alpha: 1.0)]
        let data = LineChartData()
        data.addDataSet(line)
        chtChart.data = data
    }

}
