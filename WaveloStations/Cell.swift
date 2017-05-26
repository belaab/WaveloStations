//
//  Cell.swift
//  WaveloStations
//
//  Created by Iza on 25.05.2017.
//  Copyright © 2017 IB. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    
    @IBOutlet var statusSign: UIImageView!
    
    @IBOutlet var place: UILabel!
    
    @IBOutlet var stationsCount: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
