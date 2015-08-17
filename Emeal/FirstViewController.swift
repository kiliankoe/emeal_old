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
		// Do any additional setup after loading the view, typically from a nib.

//		let ks = Kartenservice(user: "foo", password: "bar")

//		OpenMensa.canteens { (canteens) -> () in
//			print(canteens)
//		}

//		OpenMensa.meals(canteenID: 79, forDate: NSDate()) { (meals) -> () in
//			print(meals)
//		}

		OpenMensa.isClosed(canteenID: 79, forDate: NSDate()) { (isClosed) -> () in
			print(isClosed)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

