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

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = canteen.name

//		configureTableView()
    }

	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 100.0
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
			let price = prices.student.format(0.2)
			cell.priceLabel.text = "\(price)€"
		} else {
			cell.priceLabel.text = ""
		}

		if thisMeal.isSoldOut {
			cell.nameLabel.textColor = UIColor.lightGrayColor()
		} else {
			cell.nameLabel.textColor = UIColor.blackColor()
		}

		for image in cell.ingredientImages {
			image.image = nil
		}

		for ingredient in thisMeal.ingredients {
			switch ingredient {
			case .Alcohol:
				nextFreeImage(cell.ingredientImages).image = UIImage(named: "ingredient.alcohol")
			case .Beef:
				nextFreeImage(cell.ingredientImages).image = UIImage(named: "ingredient.beef")
			case .Garlic:
				nextFreeImage(cell.ingredientImages).image = UIImage(named: "ingredient.garlic")
			case .Pork:
				nextFreeImage(cell.ingredientImages).image = UIImage(named: "ingredient.pork")
			case .Vegan:
				nextFreeImage(cell.ingredientImages).image = UIImage(named: "ingredient.vegan")
			case .Vegetarian:
				nextFreeImage(cell.ingredientImages).image = UIImage(named: "ingredient.vegetarian")
			}
		}

		return cell
	}

	// MARK: - Table view delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showMeal", sender: self)
//		let ac = UIAlertController(title: "Meal", message: "\(meals[indexPath.row])", preferredStyle: UIAlertControllerStyle.Alert)
//		ac.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
//		self.presentViewController(ac, animated: true, completion: nil)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMeal" {
			let dest = segue.destinationViewController as! MealTVC
			dest.meal = meals[tableView.indexPathForSelectedRow!.row]
		}
	}

	// MARK: - Helpers

	func nextFreeImage(images: [UIImageView]) -> UIImageView {
		for image in images {
			if image.image == nil {
				return image
			}
		}
		return images.last!
	}
}
