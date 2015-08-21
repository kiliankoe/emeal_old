//
//  KartenserviceDataTypes.swift
//  Emeal
//
//  Created by Kilian Költzsch on 21/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

struct Transaction {
	let date: NSDate!
	let location: String! // Not sure if this is always a canteen, no need to match it anyways
	let register: String!
	let type: KSType!
	let receiptNum: String!
	var elements: [TransactionElement]!
	let totalPrice: Double!
}

struct TransactionElement {
	let name: String!
	let price: Double!
}

enum KSType {
	case Article, Charge
}

struct KSUserData {
	let cardNumber: Int!
	let message: String! // No clue what this is for
	let bankCode: Int!
	let bankAccountNumber: String! // Keeping the format "307xxxxx"
	let chargeAmount: Double!
	let limitAmount: Double!
	//	let password: String! // Wot?! I'd rather not throw this in here... Why the hell is it being displayed anyways?!
}
