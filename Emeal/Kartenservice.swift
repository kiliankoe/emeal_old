//
//  Kartenservice.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire

enum KartenserviceError: ErrorType {
	case Request
	case Server
	case Authentication
}

// MARK: - URLs

let ksBaseURL = NSURL(string: "http://kartenservice.studentenwerk-dresden.de/KartenService/")!
let ksTransactionsURL = NSURL(string: "Transaktionen.php", relativeToURL: ksBaseURL)!
let ksDataURL = NSURL(string: "KartenDaten.php", relativeToURL: ksBaseURL)!
let ksLoginURL = NSURL(string: "Login.php", relativeToURL: ksBaseURL)!

// MARK: -

var authCookie: String? {
	get {
		return NSUserDefaults.standardUserDefaults().stringForKey(Constants.ksAuthCookieKey)
	}
	set {
		NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: Constants.ksAuthCookieKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
}

class Kartenservice {
	static func login(user: String, password: String) throws {
		let params = "login=\(user)&password=\(password)"
		let paramsData = params.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)

		let request = NSMutableURLRequest(URL: ksLoginURL)
		request.HTTPMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = paramsData

		Alamofire.request(request).responseData { (req, res, result) -> Void in
			if let cookie = res?.allHeaderFields["Set-Cookie"] {
				let PHPSessID = cookie.componentsSeparatedByString(";")[0]
				authCookie = PHPSessID[advance(PHPSessID.startIndex, 10)...advance(PHPSessID.startIndex, PHPSessID.characters.count-1)]
			}
		}
	}

	static func transactions(completion: ([Transaction]) -> ()) throws {
		guard let authCookie = authCookie else { throw KartenserviceError.Authentication }

		fatalError("Function not implemented")
	}
}
