//
//  HistoryTableViewController.swift
//  OnlineTranslator
//
//  Created by vitket team on 1/4/19.
//  Copyright © 2019 vitket team. All rights reserved.
//

import UIKit

protocol HistoryTVDelegate {
    func deleteHistory(at: String) -> Int
    var delegatedHistory: [String] { get set }
    var delegatedLang: String { get }
    var titleText: String { get }
}


class HistoryTableViewController: UITableViewController {
    
    // delegate protocol
    var delegate: HistoryTVDelegate?
    var historyArr = [String]()
    var numOfDeletedItems = 0
    var flagOfDelete = false
    var flagHistoryIsDelete = true
    var instanceHistoryStorage = HistoryStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigation bar is hidden
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Arr of history
        historyArr = delegate!.delegatedHistory
        // TableView color
        self.tableView.backgroundColor = #colorLiteral(red: 0.6234219074, green: 0.6068384647, blue: 0.4118421078, alpha: 1)
        self.tableView.separatorColor = #colorLiteral(red: 0.2898159898, green: 0.2831504534, blue: 0.193671386, alpha: 1)
        // disabled tap on cell
        self.tableView.allowsSelection = false
        // title for history
        self.title = delegate!.titleText
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
   
    
    // trash button
    @IBAction func trash(_ sender: UIBarButtonItem) {
        let countOfHistory = (delegate?.delegatedHistory.count)!
        let lang = delegate?.delegatedLang
        
        if countOfHistory > 0 {
            // prepare alert before delete
            let alertController = UIAlertController(title: "Did you think well?", message: "", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { action in self.alertAction() })
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
            yes.setValue(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), forKey: "titleTextColor")
            cancel.setValue(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), forKey: "titleTextColor")
            alertController.addAction(yes)
            alertController.addAction(cancel)
            // run alert
            self.present(alertController, animated: true)
        }
            // displayed alert when "en" history is empty
        if countOfHistory == 0, lang == "en" {
            let alert = UIAlertController(title: "Sorry my friend, but history is empty.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
            // displayed alert when "ru" history is empty
        if countOfHistory == 0, lang == "ru" {
            let alert = UIAlertController(title: "Извини друг, история пуста.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понял.", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // action of alert (handler of trash)
    func alertAction() {
        // gets the number of deleted items from the storage
        numOfDeletedItems = (delegate?.deleteHistory(at: (delegate?.delegatedLang)!))!
        // this flag report to cell about deleting history in CoreData, based on this, cell decides what to output
        flagOfDelete = !flagOfDelete
        // -1 reserved for Error
        if numOfDeletedItems > -1 {
            var index = [IndexPath]()
            for item in 0...numOfDeletedItems {
                let indexPath = IndexPath(row: item, section: 0)
                index.append(indexPath)
            }
            // update rows
            tableView.reloadRows(at: index, with: .right)
        } else {
            print("Sorry my friend, but history is empty.")
        }
        
        // clear array of history
        delegate?.delegatedHistory = []
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    // rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArr.count
    }
    // create a Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryCell
        cell.link = instanceHistoryStorage
        
        if !flagOfDelete {
            cell.textLabel?.text = historyArr[indexPath.row]
        }
        return cell
    }
    
}
