//
//  Colors.swift
//  Emeal
//
//  Created by Kilian Költzsch on 19/03/15.
//  Copyright (c) 2015 kilian.io. All rights reserved.
//

import UIKit

class Colors {
	//	let colorTop = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0).CGColor
	let colorTop = UIColor(rgba: "#76db62").CGColor
	//	let colorBottom = UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0).CGColor
	let colorBottom = UIColor(rgba: "#0ab816").CGColor

	let gl: CAGradientLayer

	init() {
		gl = CAGradientLayer()
		gl.colors = [colorTop, colorBottom]
		gl.locations = [ 0.0, 1.0]
	}
}
