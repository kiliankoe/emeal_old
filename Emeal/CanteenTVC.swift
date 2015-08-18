//
//  CanteenTVC.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class CanteenTVC: UITableViewController {

	var canteens = [Canteen]()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationItem.title = "Canteens"

		OpenMensa.canteens { [unowned self] (canteens, error) -> ()  in
			guard error == nil else { print(error!); return }

			self.canteens = canteens
			self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("canteenCell", forIndexPath: indexPath)

		let thisCanteen = canteens[indexPath.row]

		cell.textLabel?.text = thisCanteen.name
		cell.detailTextLabel?.text = thisCanteen.address

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMenu" {
			let dest = segue.destinationViewController as! MenuTVC
			let selectedCanteen = canteens[tableView.indexPathForSelectedRow!.row]
			dest.canteenID = selectedCanteen.id
		}
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showMenu", sender: self)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}
