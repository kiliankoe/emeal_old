//
//  Speiseplan.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Alamofire
import HTMLReader

enum SpeiseplanError: ErrorType {
	case Request
	case Server
	case UnknownCanteens
}

protocol SpeiseplanDelegate {
	func SpeiseplanCanteens(canteens: [Canteen]) -> Void
	func SpeiseplanRSSErrorEncountered(error: SpeiseplanRSSError) -> Void
	func SpeiseplanErrorEncountered(error: SpeiseplanError) -> Void
}

class Speiseplan: SpeiseplanRSSParserDelegate {

	let feedParser = SpeiseplanRSSParser()

	var canteens = [Canteen]()
	var meals = [String: [Meal]]()

	var delegate: SpeiseplanDelegate?

	static let shared = Speiseplan()
	private init() {
		feedParser.delegate = self
	}

	func loadFeed(tomorrow: Bool = false) {
		feedParser.parse()
	}

	func getMeals(forCanteen canteen: Canteen) -> [Meal] {
		let mealsList = meals[canteen.name]
		if let mealsList = mealsList {
			return mealsList
		}
		return []
	}

	// MARK: - SpeiseplanRSSParserDelegate

	func SpeiseplanRSSParseError(error: SpeiseplanRSSError) {
		delegate?.SpeiseplanRSSErrorEncountered(error)
	}

	func SpeiseplanRSSParseFinished(canteens: [Canteen], meals: [String : [Meal]]) {
		self.canteens = canteens
		self.meals = meals

		delegate?.SpeiseplanCanteens(canteens)
	}


}
