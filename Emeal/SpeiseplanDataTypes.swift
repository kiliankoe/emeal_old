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
	var ingredients: [Ingredient]!
	var allergens: [Allergen]!
	var image: UIImage?
}

typealias PricePair = (student: Double, employee: Double)

enum Ingredient {
	case Alcohol, Vegetarian, Vegan, Pork, Beef, Garlic
}

enum Allergen: String {
	case A = "Glutenhaltiges Getreide (A)"
	case B = "Krebstiere (B)"
	case C = "Eier (C)"
	case D = "Fisch (D)"
	case E = "Erdnüsse (E)"
	case F = "Soja (F)"
	case G = "Milch/Milchzucker (Laktose) (G)"
	case H = "Schalenfrüchte (Nüsse) (H)"
	case I = "Sellerie (I)"
	case J = "Senf (J)"
	case K = "Sesam (K)"
	case L = "Sulfit/Schwefeldioxid (L)"
	case M = "Lupine (M)"
	case N = "Weichtiere (N)"
}
