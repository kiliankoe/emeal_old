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

/**
Errors specific to OpenMensa

- Request: Unable to get any response. Internet?
- Server: Server response isn't as expected
- UnsupportedCanteen: We're only dealing with canteens specific to Dresden here, sorry
*/
enum OpenMensaError: ErrorType {
	case Request
	case Server
	case UnsupportedCanteen
}

// MARK: URLs

let omBaseURL = NSURL(string: "http://openmensa.org/api/v2/")!
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

let supportedCanteenIDs = [78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92]

class OpenMensa {
	/**
	List all canteens in Dresden (or belonging to the TU somehow).
	
	- parameter completion: handler that is provided with said list of canteens and an optional error of type `OpenMensaError?`
	*/
	static func canteens(completion completion: (canteens: [Canteen], error: OpenMensaError?) -> ()) {
		Alamofire.request(Method.GET, omCanteensURL, parameters: ["ids": supportedCanteenIDs.combine(",")]).responseJSON { (_, res, result) -> Void in
			guard let res = res else { completion(canteens: [], error: .Request); return }
			guard res.statusCode == 200 else { completion(canteens: [], error: .Server); return }

			if let jsonData = result.value {
				let json = JSON(jsonData)

				var canteens = [Canteen]()
				for c in json.arrayValue {
					canteens.append(Canteen(id: c["id"].intValue, name: c["name"].stringValue, city: c["city"].stringValue, address: c["address"].stringValue, coords: (c["coordinates"][0].doubleValue, c["coordinates"][1].doubleValue)))
				}
				completion(canteens: canteens, error: nil)
			}
		}
	}

	/**
	List all meals for given canteen ID and date.
	
	- parameter canteenID: ID of a canteen as provided by OpenMensa.canteens()
	- parameter forDate: the day the meals are from (e.g. `NSDate()` for today)
	- parameter completion: handler that is provided with list of meals and an optional error of type `OpenMensaError?`
	*/
	static func meals(canteenID id: Int, forDate date: NSDate, completion: (meals: [Meal], error: OpenMensaError?) -> ()) {
		guard supportedCanteenIDs.contains(id) else { completion(meals: [], error: .UnsupportedCanteen); return }

		Alamofire.request(.GET, omMealsURL(id, forDate: date)).responseJSON { (_, res, result) -> Void in
			guard let res = res else { completion(meals: [], error: .Request); return }
			guard res.statusCode == 200 else { completion(meals: [], error: .Server); return }

			if let jsonData = result.value {
				let json = JSON(jsonData)

				var meals = [Meal]()
				for m in json.arrayValue {
					let meal = Meal(id: m["id"].intValue, name: m["name"].stringValue, category: m["category"].stringValue, price: (m["prices"]["students"].doubleValue, m["prices"]["employees"].doubleValue), ingredients: processIngredients(m["notes"].arrayValue))
					meals.append(meal)
				}
				completion(meals: meals, error: nil)
			}
		}
	}

	/**
	Check if a specific canteen is closed on a date.
	
	- warning: isClosed is an optional. It will however be present if error is nil.
	
	- parameter canteenID: ID of a canteen as provided by `OpenMensa.canteens()`
	- parameter forDate: the date to be checked
	- parameter completion: handler that is provided with an optional bool and an optional error of type `OpenMensaError?`
	*/
	static func isClosed(canteenID id: Int, forDate date: NSDate, completion: (isClosed: Bool?, error: OpenMensaError?) -> ()) {
		guard supportedCanteenIDs.contains(id) else { completion(isClosed: nil, error: .UnsupportedCanteen); return }

		Alamofire.request(.GET, omDaysURL(id, forDate: date)).responseJSON { (_, res, result) -> Void in
			guard let res = res else { completion(isClosed: nil, error: .Request); return }
			guard res.statusCode == 200 else { completion(isClosed: nil, error: .Server); return }

			if let jsonData = result.value {
				let json = JSON(jsonData)
				completion(isClosed: json["closed"].bool, error: nil)
			}
		}
	}
}

/**
Utility function to process a list of ingredients in string form to the appropriate enum.

- parameter notes: JSON object array of notes

- returns: Array of type `[Ingredient]`
*/
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
