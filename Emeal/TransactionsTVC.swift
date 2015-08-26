//
//  TransactionsTVCTableViewController.swift
//  Emeal
//
//  Created by Kilian Költzsch on 18/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class TransactionsTVC: UITableViewController {

	var transactions = [Transaction]()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationItem.title = "Last Transactions"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "update")

		update()
    }

	func update() {
		Kartenservice.transactions(user: "foo", password: "bar") { [unowned self] (transactions, error) -> Void in
			if let error = error {
				let ac = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
				ac.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
				self.presentViewController(ac, animated: true, completion: nil)
				return
			}

			self.transactions = transactions
			self.tableView.reloadData()
		}
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

	let timestampDateFormatter: NSDateFormatter = {
		var df = NSDateFormatter()
		df.dateFormat = "dd.MM.yyyy HH:mm 'Uhr'"
		return df
	}()

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("transactionCell", forIndexPath: indexPath) as! TransactionCell

		let thisTransaction = transactions[indexPath.row]

		cell.canteenLabel.text = thisTransaction.location
		cell.timestampLabel.text = timestampDateFormatter.stringFromDate(thisTransaction.date)

		switch thisTransaction.type! {
		case .Article:
			let price = NSString(format: "-%.2f€", thisTransaction.totalPrice)
			cell.priceLabel.text = price as String
			cell.priceLabel.textColor = UIColor.redColor()
		case .Charge:
			let price = NSString(format: "%.2f€", thisTransaction.totalPrice)
			cell.priceLabel.text = price as String
			cell.priceLabel.textColor = UIColor.blackColor()
		}

        return cell
    }

	// MARK: - Table view delegate

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print(transactions[indexPath.row])
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}
