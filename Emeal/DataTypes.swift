//
//  DataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 24/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

enum Result<T: Any, U: ErrorType> {
	case Success(T)
	case Failure(U)
}
