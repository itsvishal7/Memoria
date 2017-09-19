//
//  ViewController.swift
//  Memoria
//
//  Created by Vishal Chaurasia on 9/19/17.
//  Copyright © 2017 Vishal. All rights reserved.
//

import UIKit

class TodoListsVC: UIViewController {

    @IBOutlet weak var taskListTableView: UITableView! {
        didSet {
            self.taskListTableView.delegate = self
            self.taskListTableView.dataSource = self
        }
    }
    
    var tasks = [Task]() {
        didSet {
            self.taskListTableView.reloadData()
        }
    }
    
    var tempTasks: [Task]!
    
    lazy var searchBar: UISearchBar = {[weak self] in
        let search = UISearchBar()
        search.showsCancelButton = true
        search.placeholder = "Search tasks Here!"
        if let weakself = self {
            weakself.navigationController?.navigationBar.addSubview(search)
            search.frame.size = CGSize(width: weakself.view.frame.width, height: (weakself.navigationController?.navigationBar.frame.height)!)
            search.delegate = self
        }
        return search
        }()
    
    var order: Resources.Order = .date
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tasks = DatabaseService.fetchTasks()
        self.sort()
        self.taskListTableView.reloadData()
    }
    
    @IBAction func searchListHandler(_ sender: UIBarButtonItem) {
        self.showSearchBar()
    }

    @IBAction func addListHandler(_ sender: UIBarButtonItem) {
        self.openNewOrEditTaskViewcontroller()
    }
    
    @IBAction func sortOrderChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.order = .priority
        case 1:
            self.order = .date
        default:
            break
        }
        self.sort()
        self.taskListTableView.reloadData()
    }
    
    private func sort() {
        switch self.order {
        case .date:
            self.tasks.sort { $0.date>$1.date }
        case .priority:
            self.tasks.sort { $0.priority>$1.priority }
        }
    }
    
    func openNewOrEditTaskViewcontroller(task: Task? = nil) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "new_task_vc") as? NewNoteCreationViewController {
            vc.task = task
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            print("Unable to open screen")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TodoListsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.taskListTableView.dequeueReusableCell(withIdentifier: "list_cell", for: indexPath) as! TaskTableViewCell
        let task = self.tasks[indexPath.row]
        cell.noteLabel.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: Date(timeIntervalSince1970: task.date))
        cell.createdAtLabel.text = "Created At: \(date)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.openNewOrEditTaskViewcontroller(task: self.tasks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: {[weak self](rowAction,indexPath) in
            if let weakself = self {
                do{
                    try DatabaseService.uiRealm.write {
                        DatabaseService.uiRealm.delete(weakself.tasks[indexPath.row])
                    }
                }catch{
                    
                }
                weakself.tasks.remove(at: indexPath.row)
                weakself.taskListTableView.reloadData()
            }
        })
        return [delete]
    }
}
extension TodoListsVC: UISearchBarDelegate {
    
    func showSearchBar() {
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        self.searchBar.frame.origin.x = (self.navigationController?.navigationBar.frame.maxX)!
        UIView.animate(withDuration: 0.4, animations: {
            self.searchBar.frame.origin.x = (self.navigationController?.navigationBar.frame.minX)!
        })
        self.tempTasks = self.tasks
        self.searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.searchCancelStateBackToNormal()
        UIView.animate(withDuration: 0.4, animations: {
            self.searchBar.frame.origin.x = (self.navigationController?.navigationBar.frame.maxX)!
        }) { (result) in
            if result {
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blue
            }
        }
    }
    
    private func searchCancelStateBackToNormal() {
        self.tasks = self.tempTasks
        self.tempTasks?.removeAll()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            self.filterOutTasks(text: searchText)
        }else {
            self.tasks = self.tempTasks
        }
    }
    
    private func filterOutTasks(text: String) {
        var filteredTask: [Task] = []
        for each in self.tasks {
            if each.title.localizedCaseInsensitiveContains(text) {
                filteredTask.append(each)
            }
        }
        self.tasks = filteredTask
    }
}
