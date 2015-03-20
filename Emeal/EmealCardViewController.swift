//
//  EmealCardViewController.swift
//  Emeal
//
//  Created by Kilian Költzsch on 19/03/15.
//  Copyright (c) 2015 kilian.io. All rights reserved.
//

import UIKit

class EmealCardViewController: UIViewController {

	@IBOutlet weak var mainLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		mainLabel.textColor = UIColor.whiteColor()
		secondaryLabel.textColor = UIColor.whiteColor()

		mainLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30.0)
		mainLabel.text = "iPhone bitte\n auf Karte legen."

		secondaryLabel.text = ""

		let colors = Colors()
		view.backgroundColor = UIColor.clearColor()
		var backgroundLayer = colors.gl
		backgroundLayer.frame = view.frame
		view.layer.insertSublayer(backgroundLayer, atIndex: 0)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func testButtonDown(sender: UIButton) {
		mainLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 70.0)
		mainLabel.text = "13,37€"

		secondaryLabel.text = "Letzte Abbuchung: 1,70€"
	}

	@IBAction func testButtonUp(sender: UIButton) {
		mainLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30.0)
		mainLabel.text = "iPhone bitte\n auf Karte legen."

		secondaryLabel.text = ""
	}

}

