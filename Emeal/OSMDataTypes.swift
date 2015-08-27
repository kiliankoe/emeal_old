//
//  OSMDataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 27/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

enum OSMResult<S,E> {
	case Success(S)
	case Failure(E)
}

struct OSMData {
	let license: String
	let coords: (lat: Double, lng: Double)
	let address: String
	let openingHours: String
	let wheelchairAccessible: Bool
	let website: NSURL
	let hasClubMate: Bool
}
