//
//  SpeiseplanDataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

struct Canteen {
	let name: String!
	let address: String!
	let coords: (Double, Double)!
}

struct Meal {
	let id: Int!
	let name: String!
//	let category: String!
	let price: PricePair!
	var ingredients: [BaseIngredient]!
	var allergens: [Allergen]!
	var image: UIImage?
}

typealias PricePair = (student: Double, employee: Double)

enum BaseIngredient {
	case Alcohol, Vegetarian, Vegan, Pork, Beef, Garlic
}

// Not going to translate these into English...
enum Allergen {
	case GlutenhaltigesGetreide, Soja, Sesam, Laktose, Sellerie, Senf, Ei, Nuesse, Schwefeldioxid, Fisch, Weichtiere
}
