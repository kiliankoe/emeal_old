//
//  Constants.swift
//  Emeal
//
//  Created by Kilian Költzsch on 17/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import Foundation

struct Constants {
	static let spFeedURL = NSURL(string: "https://www.studentenwerk-dresden.de/feeds/speiseplan.rss")!
	static let spFeedURLTomorrow = NSURL(string: "?tag=morgen", relativeToURL: spFeedURL)!
	static func spDetailURL(id: Int) -> NSURL {
		return NSURL(string: "http://www.studentenwerk-dresden.de/mensen/speiseplan/details-\(id).html")!
	}

	static let ksBaseURL = NSURL(string: "https://kartenservice.studentenwerk-dresden.de/KartenService/")!
	static let ksTransactionsURL = NSURL(string: "Transaktionen.php", relativeToURL: ksBaseURL)!
	static let ksUserDataURL = NSURL(string: "KartenDaten.php", relativeToURL: ksBaseURL)!
	static let ksLoginURL = NSURL(string: "Login.php?ccsForm=Login", relativeToURL: ksBaseURL)!
}
