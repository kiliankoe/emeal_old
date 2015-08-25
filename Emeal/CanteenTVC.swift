//
//  CanteenTVC.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class CanteenTVC: UITableViewController {

	@IBOutlet weak var dayPicker: UISegmentedControl!

	var canteens = [Canteen]()

	let spToday = Speiseplan.today
	let spTomorrow = Speiseplan.tomorrow

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "update")

		update()

//		let meal = Meal(id: 152724, name: "", price: nil, ingredients: [], allergens: [], imageURL: nil)
//		speiseplan.mealDetails(forMeal: meal) { (result) -> Void in
//			switch result {
//			case .Success(let meal):
//				print(meal)
//			case .Failure(let error):
//				print(error)
//			}
//		}
    }

	func update() {
		spToday.updateFromWebsite { (error) -> Void in
			if let error = error { print(error); return }
			do {
				self.canteens = try self.spToday.canteens()
			} catch let error {
				print(error)
			}
			self.tableView.reloadData()
		}
		spTomorrow.updateFromWebsite { (error) -> Void in
			if let error = error { print(error); return }
		}
	}

	// MARK: - IBActions

	@IBAction func dayPickerValueChanged(sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			do {
				self.canteens = try self.spToday.canteens()
			} catch let error {
				print(error)
			}
			tableView.reloadData()
		} else {
			do {
				self.canteens = try self.spTomorrow.canteens()
			} catch let error {
				print(error)
			}
			tableView.reloadData()
		}
	}


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canteens.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("canteenCell")!

		let thisCanteen = canteens[indexPath.row]

		cell.textLabel?.text = thisCanteen.name

		switch thisCanteen.name {
		case "Zeltschlösschen":
			cell.imageView?.image = UIImage(named: "Zeltschloesschen")
		case "Mensa Brühl":
			cell.imageView?.image = UIImage(named: "Mensa Bruehl")
		case "Mensa Görlitz":
			cell.imageView?.image = UIImage(named: "Mensa Goerlitz")
		default:
			cell.imageView?.image = UIImage(named: thisCanteen.name)
		}

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMenu" {
			let dest = segue.destinationViewController as! MenuTVC
			let selectedCanteen = canteens[tableView.indexPathForSelectedRow!.row]
			dest.canteen = selectedCanteen
			if dayPicker.selectedSegmentIndex == 0 {
				dest.meals = try! spToday.meals(forCanteen: selectedCanteen.name)
			} else {
				dest.meals = try! spTomorrow.meals(forCanteen: selectedCanteen.name)
			}
		}
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showMenu", sender: self)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
