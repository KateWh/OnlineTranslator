//
//  HistoryCell.swift
//  OnlineTranslator
//
//  Created by vit on 1/15/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit

struct HasFavorite {
    var value: String
    var favoriteFlag: Bool
}


class HistoryCell: UITableViewCell {
    
    var storage: HistoryStorage!
    var table = HistoryTableViewController()
    var translateVC: TranslateVC!
    var bookmarkFlag = false
    var favoritesArray = [HasFavorite]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // create "★"
    func createStar() {
        let button = UIButton(type: .system)
        let image = UIImage(named: "LackyStar.png")
        button.setImage(image, for: .normal)
        button.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(starHandler), for: .touchUpInside)
        accessoryView = button
        
        for value in (table.delegate?.dataArray)! {
            favoritesArray.append(HasFavorite(value: value, favoriteFlag: bookmarkFlag))
        }
    }
    
    // star selector handler
    @objc private func starHandler() {
        bookmarkFlag = !bookmarkFlag
        //let arrayWithData = table.delegate?.dataArray
        let valueOfCell = table.valueOfCell(forCell: self, at: table.lang!)
        
        for (indx, favoriteVal) in favoritesArray.enumerated() {
            if favoriteVal.value == valueOfCell {
                favoritesArray[indx].favoriteFlag = bookmarkFlag
            }
        }
        
        print("------------------------")
        for indx in favoritesArray {
            print(indx.value, indx.favoriteFlag)
        }
        
        for bookmark in storage.getBookmarks() {
            guard bookmark != valueOfCell else { return }
        }
        storage.setBookmark(forValue: valueOfCell , at: "")
    }
}

