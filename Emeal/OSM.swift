//
//  OSM.swift
//  Emeal
//
//  Created by Kilian Költzsch on 27/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum OSMError: ErrorType {
	case Request
	case Server
}

class OSM {
	static func lookup(name: String, completion: (OSMResult<OSMData,OSMError>) -> Void) {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		Alamofire.request(.GET, Constants.osmLookupURL(name)).responseJSON { (_, res, result) -> Void in
			defer { UIApplication.sharedApplication().networkActivityIndicatorVisible = false }
			guard let res = res else { completion(.Failure(.Request)); return }
			guard res.statusCode == 200 else { completion(.Failure(.Request)); return }
			guard let data = result.value else { completion(.Failure(.Server)); return }

			let json = JSON(data)
			print(json[0]["extratags"]["drink:club-mate"])
		}
	}
}
