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

enum OpenMensaError: ErrorType {
	case Request
	case Server
	case UnsupportedID
}

// MARK: - URLs

let omBaseURL = NSURL(string: "https://openmensa.org/api/v2/")!
let omCanteensURL = NSURL(string: "canteens", relativeToURL: omBaseURL)!
func omMealsURL(id: Int, forDate date: NSDate) -> NSURL {
	let dateFormatter = NSDateFormatter()
	dateFormatter.dateFormat = "yyyy-MM-dd"
	return NSURL(string: "canteens/\(id)/days/\(dateFormatter.stringFromDate(date))/meals", relativeToURL: omBaseURL)!
}
func omDaysURL(id: Int, forDate date: NSDate) -> NSURL {
	let dateFormatter = NSDateFormatter()
	dateFormatter.dateFormat = "yyyy-MM-dd"
	return NSURL(string: "canteens/\(id)/days/\(dateFormatter.stringFromDate(date))", relativeToURL: omBaseURL)!
}

// MARK: -

let supportedMensaIDs = [78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92]

class OpenMensa {
	static func canteens(completion completion: ([Canteen]) -> ()) throws {
		Alamofire.request(Method.GET, omCanteensURL, parameters: ["ids": supportedMensaIDs.combine(",")]).responseJSON { (req, res, result) -> Void in
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

	static func meals(canteenID id: Int, forDate date: NSDate, completion: ([Meal]) -> ()) throws {
		guard supportedMensaIDs.contains(id) else { throw OpenMensaError.UnsupportedID }

		Alamofire.request(.GET, omMealsURL(id, forDate: date)).responseJSON { (req, res, result) -> Void in
			if let jsonData = result.value {
				let json = JSON(jsonData)

				var meals = [Meal]()
				for m in json.arrayValue {
					let meal = Meal(id: m["id"].intValue, name: m["name"].stringValue, category: m["category"].stringValue, price: (m["prices"]["students"].doubleValue, m["prices"]["employees"].doubleValue), ingredients: processIngredients(m["notes"].arrayValue))
					meals.append(meal)
				}
				completion(meals)
			}
		}
	}

	static func isClosed(canteenID id: Int, forDate date: NSDate, completion: (Bool) -> ()) throws {
		Alamofire.request(.GET, omDaysURL(id, forDate: date)).responseJSON { (req, res, result) -> Void in
			if let jsonData = result.value {
				let json = JSON(jsonData)

				completion(json["closed"].boolValue)
			}
		}
	}
}

func processIngredients(notes: [JSON]) -> [Ingredient] {
	var ingredients = [Ingredient]()
	for note in notes {
		switch note.stringValue {
		case "Menü enthält Alkohol":
			ingredients.append(.Alcohol)
		case "Menü enthält kein Fleisch":
			ingredients.append(.Vegetarian)
		case "Menü ist vegan":
			ingredients.append(.Vegan)
		case "Menü enthält Schweinefleisch":
			ingredients.append(.Pork)
		case "Menü enthält Rindfleisch":
			ingredients.append(.Beef)
		case "Menü enthält Knoblauch":
			ingredients.append(.Garlic)
		default:
			break
		}
	}
	return ingredients
}
