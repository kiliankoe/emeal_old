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

//		OpenMensa.canteens { (canteens, error) -> () in
//			guard error == nil else { print(error!); return }
//			print(canteens)
//		}

		OpenMensa.meals(canteenID: 79, forDate: NSDate()) { (meals, error) -> () in
			guard error == nil else { print(error!); return }
			print(meals)
		}

//		OpenMensa.isClosed(canteenID: 91, forDate: NSDate()) { (isClosed, error) -> () in
//			guard error == nil else { print(error!); return }
//			print(isClosed!)
//		}

//		Kartenservice.transactions(user: "foo", password: "bar") { (transactions, error) -> Void in
//			guard error == nil else { print(error!); return }
//			print(transactions)
//		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

