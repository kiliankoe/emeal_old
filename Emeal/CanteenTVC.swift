//
//  CanteenTVC.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class CanteenTVC: UITableViewController, SpeiseplanDelegate {

	var canteens = [Canteen]()

	let speiseplan = Speiseplan.shared

    override func viewDidLoad() {
        super.viewDidLoad()

		let daySelector = UISegmentedControl(items: ["Today", "Tomorrow"])
		daySelector.sizeToFit()
		daySelector.selectedSegmentIndex = 0
		self.navigationItem.titleView = daySelector

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "update")

		speiseplan.delegate = self
		speiseplan.loadFeed()
    }

	func update() {
		speiseplan.loadFeed()
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMenu" {
			let dest = segue.destinationViewController as! MenuTVC
			let selectedCanteen = canteens[tableView.indexPathForSelectedRow!.row]
			dest.canteen = selectedCanteen
		}
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showMenu", sender: self)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

	// MARK: - SpeiseplanDelegate

	func SpeiseplanCanteens(canteens: [Canteen]) {
		self.canteens = canteens
		tableView.reloadData()
	}

	func SpeiseplanErrorEncountered(error: SpeiseplanError) {
		print(error)
	}

	func SpeiseplanRSSErrorEncountered(error: SpeiseplanRSSError) {
		print(error)
	}

}
