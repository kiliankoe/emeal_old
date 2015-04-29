//
//  Speiseplan.swift
//  Emeal
//
//  Created by Kilian Költzsch on 29/04/15.
//  Copyright (c) 2015 kilian.io. All rights reserved.
//

import Foundation

struct Menu {
	let mensa: String!
	let meals: [Meal]!
}

struct Meal {
	let name: String!
	let price: Double!
	let ingredients: [Ingredient]!
}

enum Ingredient {
	case Alcohol
	case Meat
	case Pork
	case Beef
	case Garlic
}
