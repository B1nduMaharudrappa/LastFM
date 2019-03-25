//
//  AlbumsTableViewCell.swift
//  TestTask
//
//  Created by Bindu on 17.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import UIKit

class AlbumsTableViewCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var favouriteIconButton: UIButton!
    @IBOutlet weak var albumName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
