//
//  DataController.swift
//  Emeal
//
//  Created by Kilian Költzsch on 29/04/15.
//  Copyright (c) 2015 kilian.io. All rights reserved.
//

import Foundation
import Alamofire
import HTMLReader

class DataController {
	static func getMensaMenu(completion: (htmlString: String) -> ()) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		Alamofire.request(.GET, Constants.mensaURL).responseString(encoding: NSUTF8StringEncoding) { (_, res, string, err) -> Void in
			if err == nil && res?.statusCode == 200 {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				completion(htmlString: string!)
			}
		}
	}

	static func parseMensenList(htmlString: String) -> [Menu] {
		let document = HTMLDocument(string: htmlString)
		var menus = [Menu]()
		for speiseplan in document.nodesMatchingSelector(".speiseplan") {

			// Get Mensa Name
			var mensaName = speiseplan.firstNodeMatchingSelector("thead .text").textContent
			if (mensaName.rangeOfString("Bio") != nil) {
				mensaName = "BioMensa U-Boot"
			}

			// Get Meals
			var meals = [Meal]()
			for tr in speiseplan.nodesMatchingSelector("tbody tr") {

				var mealName: String

				var mealPrice: (Double, Double)
				var isSoldOut = false

				var containsAlcohol = false
				var isVegetarian = false
				var containsPork = false
				var containsBeef = false
				var containsGarlic = false

				// A tr containing a td.text is a tr containing a single meal and metadata
				if tr.firstNodeMatchingSelector(".text") != nil {

					// Get name of meal
					mealName = tr.firstNodeMatchingSelector(".text").textContent
					println(mealName)

					// Get price of meal
					let priceString = tr.firstNodeMatchingSelector(".preise").textContent
					if priceString == "" {
						mealPrice = (-1.0, -1.0)
					} else if priceString == "ausverkauft" {
						mealPrice = (-1.0, -1.0)
						isSoldOut = true
					} else {
						let prices = priceString.componentsSeparatedByString(" / ")
//						let substringIndex = count(prices[0]) - 2
//						let studPrice = dropLast(dropLast(prices[0]))
						println(prices)
					}

					// Get meal ingredients by checking which img alt tags are present
					if tr.nodesMatchingSelector(".stoffe img[alt='Menü enthält Alkohol']") != nil {
						containsAlcohol = true
					}

					if tr.nodesMatchingSelector(".stoffe img[alt='Menü enthält kein Fleisch']") != nil {
						isVegetarian = true
					}

					if tr.nodesMatchingSelector(".stoffe img[alt='Menü enthält Schweinefleisch']") != nil {
						containsPork = true
					}

					if tr.nodesMatchingSelector(".stoffe img[alt='Menü enthält Rindfleisch']") != nil {
						containsBeef = true
					}

					if tr.nodesMatchingSelector(".stoffe img[alt='Menü enthält Knoblauch']") != nil {
						containsGarlic = true
					}
				}

				
			}
		}

		return menus
	}
}
