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

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "update")

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
			let price = NSString(format: "+%.2f€", thisTransaction.totalPrice)
			cell.priceLabel.text = price as String
			cell.priceLabel.textColor = UIColor.blackColor()
		}

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}
