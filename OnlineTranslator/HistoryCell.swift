//
//  HistoryCell.swift
//  OnlineTranslator
//
//  Created by vit on 1/15/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    var link: HistoryStorage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create "★"
        let starButton = UIButton(type: .system)
        let image = UIImage(named: "LackyStar.png")
        starButton.setImage(image, for: .normal)
        starButton.tintColor = #colorLiteral(red: 0.4915600419, green: 0.4730434418, blue: 0.03819935396, alpha: 1)
        starButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        starButton.addTarget(self, action: #selector(starHandler), for: .touchUpInside)
        accessoryView = starButton
    }
    
    @objc private func starHandler() {
        link?.bookmarks()
        print("★")
        
    }
}
