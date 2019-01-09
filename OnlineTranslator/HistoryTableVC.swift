//
//  HistoryTableViewController.swift
//  OnlineTranslator
//
//  Created by vitket team on 1/4/19.
//  Copyright © 2019 vitket team. All rights reserved.
//

import UIKit

protocol HistoryTVDelegate {
    var delegatedHistory: [String] { get }
    var titleText: String { get }
}


class HistoryTableViewController: UITableViewController {
    
    // delegate protocol
    var delegate: HistoryTVDelegate?
    var historyArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        historyArr = delegate!.delegatedHistory
        print(historyArr)
        // TableView color
        self.tableView.backgroundColor = #colorLiteral(red: 0.6234219074, green: 0.6068384647, blue: 0.4118421078, alpha: 1)
        self.tableView.separatorColor = #colorLiteral(red: 0.2898159898, green: 0.2831504534, blue: 0.193671386, alpha: 1)
        // title for history
        self.title = delegate!.titleText
    }
    
    // navigationBar is appear
    override func viewWillAppear(_ animated: Bool) {
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
        cell.textLabel?.text = historyArr[indexPath.row]
        return cell
    }
    
}
