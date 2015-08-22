//
//  MenuTVC.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class MenuTVC: UITableViewController {

	var canteen: Canteen!
	var meals = [Meal]()

	let speiseplan = Speiseplan.shared

    override func viewDidLoad() {
        super.viewDidLoad()

		self.meals = speiseplan.getMeals(forCanteen: canteen)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mealCell") as! MealCell
		let thisMeal = meals[indexPath.row]

		cell.nameLabel.text = thisMeal.name
		if let prices = thisMeal.price {
			cell.priceLabel.text = "\(prices.student)€"
		}

		return cell
	}
}
