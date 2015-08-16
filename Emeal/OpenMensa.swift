//
//  OpenMensa.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: - URLs

let omBaseURL = NSURL(string: "https://openmensa.org/api/v2/")!
let omCanteensURL = NSURL(string: "canteens", relativeToURL: omBaseURL)!
func omMealsURL(id: Int, forDate date: NSDate) -> NSURL {
	let dateFormatter = NSDateFormatter()
	dateFormatter.dateFormat = "yyyy-MM-dd"
	return NSURL(string: "canteens/\(id)/days/\(dateFormatter.stringFromDate(date))/meals", relativeToURL: omBaseURL)!
}

// MARK: -

let supportedMensaIDs = "78,79,80,81,82,83,84,85,86,87,88,89,90,91,92"

class OpenMensa {
	static func canteens(completion: ([Canteen]) -> ()) {
		Alamofire.request(.GET, omCanteensURL, parameters: ["ids": supportedMensaIDs]).responseJSON { (req, res, result) -> Void in
			if let jsonData = result.value {
				let json = JSON(jsonData)

				var canteens = [Canteen]()
				for c in json.arrayValue {
					canteens.append(Canteen(id: c["id"].intValue, name: c["name"].stringValue, city: c["city"].stringValue, address: c["address"].stringValue, coords: (c["coordinates"][0].doubleValue, c["coordinates"][1].doubleValue)))
				}
				completion(canteens)
			}
		}
	}

	static func meals(canteenID id: Int, forDate date: NSDate, completion: ([Meal]) -> ()) {
		Alamofire.request(.GET, omMealsURL(id, forDate: date)).responseJSON { (req, res, result) -> Void in
			if let jsonData = result.value {
				let json = JSON(jsonData)

				var meals = [Meal]()
				for m in json.arrayValue {
					let meal = Meal(id: m["id"].intValue, name: m["name"].stringValue, category: m["category"].stringValue, price: (m["prices"]["students"].doubleValue, m["prices"]["employees"].doubleValue), ingredients: [Ingredient.None])
					meals.append(meal)
				}
				completion(meals)
			}
		}
	}

}

