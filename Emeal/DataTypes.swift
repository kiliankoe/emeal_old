//
//  MenuDataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

struct Canteen {
	let id: Int!
	let name: String!
	let city: String!
	let address: String!
	let coords: (Double, Double)!
}

struct Menu {
	let canteen: String!
	let meals: [Meal]!
}

struct Meal {
	let id: Int!
	let name: String!
	let category: String!
	let price: (Double, Double)!
	let ingredients: [Ingredient]!
}

enum Ingredient {
	case Alcohol
	case Vegetarian
	case Vegan
	case Pork
	case Beef
	case Garlic
	case None
}
