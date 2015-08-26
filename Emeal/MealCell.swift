//
//  MealCell.swift
//  Emeal
//
//  Created by Kilian Költzsch on 22/08/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!

	@IBOutlet weak var ingredientImage1: UIImageView!
	@IBOutlet weak var ingredientImage2: UIImageView!
	@IBOutlet weak var ingredientImage3: UIImageView!
	@IBOutlet weak var ingredientImage4: UIImageView!

	var ingredientImages: [UIImageView] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

		ingredientImages = [ingredientImage1, ingredientImage2, ingredientImage3, ingredientImage4]
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
