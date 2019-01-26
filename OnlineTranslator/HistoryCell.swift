//
//  HistoryCell.swift
//  OnlineTranslator
//
//  Created by vit on 1/15/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    let history = HistoryStorage()
    let button = UIButton(type: .system)
    var favorites = HasFavorite(value: "", favoriteFlag: false )
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // create "★"
    func createStar(tagButton: Int, favorites: HasFavorite, star: Bool) {
        self.favorites = favorites
        //let button = UIButton(type: .system)
        let image = UIImage(named: "LackyStar.png")
        button.setImage(image, for: .normal)
        if star {
            button.tintColor = #colorLiteral(red: 0.1240676269, green: 0.2373861074, blue: 0.1056869999, alpha: 1)
        } else {
            button.tintColor = #colorLiteral(red: 0.5019258261, green: 0.5019868016, blue: 0.5018984675, alpha: 1)
        }
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        print("Tag for each button: \(tagButton)")
        button.tag = tagButton
        print("Tag was button has: \(button.tag)")
        button.addTarget(self, action: #selector(starHandler), for: .touchUpInside)
        accessoryView = button

    }

    // star selector handler
    @objc private func starHandler() {
        favorites.favoriteFlag = !favorites.favoriteFlag
        button.tintColor = favorites.favoriteFlag ? #colorLiteral(red: 0.1240676269, green: 0.2373861074, blue: 0.1056869999, alpha: 1) : #colorLiteral(red: 0.5019258261, green: 0.5019868016, blue: 0.5018984675, alpha: 1)
            print("bla bla bla \(button.tag)")
        print(favorites)



        DispatchQueue.main.async {
            self.history.setBookmark(forValue: self.favorites.value, bookmark: self.favorites.favoriteFlag)
        }
    }
}

