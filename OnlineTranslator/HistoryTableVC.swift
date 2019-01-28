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
    var titleText: String { get set }
}

class HistoryTableViewController: UITableViewController {
    
    

    var delegate: HistoryTVDelegateProtocol?
    var historyArray = [HasFavorite]()
    var sumOfDeletedItems = 0
    var flagOfDelete = false
    var flagOfRuEnBookmarks = false
    var flagHistoryIsDelete = true
    var instanceHistoryStorage = HistoryStorage()
    var lang: String?
    var digitCounts = Array(repeating: 0, count: 10)
    var ruBookmarksArray = [HasFavorite]()
    var enBookmarksArray = [HasFavorite]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar is hidden
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        lang = delegate?.delegatedLang
            // create Arr of history
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
        super.viewWillAppear(animated)
        if delegate?.titleText != "Bookmarks" {
            self.navigationController?.toolbar.isHidden = true
        } else {
            self.navigationController?.setToolbarHidden(false, animated: false)
        }
        
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

    // Toolbar botton to change Ru/En bookmarks
    @IBAction func ruEnToolbarButton(_ sender: UIBarButtonItem) {
        flagOfRuEnBookmarks = !flagOfRuEnBookmarks
        // create En and Ru bookmarks arrays
        for historyItem in historyArray {
            for (_ , unicode) in historyItem.value.first!.unicodeScalars.enumerated() {
                // check cyrillic diapasone
                if (unicode.value < 1024 || unicode.value > 1279) {
                    enBookmarksArray.append(historyItem)
                } else {
                    ruBookmarksArray.append(historyItem)
                }
            }
        }
        
        // prepare to update En bookmarks
        if !flagOfRuEnBookmarks {
            var index = [IndexPath]()
            // create IndexPath for tableView rows
            for (indx, _) in enBookmarksArray.enumerated() {
                let indexPath = IndexPath(row: indx, section: 0)
                index.append(indexPath)
            }
            // checking, how many rows need to delete on reverse motion
            if index.count < ruBookmarksArray.count {
                let difference = (ruBookmarksArray.count - 1) - index.count
                for _ in 0...difference {
                    if index.count != 0 {
                        index.append(IndexPath(row: index.max()!.row + 1, section: 0))
                    } else {
                        index.append(IndexPath(row: 0, section: 0))
                    }
                    enBookmarksArray.append(HasFavorite(value: "", favoriteFlag: false))
                }
            }
            // reload rows and clear Ru/En bookmarks arrays then
            tableView.reloadRows(at: index, with: .right)
            enBookmarksArray = []
            ruBookmarksArray = []
        }
        
        // prepare to update Ru bookmarks
        if flagOfRuEnBookmarks {
            var index = [IndexPath]()
            for (indx, _) in ruBookmarksArray.enumerated() {
                let indexPath = IndexPath(row: indx, section: 0)
                index.append(indexPath)
            }
            // checking, how many rows need to delete on reverse motion
            if index.count < enBookmarksArray.count {
                let difference = (enBookmarksArray.count - 1) - index.count
                for _ in 0...difference {
                    if index.count != 0 {
                        index.append(IndexPath(row: index.max()!.row + 1, section: 0))
                    } else {
                        index.append(IndexPath(row: 0, section: 0))
                    }
                    ruBookmarksArray.append(HasFavorite(value: "", favoriteFlag: false))
                }
                    
            }
            // reload rows and lcear Ru/En bookmarks arrays then
            tableView.reloadRows(at: index, with: .left)
            ruBookmarksArray = []
            enBookmarksArray = []
        }
        
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

        // print history
        if !flagOfDelete && delegate?.titleText != "Bookmarks" {
            cell.textLabel?.text = historyArray[indexPath.row].value
            cell.createStar(tagButton: indexPath.row, favorites: HasFavorite(value: historyArray[indexPath.row].value, favoriteFlag: historyArray[indexPath.row].favoriteFlag), star: historyArray[indexPath.row].favoriteFlag)
        }

        // print only English bookmarks
        if !enBookmarksArray.isEmpty && !flagOfRuEnBookmarks {
            cell.textLabel?.text = enBookmarksArray[indexPath.row].value
        }
        // print only Russian bookmarks
        if !ruBookmarksArray.isEmpty && flagOfRuEnBookmarks {
            cell.textLabel?.text = ruBookmarksArray[indexPath.row].value
        }

        return cell
    }
    
}
