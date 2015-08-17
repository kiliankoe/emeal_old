//
//  FirstViewController.swift
//  Emeal
//
//  Created by Kilian Költzsch on 15/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

//		do {
//			try OpenMensa.meals(canteenID: 79, forDate: NSDate()) { (meals) -> () in
//				print(meals)
//			}
//		} catch let err {
//			print(err)
//		}

		Kartenservice.transactions(user: "foo", password: "bar") { (transactions, error) -> Void in
			guard error == nil else { print(error!); return }
			print(transactions)
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

