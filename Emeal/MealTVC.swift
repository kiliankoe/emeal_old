//
//  MealTVC.swift
//  Emeal
//
//  Created by Kilian Költzsch on 26/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Static

class MealTVC: UITableViewController {

	let dataSource = DataSource()
	var meal: Meal?

	override func loadView() {
		super.loadView()
		tableView.dataSource = self
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		title = meal?.name
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Bookmarks, target: self, action: "openDetailPageInBrowser")
		dataSource.tableView = tableView

		Speiseplan.mealDetails(forMeal: meal!, completion: { [unowned self] (result) -> Void in
			switch result {
			case .Success(let meal):
				self.meal = meal
			case .Failure(let error):
				print(error)
			}

			let imageRow = Row(context: ["imageURL": self.meal?.imageURL], cellClass: MealDetailImageCell.self)
			self.dataSource.sections[0].rows.insert(imageRow, atIndex: 0)

			if self.meal?.allergens.count > 0 {
				var allergensSection = Section(header: "Allergens")
				for allergen in self.meal!.allergens {
					allergensSection.rows.append(Row(text: allergen.rawValue))
				}
				self.dataSource.sections.append(allergensSection)
			}
		})

		dataSource.sections = [
			Section(header: "Meal", rows: [
				Row(text: meal?.name)
			])
		]

		if let studentPrice = meal?.price?.student, let employeePrice = meal?.price?.employee {
			dataSource.sections.append(Section(header: "Prices", rows: [
				Row(text: "Students: \(studentPrice.format(0.2))€"),
				Row(text: "Employees: \(employeePrice.format(0.2))€")
				]))
		}

		if meal!.ingredients.count > 0 {
			var ingredientsSection = Section(header: "Ingredients")
			for ingredient in meal!.ingredients {
				ingredientsSection.rows.append(Row(text: ingredient.rawValue))
			}
			dataSource.sections.append(ingredientsSection)
		}

		tableView.reloadData()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func openDetailPageInBrowser() {
		UIApplication.sharedApplication().openURL(Constants.spDetailURL(meal!.id))
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
