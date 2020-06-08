//
//  TableViewController.swift
//  QZIJKPlayer
//
//  Created by 曲终叶落 on 2018/11/24.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 9/16
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        if indexPath.row == 0 {
            let player = QZIJKPlayerViewController()
            let playModel = QZIJKPlayerPlayModel(title: "《叶问4》先行预告", url: "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4", name: "高清")
            player.view.frame = cell.contentView.bounds
            player.setPlayData(playModels: [playModel])
            cell.contentView.addSubview(player.view)
            self.addChild(player)
        }
        return cell
    }
}
