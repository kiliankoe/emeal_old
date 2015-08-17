//
//  Kartenservice.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire
import HTMLReader

enum KartenserviceError: ErrorType {
	case Request
	case Server
	case Authentication
}

// MARK: URLs

let ksBaseURL = NSURL(string: "http://kartenservice.studentenwerk-dresden.de/KartenService/")!
let ksTransactionsURL = NSURL(string: "Transaktionen.php", relativeToURL: ksBaseURL)!
let ksDataURL = NSURL(string: "KartenDaten.php", relativeToURL: ksBaseURL)!
let ksLoginURL = NSURL(string: "Login.php?ccsForm=Login", relativeToURL: ksBaseURL)!

// MARK: -

/// Custom Alamofire.Manager to use NSHTTPCookieStorage.sharedHTTPCookieStorage()
let alamo: Alamofire.Manager = {
	let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
	cfg.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
	return Alamofire.Manager(configuration: cfg)
}()

class Kartenservice {
	static func login(user: String, password: String, completion: (error: KartenserviceError?) -> Void) {
		let params = "login=\(user)&password=\(password)"
		let paramsData = params.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)

		let request = NSMutableURLRequest(URL: ksLoginURL)
		request.HTTPMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = paramsData

		alamo.request(request).responseData { (_, res, _) -> Void in
			guard let res = res else { completion(error: .Request); return }
			guard res.URL?.path == "/KartenService/Index.php" else { completion(error: .Authentication); return }
			guard res.statusCode == 200 else { completion(error: .Server); return }

			completion(error: nil)
		}
	}

	static func transactions(completion: (transactions: [Transaction], error: KartenserviceError?) -> Void) {
		alamo.request(.GET, ksTransactionsURL).responseData { (_, res, result) -> Void in
			guard let res = res else { completion(transactions: [], error: .Request); return }
			guard res.URL?.path == "/KartenService/Transaktionen.php" else { completion(transactions: [], error: KartenserviceError.Authentication); return }
			guard res.statusCode == 200 else { completion(transactions: [], error: .Server); return }

			if let data = result.value {
				let document = HTMLDocument(string: NSString(data: data, encoding: NSUTF8StringEncoding) as! String)
				let transactionsTRs = document.nodesMatchingSelector("table.grid tr")

				var transactionsList = [Transaction]()

				// This is just a default value to initialize lastTransaction, it should be overwritten in a sec
				var lastTransaction = createTransaction([], placeholder: true)

				// Ignoring the first two and the last value, as these are not transactions.
				// Fingers crossed that the format never changes :P
				for i in 2..<transactionsTRs.count-1 {
					let tds = transactionsTRs[i].nodesMatchingSelector("td")

					// This is a bit tricky. TDs are either identifiers for a new `Transaction` or additions in the
					// form of `TransactionElement`. This can be determined by checking if a date is present in tds[0].
					if tds[0].textContent != "" {
						if !lastTransaction.elements.isEmpty {
							transactionsList.append(lastTransaction)
						}
						lastTransaction = createTransaction(tds)
					}
					lastTransaction.elements.append(createTransactionElement(tds))
				}

				completion(transactions: transactionsList, error: nil)
			}
		}
	}
}

// MARK: - Helper functions

/**
Convert a price from a given string (e.g. "2,30 €") into a double value.

- parameter price: string representation of price
- returns: double value
*/
func readPrice(var price: String) -> Double {
	let range = price.rangeOfString(",")
	price.replaceRange(range!, with: ".")
	return (price.componentsSeparatedByString(" ")[0] as NSString).doubleValue
}

/**
Convert a date from a string in format `dd.MM.yyyy HH:mm:ss` to an NSDate object.

- parameter date: string representation
- returns: NSDate
*/
func readDate(date: String) -> NSDate {
	if let date = ksDateFormatter.dateFromString(date) {
		return date
	}
	return NSDate(timeIntervalSince1970: 0.0)
}

/**
Convert a string to a KSType value.

- warning: Falls back to .Article if unrecognized
- parameter type: string representation
- returns: KSType value
*/
func readType(type: String) -> KSType {
	switch type {
	case "Artikel":
		return .Article
	case "Karte aufwerten":
		return .Charge
	default:
		return .Article
	}
}

/**
Utility function to convert a tablerow from the Kartenservice transactions view into a `Transaction` value.

- parameter tr: tablerow
- parameter placeholder: optional bool
- returns: Transaction value
*/
func createTransaction(tr: [AnyObject], placeholder: Bool = false) -> Transaction {
	if placeholder {
		return Transaction(date: NSDate(), location: "", register: "", type: .Article, receiptNum: "", elements: [], totalPrice: -1.0)
	}
	return Transaction(date: readDate(tr[0].textContent), location: tr[1].textContent, register: tr[2].textContent, type: readType(tr[3].textContent), receiptNum: tr[4].textContent, elements: [], totalPrice: readPrice(tr[7].textContent))
}

/**
Utility function to convert a tablerow from the Kartenservice transactions view into a `TransactionElement` value.

- parameter tr: tablerow
- returns: TransactionElement value
*/
func createTransactionElement(tr: [AnyObject]) -> TransactionElement {
	return TransactionElement(name: tr[5].textContent, price: readPrice(tr[6].textContent))
}

/// NSDateFormatter that can handle `dd.MM.yyyy HH:mm:ss`
let ksDateFormatter: NSDateFormatter = {
	var df = NSDateFormatter()
	df.dateFormat = "dd.MM.yyyy HH:mm:ss"
	return df
}()
