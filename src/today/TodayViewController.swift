//
//  TodayViewController.swift
//  today
//
//  Created by Hugh Bellamy on 12/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Homework_Planner_Core
import UIKit
import NotificationCenter

class TodayViewController: DayViewController, NCWidgetProviding {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)

        tableView.reloadData()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }

    override func reloadData(animated: Bool) {
        super.reloadData(animated: true)
        
        tableView.layoutIfNeeded()
        preferredContentSize = tableView.contentSize
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: preferredContentSize.width, height: tableView.contentSize.height + 50)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        reloadData(animated: true)       
        completionHandler(NCUpdateResult.newData)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.black
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.homework.count > 0 && indexPath.section == 0 {
            let homework = self.homework[indexPath.row]
            let urlString = homework.objectID.uriRepresentation().absoluteString
            let url = URL(string: "homework-planner://\(urlString)")!

            extensionContext?.open(url)
        }
    }
}
