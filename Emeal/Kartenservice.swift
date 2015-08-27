//
//  Kartenservice.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Alamofire
import Ji

/**
Errors specific to Kartenservice

- Request: Unable to get any response. Internet?
- Server: Server response isn't as expected
- Authentication: Unable to authenticate with user credentials
*/
enum KartenserviceError: ErrorType {
	case Request
	case Server
	case Authentication
	case Closed
}

// MARK: -

/// Custom Alamofire.Manager to use NSHTTPCookieStorage.sharedHTTPCookieStorage()
let alamo: Alamofire.Manager = {
	let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
	cfg.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
	return Alamofire.Manager(configuration: cfg)
}()

class Kartenservice {
	/**
	Authenticate a user with login credentials. A session cookie is then stored for further calls to Kartenservice resources.
	
	- parameter user: username
	- parameter password: password
	- parameter completion: handler that receives an optional error of type `KartenserviceError?`
	*/
	static func login(user user: String, password: String, completion: (error: KartenserviceError?) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let params = "login=\(user)&password=\(password)"
		let paramsData = params.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)

		let request = NSMutableURLRequest(URL: Constants.ksLoginURL)
		request.HTTPMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = paramsData

		alamo.request(request).responseData { (_, res, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let res = res else { completion(error: .Request); return }

			// Unfortunately need to check for this as we're returning an .Authentication error otherwise
			if let data = result.value {
				if let _ = (NSString(data: data, encoding: NSUTF8StringEncoding) as! String).rangeOfString("Session halted.") {
					completion(error: .Closed)
					return
				}
			}

			guard res.URL?.path == "/KartenService/Index.php" else { completion(error: .Authentication); return }
			guard res.statusCode == 200 else { completion(error: .Server); return }

			completion(error: nil)
		}
	}

	/**
	Get all known transactions for an already authenticated user.
	
	- warning: List of transactions will be empty if an error is handed to the completion handler.

	- parameter completion: handler that receives a list of transactions and an optional error of type `KartenserviceError?`
	*/
	static func transactions(completion: (transactions: [Transaction], error: KartenserviceError?) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		alamo.request(.GET, Constants.ksTransactionsURL).responseData { (_, res, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let res = res else { completion(transactions: [], error: .Request); return }
			guard res.URL?.path == Constants.ksTransactionsURL.path else { completion(transactions: [], error: .Authentication); return }
			guard res.statusCode == 200 else { completion(transactions: [], error: .Server); return }

			if let data = result.value {
				let document = Ji(htmlData: data, encoding: NSUTF8StringEncoding)
				let transactionsTRs = document?.xPath("//table[@class='grid']//tr")

				var transactionsList = [Transaction]()

				// This is just a default value to initialize lastTransaction, it should be overwritten in a sec
				var lastTransaction = createTransaction([], placeholder: true)

				// Ignoring the first two and the last value, as these are not transactions.
				// Fingers crossed that the format never changes :P
				for i in 2..<transactionsTRs!.count-1 {
					let tds = transactionsTRs![i].xPath("td")

					// This is a bit tricky. TDs are either identifiers for a new `Transaction` or additions in the
					// form of `TransactionElement`. This can be determined by checking if a date is present in tds[0].
					if tds[0].content != "" {
						if !lastTransaction.elements.isEmpty {
							transactionsList.append(lastTransaction)
						}
						lastTransaction = createTransaction(tds)
					}
					lastTransaction.elements.append(createTransactionElement(tds))
				}

				completion(transactions: transactionsList, error: nil)
				return
			}
			completion(transactions: [], error: .Server)
		}
	}

	/**
	Get all known transactions for a not yet authenticated user. This is the preferred method.
	
	- warning: List of transactions will be empty if an error is handed to the completion handler.
	
	- parameter user: username
	- parameter password: password
	- parameter completion: handler that receives a list of transactions and an optional error of type `KartenserviceError?`
	*/
	static func transactions(user user: String, password: String, completion: (transactions: [Transaction], error: KartenserviceError?) -> Void) {
		login(user: user, password: password) { (error) -> Void in
			guard error == nil else { completion(transactions: [], error: error); return }
			transactions({ (transactions, error) -> Void in
				guard error == nil else { completion(transactions: [], error: error); return }
				completion(transactions: transactions, error: nil)
			})
		}
	}

	/**
	Get user data for an already authenticated user.
	
	- warning: userdata is an optional. It will however be present if error is nil.
	
	- parameter completion: handler that is provided with user data of type `KSUserData?` and an optional error of type `KartenserviceError?`
	*/
	static func userdata(completion: (userdata: KSUserData?, error: KartenserviceError?) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		alamo.request(.GET, Constants.ksUserDataURL).responseData { (_, res, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let res = res else { completion(userdata: nil, error: .Request); return }
			guard res.URL?.path == Constants.ksUserDataURL.path else { completion(userdata: nil, error: .Authentication); return }
			guard res.statusCode == 200 else { completion(userdata: nil, error: .Server); return }

			if let data = result.value {
				let document = Ji(htmlData: data, encoding: NSUTF8StringEncoding)

				let controls = document?.xPath("//form[@id='KAKARTE2']//tr[@class='Controls']")

				if let cardNumberString	= controls?[0].xPath("td[2]").first?.content,
					message				= controls?[1].xPath("td[2]").first?.content,
					bankCodeString		= controls?[2].xPath("td[2]").first?.content,
					bankAccountNumber	= controls?[3].xPath("td[2]").first?.content!,
					chargeAmount		= controls?[4].xPath("td[2]/input").first!["value"],
					limitAmount			= controls?[5].xPath("td[2]/input").first!["value"]
				{
					let cardNumber = Int(cardNumberString)!
					let bankCode = Int(bankCodeString)!
					let userData = KSUserData(cardNumber: cardNumber, message: message, bankCode: bankCode, bankAccountNumber: bankAccountNumber, chargeAmount: readPrice(chargeAmount), limitAmount: readPrice(limitAmount))
					completion(userdata: userData, error: nil)
					return
				}
				completion(userdata: nil, error: .Server)
				return
			}
			completion(userdata: nil, error: .Server)
		}
	}

	/**
	Get user data for a not yet authenticated user. This is the preferred method.
	
	- warning: userdata is an optional. It will however be present if error is nil.

	- parameter user: username
	- parameter password: password
	- parameter completion: handler that is provided with user data of type `KSUserData?` and an optional error of type `KartenserviceError?`
	*/
	static func userdata(user user: String, password: String, completion: (userdata: KSUserData?, error: KartenserviceError?) -> Void) {
		login(user: user, password: password) { (error) -> Void in
			guard error == nil else { completion(userdata: nil, error: error); return }
			userdata({ (userdata, error) -> Void in
				guard error == nil else { completion(userdata: nil, error: error); return }
				completion(userdata: userdata, error: nil)
			})
		}
	}
}

// MARK: - Helper functions

/**
Convert a price from a given string (e.g. "2,30 €") into a double value.

- parameter price: string representation of price
- parameter makePositive: bool value that specifies if a negative value should be made positive, defaults to false
- returns: double value
*/
func readPrice(var price: String, makePositive: Bool = false) -> Double {
	let range = price.rangeOfString(",")
	price.replaceRange(range!, with: ".")
	return makePositive ? (price.componentsSeparatedByString(" ")[0] as NSString).doubleValue * -1 : (price.componentsSeparatedByString(" ")[0] as NSString).doubleValue
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
func createTransaction(tr: [JiNode], placeholder: Bool = false) -> Transaction {
	if placeholder {
		return Transaction(date: NSDate(), location: "", register: "", type: .Article, receiptNum: "", elements: [], totalPrice: -1.0)
	}

	// Deposits are not specifically marked as such, so we're checking the price to determine that
	if readPrice(tr[7].content!) < 0 {
		return Transaction(date: readDate(tr[0].content!), location: tr[1].content!, register: tr[2].content!, type: .Charge, receiptNum: tr[4].content!, elements: [], totalPrice: readPrice(tr[7].content!, makePositive: true))
	}

	return Transaction(date: readDate(tr[0].content!), location: tr[1].content!, register: tr[2].content!, type: readType(tr[3].content!), receiptNum: tr[4].content!, elements: [], totalPrice: readPrice(tr[7].content!))
}

/**
Utility function to convert a tablerow from the Kartenservice transactions view into a `TransactionElement` value.

- parameter tr: tablerow
- returns: TransactionElement value
*/
func createTransactionElement(tr: [JiNode]) -> TransactionElement {

	// Deposits are not specifically marked as such, so we're checking the price to determine that
	if readPrice(tr[6].content!) < 0 {
		return TransactionElement(name: tr[5].content!, price: readPrice(tr[6].content!, makePositive: true))
	}
	return TransactionElement(name: tr[5].content!, price: readPrice(tr[6].content!))
}

/// NSDateFormatter that can handle `dd.MM.yyyy HH:mm:ss`
let ksDateFormatter: NSDateFormatter = {
	var df = NSDateFormatter()
	df.dateFormat = "dd.MM.yyyy HH:mm:ss"
	return df
}()
