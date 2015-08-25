//
//  Constants.swift
//  Emeal
//
//  Created by Kilian Költzsch on 17/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

struct Constants {
	// Speiseplan
	static let spMainURL = NSURL(string: "https://www.studentenwerk-dresden.de/mensen/speiseplan/")!
	static let spMainTomorrowURL = NSURL(string: "morgen.html", relativeToURL: spMainURL)!
	static func spDetailURL(id: Int) -> NSURL {
		return NSURL(string: "https://www.studentenwerk-dresden.de/mensen/speiseplan/details-\(id).html")!
	}

	static let spMainURLEgg = NSURL(string: "http://www.studentenwerk-dresden.de.saxophone.parallelnetz.de/mensen/speiseplan/")!
	static let spMainTomorrowURLEgg = NSURL(string: "morgen.html", relativeToURL: spMainURLEgg)!
	static func spDetailURLEgg(id: Int) -> NSURL {
		return NSURL(string: "http://www.studentenwerk-dresden.de.saxophone.parallelnetz.de/mensen/speiseplan/details-\(id).html")!
	}

	// Kartenservice
	static let ksBaseURL = NSURL(string: "https://kartenservice.studentenwerk-dresden.de/KartenService/")!
	static let ksTransactionsURL = NSURL(string: "Transaktionen.php", relativeToURL: ksBaseURL)!
	static let ksUserDataURL = NSURL(string: "KartenDaten.php", relativeToURL: ksBaseURL)!
	static let ksLoginURL = NSURL(string: "Login.php?ccsForm=Login", relativeToURL: ksBaseURL)!
}
