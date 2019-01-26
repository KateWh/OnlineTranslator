//
//  HistoryTableViewController.swift
//  OnlineTranslator
//
//  Created by vitket team on 1/4/19.
//  Copyright © 2019 vitket team. All rights reserved.
//

import UIKit

struct HasFavorite {
    var value: String
    var favoriteFlag: Bool
}

protocol HistoryTVDelegateProtocol {
    func deleteHistory(at: String) -> Int
    func deleteBookmarks()
    var dataArray: [HasFavorite] { get set }
    var delegatedLang: String { get }
    var titleText: String { get }
}

class HistoryTableViewController: UITableViewController {
    var delegate: HistoryTVDelegateProtocol?
    var historyArray = [HasFavorite]()
    var sumOfDeletedItems = 0
    var flagOfDelete = false
    var flagHistoryIsDelete = true
    var instanceHistoryStorage = HistoryStorage()
    var lang: String?


    var digitCounts = Array(repeating: 0, count: 10)

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigation bar is hidden
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        lang = delegate?.delegatedLang
            // Arr of history
            historyArray = delegate!.dataArray
        
        
        // TableView color
        self.tableView.backgroundColor = #colorLiteral(red: 0.6234219074, green: 0.6068384647, blue: 0.4118421078, alpha: 1)
        self.tableView.separatorColor = #colorLiteral(red: 0.2898159898, green: 0.2831504534, blue: 0.193671386, alpha: 1)
        // disabled tap on cell
        self.tableView.allowsSelection = false
        // title for history
        self.title = delegate!.titleText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // trash button
    @IBAction func trash(_ sender: UIBarButtonItem) {
        let countOfHistory = (delegate?.dataArray.count)!
        let title = delegate?.titleText
        
        if countOfHistory > 0 && title != "Bookmarks" {
            // prepare alert before delete
            let alertController = UIAlertController(title: "Did you think well?", message: "", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { action in self.trashAlertAction() })
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
            yes.setValue(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), forKey: "titleTextColor")
            cancel.setValue(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), forKey: "titleTextColor")
            alertController.addAction(yes)
            alertController.addAction(cancel)
            // run alert
            self.present(alertController, animated: true)
        }
            // displayed alert when "en" history is empty
        if countOfHistory == 0 && lang == "en" {
            let alert = UIAlertController(title: "Sorry my friend, but history is empty.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
            // displayed alert when "ru" history is empty
        if countOfHistory == 0 && lang == "ru" {
            let alert = UIAlertController(title: "Извини друг, история пуста.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понял.", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
        if title == "Bookmarks" && delegate?.dataArray.count ?? 0 > 0 {
            let alertController = UIAlertController(title: "Delete All Bookmarks!", message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in self.trashAlertAction() }))
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
            delegate?.dataArray = [HasFavorite]()
        }
    }
    
    // action of alert (handler of trash)
    func trashAlertAction() {
        if title == "Bookmarks" {
            // gets the number of deleted bookmarks items from the storage
            delegate?.deleteBookmarks()
            sumOfDeletedItems = historyArray.count - 1
        } else {
            // gets the number of deleted history items from the storage
            sumOfDeletedItems = (delegate?.deleteHistory(at: (delegate?.delegatedLang)!))!
        }
        // this flag report to cell about deleting history in CoreData, based on this, cell decides what to output
        flagOfDelete = !flagOfDelete
        // -1 reserved for Error
        if sumOfDeletedItems > -1 {
            var index = [IndexPath]()
            for item in 0...sumOfDeletedItems {
                let indexPath = IndexPath(row: item, section: 0)
                index.append(indexPath)
            }
            // update rows
            tableView.reloadRows(at: index, with: .right)
            
        } else {
            print("Sorry my friend, but history is empty.")
        }
        
        // clear array of history
        delegate?.dataArray = []
    }


    // create index of cell for HistoryCell
    func valueOfCell(forCell: UITableViewCell, at lang: String) -> String {
        let indexPathTapped = tableView.indexPath(for: forCell)
        let cellValue = delegate!.dataArray[indexPathTapped!.row]
        return cellValue.value
    }

    
    // MARK: - Table view data source
    // rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    // create a Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryCell

        if !flagOfDelete {
            cell.textLabel?.text = historyArray[indexPath.row].value
            cell.createStar(tagButton: indexPath.row, favorites: HasFavorite(value: historyArray[indexPath.row].value, favoriteFlag: historyArray[indexPath.row].favoriteFlag), star: historyArray[indexPath.row].favoriteFlag)
        }
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //print(historyCell.favoritesArray)
    }
    
}
