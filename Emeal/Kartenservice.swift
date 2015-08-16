//
//  Kartenservice.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import Alamofire

let ksBaseURL = NSURL(string: "https://kartenservice.studentenwerk-dresden.de/KartenService/")!
let ksTransactionsURL = NSURL(string: "Transaktionen.php", relativeToURL: ksBaseURL)!
let ksDataURL = NSURL(string: "KartenDaten.php", relativeToURL: ksBaseURL)!
let ksLoginURL = NSURL(string: "Login.php", relativeToURL: ksBaseURL)!

class Kartenservice {

	init(user: String, password: String) {
		let params = "login=\(user)&password=\(password)"
		let paramsData = params.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)

		let request = NSMutableURLRequest(URL: ksLoginURL)
		request.HTTPMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = paramsData

		Alamofire.request(request).responseData { (req, res, data) -> Void in
			print(res)
		}
	}

	func foo() {
		print(ksTransactionsURL.absoluteString)
	}
}
