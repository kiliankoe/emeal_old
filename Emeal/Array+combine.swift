//
//  Array+combine.swift
//  Emeal
//
//  Created by Kilian Költzsch on 17/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

extension Array {
	func combine(separator: String) -> String{
		var str : String = ""
		for (idx, item) in self.enumerate() {
			str += "\(item)"
			if idx < self.count-1 {
				str += separator
			}
		}
		return str
	}
}
