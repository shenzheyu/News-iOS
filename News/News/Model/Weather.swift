//
//  Weather.swift
//  News
//
//  Created by Zheyu Shen on 4/26/20.
//  Copyright © 2020 Zheyu Shen. All rights reserved.
//

import Foundation

class Weather {
    var city = ""
    var area = ""
    var temp = 0
    var summary = ""
    
    var state:String {
        switch area {
        case "CA":
            return "California"
        case "AL":
            return "Alabama"
        case "AK":
            return "Alaska"
        case "AZ":
            return "Arizona"
        case "AR":
            return "Arkansas"
        case "CO":
            return "Colorado"
        case "CT":
            return "Connecticut"
        case "DE":
            return "Delaware"
        case "FL":
            return "Florida"
        case "GA":
            return "Georgia"
        case "HI":
            return "Hawaii"
        case "ID":
            return "Idaho"
        case "IL":
            return "Illinois"
        case "IN":
            return "Indiana"
        case "IA":
            return "Iowa"
        case "KS":
            return "Kansas"
        case "KY":
            return "Kentucky"
        case "LA":
            return "Louisiana"
        case "ME":
            return "Maine"
        case "MD":
            return "Maryland"
        case "MA":
            return "Massachusetts"
        case "MI":
            return "Michigan"
        case "MN":
            return "Minnesota"
        case "MS":
            return "Mississippi"
        case "MO":
            return "Missouri"
        case "MT":
            return "Montana"
        case "NE":
            return "Nebraska"
        case "NV":
            return "Nevada"
        case "NH":
            return "New hampshire"
        case "NJ":
            return "New jersey"
        case "NM":
            return "New mexico"
        case "NY":
            return "New York"
        case "NC":
            return "North Carolina"
        case "ND":
            return "North Dakota"
        case "OH":
            return "Ohio"
        case "OK":
            return "Oklahoma"
        case "OR":
            return "Oregon"
        case "PA":
            return "Pennsylvania"
        case "RI":
            return "Rhode island"
        case "SC":
            return "South carolina"
        case "SD":
            return "South dakota"
        case "TN":
            return "Tennessee"
        case "TX":
            return "Texas"
        case "UT":
            return "Utah"
        case "VT":
            return "Vermont"
        case "VA":
            return "Virginia"
        case "WA":
            return "Washington"
        case "WV":
            return "West Virginia"
        case "WI":
            return "Wisconsin"
        case "WY":
            return "Wyoming"
        default:
            return area
        }
    }
    
    var image:String {
        switch summary {
        case "Clouds":
            return "cloudy_weather"
        case "Clear":
            return "clear_weather"
        case "Snow":
            return "snowy_weather"
        case "Rain":
            return "rainy_weather"
        case "Thunderstorm":
            return "thunder_weather"
        default:
            return "sunny_weather"
        }
    }
}
