//
//  MealDetailImageCell.swift
//  Emeal
//
//  Created by Kilian Költzsch on 26/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Static

class MealDetailImageCell: UITableViewCell, CellType {

	@IBOutlet weak var mealImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	func configure(row row: Row) {

	}

}
