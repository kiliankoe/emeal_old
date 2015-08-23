//
//  SpeiseplanRSSParser.swift
//  Emeal
//
//  Created by Kilian Költzsch on 20/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

// MARK: Error

enum SpeiseplanRSSError: ErrorType {
	case NoData
	case Parse
}

// MARK: - Delegate Protocol

protocol SpeiseplanRSSParserDelegate {
	func SpeiseplanRSSParseError(error: SpeiseplanRSSError)
	func SpeiseplanRSSParseFinished(canteens: [Canteen], meals: [String: [Meal]])
}

// MARK: - URLs

let spFeedURL = NSURL(string: "https://www.studentenwerk-dresden.de/feeds/speiseplan.rss")!
let spFeedURLTomorrow = NSURL(string: "?tag=morgen", relativeToURL: spFeedURL)!
func spDetailURL(id: Int) -> NSURL {
	return NSURL(string: "http://www.studentenwerk-dresden.de/mensen/speiseplan/details-\(id).html")!
}

// MARK: - Parser

class SpeiseplanRSSParser: NSObject, NSXMLParserDelegate {

	var delegate: SpeiseplanRSSParserDelegate?

	// MARK: - Icky global vars
	// I feel so very very dirty... Global mutable vars... (´･︹ ･`) So much for using Swift :(
	var eName = ""
	var currentItemTitle = ""
	var currentItemLink = ""
	var currentItemAuthor = ""
	var inItem = false

	var currentCanteenName = ""
	var currentMealName = ""
	var currentMealID = 0
	var currentMealPrice: PricePair? = nil

	var canteens = [Canteen]()
	var meals = [String: [Meal]]()

	// MARK: -

	func parse() {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [unowned self] () -> Void in
			UIApplication.sharedApplication().networkActivityIndicatorVisible = true
			let data = NSData(contentsOfURL: spFeedURL)
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false

			// Is it wrong to be going back to the main queue here? Parsing this document should be fast enough, right?
			// Only wanted to make sure the network call is being done on the background queue.
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				guard let xmlData = data else { self.delegate?.SpeiseplanRSSParseError(.NoData); return }

				let xmlParser = NSXMLParser(data: xmlData)
				xmlParser.delegate = self

				if !xmlParser.parse() {
					self.delegate?.SpeiseplanRSSParseError(.Parse)
				}
			})
		}
	}

	// MARK: - NSXMLParserDelegate

	func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
		delegate?.SpeiseplanRSSParseError(.Parse)
	}

	func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		eName = elementName
		if elementName == "item" {
			inItem = true
		}
	}

	func parser(parser: NSXMLParser, foundCharacters string: String) {
		if inItem {
			let data = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
			if !data.isEmpty {
				if eName == "title" {
					currentItemTitle += data
				} else if eName == "link" {
					currentItemLink += data
				} else if eName == "author" {
					currentItemAuthor += data
				}
			}
		}
	}

	func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		switch elementName {
		case "item" where inItem:
			inItem = false
			let newCanteen = Canteen(name: currentCanteenName, address: "", coords: (0.0, 0.0))
			if !canteens.contains(newCanteen) {
				canteens.append(newCanteen)
				meals[newCanteen.name] = []
			}
			meals[currentCanteenName]?.append(Meal(id: currentMealID, name: currentMealName, price: currentMealPrice, ingredients: [], allergens: [], image: nil))
		case "title" where inItem:
			// Every weekend a normal canteen doesn't offer anything and so isn't listed.
			// But the Mensologie is no "normal canteen", because they have to specifically
			// tell you that they don't have anything (┛ò__ó)┛彡┻━┻
			if currentItemTitle == "Angebot im GOURMED: Kein Angebot" {
				inItem = false
				currentItemTitle = ""
			}

			let itemElements = processTitle(currentItemTitle)
			currentItemTitle = ""
			currentMealName = itemElements.0
			currentMealPrice = itemElements.1
		case "link" where inItem:
			currentMealID = processLinkToID(currentItemLink)
			currentItemLink = ""
		case "author" where inItem:
			currentCanteenName = currentItemAuthor
			currentItemAuthor = ""
		default: break
		}
	}

	func parserDidEndDocument(parser: NSXMLParser) {
		delegate?.SpeiseplanRSSParseFinished(canteens, meals: meals)
	}

}

// MARK: - Helper functions

func processTitle(title: String) -> (String, PricePair?) {
	let titleElements = title.componentsSeparatedByString(" (")
	let name = titleElements[0]

	// If we get something without a price, don't stupidly try to do something with that data
	if titleElements.count == 2 {
		let priceElements = titleElements[1].componentsSeparatedByString("/")
		let skipChars = NSMutableCharacterSet()
		skipChars.formUnionWithCharacterSet(NSCharacterSet.letterCharacterSet())
		skipChars.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
		skipChars.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

		let studentPrice = (priceElements[0].stringByTrimmingCharactersInSet(skipChars) as NSString).doubleValue
		let employeePrice = (priceElements[1].stringByTrimmingCharactersInSet(skipChars) as NSString).doubleValue

		return (name, (studentPrice, employeePrice))
	} else {
		return (name, nil)
	}
}

func processLinkToID(link: String) -> Int {
	let skipChars = NSMutableCharacterSet()
	skipChars.formUnionWithCharacterSet(NSCharacterSet.letterCharacterSet())
	skipChars.formUnionWithCharacterSet(NSCharacterSet.punctuationCharacterSet())
	return (link.stringByTrimmingCharactersInSet(skipChars) as NSString).integerValue
}
