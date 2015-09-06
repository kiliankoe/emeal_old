//
//  OSMDataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 27/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation
import SwiftyJSON

enum OSMResult<S,E> {
	case Success(S)
	case Failure(E)
}

struct OSMData {
	let license: String
	let coords: (lat: Double, lng: Double)
	let address: String?
	let openingHours: String?
	let wheelchairAccessible: Bool
	let website: NSURL?
	let hasClubMate: Bool

	init(_ json: JSON) {
		self.license = json[0]["licence"].stringValue
		self.coords = (json[0]["lat"].doubleValue, json[0]["lon"].doubleValue)
		let addressData = json[0]["address"].dictionaryValue
		if let road = addressData["road"]?.string,
		   let houseNumber = addressData["house_number"]?.string,
		   let postcode = addressData["postcode"]?.string,
		   let city = addressData["city"]?.string {
			self.address = "\(road) \(houseNumber), \(postcode) \(city)"
		} else {
			self.address = nil
		}
		self.openingHours = json[0]["extratags"]["opening_hours"].string
		self.wheelchairAccessible = json[0]["extratags"]["wheelchair"].string == "yes" ? true : false
		self.website = NSURL(string: json[0]["extratags"]["contact:website"].stringValue)
		self.hasClubMate = json[0]["extratags"]["drink:club-mate"].string == "yes" ? true : false
	}
}
