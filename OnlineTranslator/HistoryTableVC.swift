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
    var delegatedHistory: [String] { get }
    var delegatedLang: String { get }
    var titleText: String { get }
}


class HistoryTableViewController: UITableViewController {
    
    // delegate protocol
    var delegate: HistoryTVDelegate?
    var historyArr = [String]()
    var sumOfDeletedItems = 0
    var flagOfDelete = true
    var flagHistoryIsDelete = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        historyArr = delegate!.delegatedHistory
        // TableView color
        self.tableView.backgroundColor = #colorLiteral(red: 0.6234219074, green: 0.6068384647, blue: 0.4118421078, alpha: 1)
        self.tableView.separatorColor = #colorLiteral(red: 0.2898159898, green: 0.2831504534, blue: 0.193671386, alpha: 1)
        // title for history
        self.title = delegate!.titleText
    }
    
    // navigationBar is appear
    override func viewWillAppear(_ animated: Bool) {
    }
   
    
    @IBAction func trash(_ sender: UIBarButtonItem) {
        // displayed alert before delete
        let alert = UIAlertController(title: "Delete All!", message: "Did you think well?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in self.alertAction() }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        /*
        if delegate?.delegatedLang == "en" {
            let alert = UIAlertController(title: "Sorry my friend, but history is empty", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        if delegate?.delegatedLang == "ru" {
            let alert = UIAlertController(title: "Извини друг, история пуста.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понял.", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        */
    }
    
    func alertAction() {
        // gets the number of deleted items from the storage
        sumOfDeletedItems = (delegate?.deleteHistory(at: (delegate?.delegatedLang)!))!
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if flagOfDelete {
            cell.textLabel?.text = historyArr[indexPath.row]
        }
        return cell
    }
    
}
