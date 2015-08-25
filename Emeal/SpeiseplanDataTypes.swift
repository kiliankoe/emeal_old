//
//  SpeiseplanDataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 16/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

struct Canteen: Equatable {
	let name: String!
	let address: String!
	let coords: (Double, Double)!
}

func ==(lhs: Canteen, rhs: Canteen) -> Bool {
	if lhs.name == rhs.name {
		return true
	}
	return false
}

struct Meal {
	let id: Int!
	let name: String!
//	let category: String!
	let price: PricePair!
	var ingredients: [Ingredient]!
	var allergens: [Allergen]!
	var imageURL: NSURL?
	var isSoldOut: Bool!
}

typealias PricePair = (student: Double?, employee: Double?)

enum Ingredient:String {
	case Alcohol = "Menü enthält Alkohol"
	case Vegetarian = "Menü enthält kein Fleisch"
	case Vegan = "Menü ist vegan"
	case Pork = "Menü enthält Schweinefleisch"
	case Beef = "Menü enthält Rindfleisch"
	case Garlic = "Menü enthält Knoblauch"
//	case Gelantine = "Menü enthält Gelantine"
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

enum SPResult<S,E> {
	case Success(S)
	case Failure(E)
}

enum SPPriceResult {
	case Price(PricePair)
	case SoldOut
	case None
}
