//
//  Double+Format.swift
//  Emeal
//
//  Created by Kilian Költzsch on 26/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

extension Double {
	func format(f: String) -> String {
		return NSString(format: "%\(f)f", self) as String
	}
}
