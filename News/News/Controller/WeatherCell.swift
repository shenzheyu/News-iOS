//
//  WeatherCell.swift
//  News
//
//  Created by Zheyu Shen on 5/3/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

//    @IBOutlet weak var cityLabel: UILabel!
//    @IBOutlet weak var tempLabel: UILabel!
//    @IBOutlet weak var stateLabel: UILabel!
//    @IBOutlet weak var conditionLabel: UILabel!
//    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
