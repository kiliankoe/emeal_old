//
//  Speiseplan.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Alamofire
import Ji

/**
Errors specific to Speiseplan

- Request: Unable to get any response. Internet?
- Server: Server response isn't as expected
- UnknownCanteen: There's no info on the requested canteen
- OutdatedData: The requested data is old and should be refreshed
*/
enum SpeiseplanError: ErrorType {
	case Request
	case Server
	case UnknownCanteen
	case OutdatedData
}

class Speiseplan {

	let spURL: NSURL!

	var savedCanteens = [Canteen]()
	var savedMeals = [String: [Meal]]()
	var lastUpdated = NSDate()

	static let today = Speiseplan(url: Constants.spMainURL)
	static let tomorrow = Speiseplan(url: Constants.spMainTomorrowURL)

	init(url: NSURL) {
		self.spURL = url
	}

	/**
	Update the list of canteens and meals stored in the Speiseplan object by getting current data 
	from the Studentenwerk website.

	- parameter completion: handler that is called when done or receives an optional error
	*/
	func updateFromWebsite(completion: (SpeiseplanError?) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		Alamofire.request(.GET, spURL).responseData { [unowned self] (_, res, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let res = res else { completion(.Request); return }
			guard res.statusCode == 200 else { completion(.Server); return }
			guard let data = result.value else { completion(.Server); return }

			self.savedCanteens = [Canteen]()
			self.savedMeals = [String: [Meal]]()

			let jiDoc = Ji(htmlData: data)

			guard let speiseplaene = jiDoc?.xPath("//table[@class='speiseplan']") else { completion(.Server); return }
			for speiseplan in speiseplaene {

				// Read canteen name
				if let canteenName = speiseplan.xPath("thead//th[1]").first?.content {
					let canteen: Canteen
					if canteenName == "BioMensa U-Boot (Bio-Code-Nummer: DE-ÖKO-021)" {
						// There always has to be a special snowflake somewhere...
						canteen = Canteen(name: "BioMensa U-Boot", address: "", coords: (1.0, 1.0))
					} else {
						canteen = Canteen(name: canteenName, address: "", coords: (1.0, 1.0))
					}

					self.savedCanteens.append(canteen)
					self.savedMeals[canteen.name] = []

					// Read meals. There's two tables to gather these from. Starting with the first one
					let firstRows = speiseplan.xPath("tbody[1]/tr")
					for tr in firstRows {
						let rowData = tr.xPath("td")
						let meal = processRowToMeal(rowData)
						if let meal = meal {
							self.savedMeals[canteen.name]?.append(meal)
						}
					}

					let hiddenRows = speiseplan.xPath("tbody[4]/tr")
					for tr in hiddenRows {
						let rowData = tr.xPath("td")
						let meal = processRowToMeal(rowData)
						if let meal = meal {
							self.savedMeals[canteen.name]?.append(meal)
						}
					}

				} else {
					// There should never be a table.speiseplan without a listed canteen name, I hope...
					completion(.Server)
					return
				}
			}

			completion(nil)
		}
	}

	/**
	Get list of canteens from last refresh.
	
	- warning: Throws an OutdatedData error if data is older than 30 minutes and should be refreshed.

	- returns: list of canteens
	*/
	func canteens() throws -> [Canteen] {
		guard NSDate().timeIntervalSinceDate(self.lastUpdated) < 60*30 else { throw SpeiseplanError.OutdatedData }
		return self.savedCanteens
	}

	/**
	Get list of meals in the form of a dictionary with canteen names as keys.

	- warning: Throws an OutdatedData error if data is older than 30 minutes and should be refreshed.

	- returns: dictionary of meals
	*/
	func meals(forCanteen canteenName: String) throws -> [Meal] {
		guard NSDate().timeIntervalSinceDate(self.lastUpdated) < 60*30 else { throw SpeiseplanError.OutdatedData }
		guard let theseMeals = self.savedMeals[canteenName] else { throw SpeiseplanError.UnknownCanteen }
		return theseMeals
	}

	/**
	Update a meal value with an image URL (if available) and allergen data (if available) by
	requesting additional data from the Studentenwerk website.
	
	- parameter meal: The meal value to be updated
	- parameter completion: handler that is given a SPResult containing either the updated meal or 
	an error
	*/
	static func mealDetails(var forMeal meal: Meal, completion: (SPResult<Meal, SpeiseplanError>) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		Alamofire.request(.GET, Constants.spDetailURL(meal.id)).responseData { (_, res, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let res = res else { completion(.Failure(.Request)); return }
			guard res.statusCode == 200 else { completion(.Failure(SpeiseplanError.Server)); return }
			guard let data = result.value else { completion(.Failure(SpeiseplanError.Server)); return }

			let jiDoc = Ji(htmlData: data)

			// Let's get the image
			if let mealImageURLComponent = jiDoc?.xPath("//a[@id='essenfoto']")?.first?["href"] {
				if let mealImageURL = NSURL(string: mealImageURLComponent, relativeToURL: NSURL(string: "https://bilderspeiseplan.studentenwerk-dresden.de")!) {
					meal.imageURL = mealImageURL
				}
			}

			// Now for the ingredients
			if let ingredientsList = jiDoc?.xPath("//div[@id='speiseplandetailsrechts']/ul[1]/li"), let title = jiDoc?.xPath("//div[@id='speiseplandetailsrechts']/h2[1]") {
				if title.first?.content == "Allgemeine Informationen zur Speise:" {
					for ingredient in ingredientsList {
						if let ing = Ingredient(rawValue: ingredient.content!) {
							meal.ingredients.append(ing)
						} else {
							NSLog("Unknown ingredient for meal \(meal.id): \(ingredient.content)")
						}
					}
				} else {
					NSLog("Meal \(meal.id) has no list of ingredients")
				}
			}

			// And the allergens
			if let allergensList = jiDoc?.xPath("//div[@id='speiseplandetailsrechts']/ul[2]/li"), let title = jiDoc?.xPath("//div[@id='speiseplandetailsrechts']/h2[2]") {
				if title.first?.content == "Infos zu enthaltenen Allergenen[2]:" {
					for allergen in allergensList {
						if let all = Allergen(rawValue: allergen.content!) {
							meal.allergens.append(all)
						} else {
							NSLog("Unknown allergen for meal \(meal.id): \(allergen.content)")
						}
					}
				} else {
					NSLog("Meal \(meal.id) has no list of allergens")
				}
			}

			// And the check if this is vegan or not, because that has to specified elsewhere and not where it belongs (┛ò__ó)┛彡┻━┻
			if let additionalInfos = jiDoc?.xPath("//div[@id='speiseplandetailsrechts']/ul[3]/li"), let title = jiDoc?.xPath("//div[@id='speiseplandetailsrechts']/h2[3]") {
				if title.first?.content == "Weitere Informationen:" {
					for info in additionalInfos {
						if let inf = Ingredient(rawValue: info.content!) {
							meal.ingredients.append(inf)
						} else {
							NSLog("Unknown additional info for meal \(meal.id): \(info.content)")
						}
					}
				} else {
					NSLog("Meal \(meal.id) has no list of additional information")
				}
			}

			completion(.Success(meal))
		}
	}
}

// MARK: - Helper functions

/**
Process a single row of data from the Speiseplan into a meal value.

- parameter row: A row of data

- returns: A meal
*/
func processRowToMeal(row: [JiNode]) -> Meal? {
	guard row.count == 3 else { return nil }
	guard let mealIDURL = row[0].xPath("a").first?["href"] else { return nil }
	guard let mealName = row[0].content else { return nil }
	guard let mealPriceString = row[2].content else { return nil }
	let mealIngredients = processIngredients(row[1].xPath("a/img"))

	let price: PricePair?
	let soldOut: Bool
	switch processPriceString(mealPriceString) {
	case .None:
		price = nil
		soldOut = false
	case .SoldOut:
		price = nil
		soldOut = true
	case .Price(let pricePair):
		price = pricePair
		soldOut = false
	}

	return Meal(id: processMealID(mealIDURL), name: mealName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), price: price, ingredients: mealIngredients, allergens: [], imageURL: nil, isSoldOut: soldOut)
}

/**
Process a price in string form into an SPPriceResult.

- parameter string: string containing the prices from the Speiseplan

- returns: An SPPriceResult
*/
func processPriceString(string: String) -> SPPriceResult {
	if string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "ausverkauft" {
		return .SoldOut
	}
	switch string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
	case "ausverkauft":
		return .SoldOut
	case "":
		return .None
	default:
		if let pricePair = processPricePair(string) {
			return .Price(pricePair)
		}
		return SPPriceResult.Price(nil)
	}
}

/**
Process a price in string form into a PricePair. Used by processPriceString().

- parameter string: string containing the prices

- returns: PricePair
*/
func processPricePair(var string: String) -> PricePair? {
	string = string.stringByReplacingOccurrencesOfString(",", withString: ".")
	let priceElements = string.componentsSeparatedByString("/")
	guard priceElements.count <= 2 else { return nil }

	let studentPrice: Double
	let employeePrice: Double
	if priceElements.count == 1 {
		studentPrice = (priceElements[0] as NSString).doubleValue
		employeePrice = studentPrice
	} else {
		studentPrice = (priceElements[0] as NSString).doubleValue
		employeePrice = (priceElements[1] as NSString).doubleValue
	}
	return PricePair(studentPrice, employeePrice)
}

/**
Process something like 'details-152702.html?pni=2' into just '152702'.

- parameter string: The original URL string.

- returns: An integer
*/
func processMealID(string: String) -> Int {
	let anythingBut = NSMutableCharacterSet()
	anythingBut.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	anythingBut.formUnionWithCharacterSet(NSCharacterSet.letterCharacterSet())
	anythingBut.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())

	let stringElements = string.componentsSeparatedByString(".html")

	return (stringElements[0].stringByTrimmingCharactersInSet(anythingBut) as NSString).integerValue
}

/**
Process a list of XML nodes into a list of ingredients.

- parameter nodeList: list of nodes

- returns: list of ingredients
*/
func processIngredients(nodeList: [JiNode]) -> [Ingredient] {
	var ingredients = [Ingredient]()
	for ingredient in nodeList {
		if let altText = ingredient["alt"] {
			if let ing = Ingredient(rawValue: altText) {
				ingredients.append(ing)
			} else {
				NSLog("Unknown ingredient: \(altText)")
			}
		}
	}
	return ingredients
}
