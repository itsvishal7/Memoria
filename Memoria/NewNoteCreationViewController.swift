//
//  NewNoteCreationViewController.swift
//  Memoria
//
//  Created by Vishal Chaurasia on 9/19/17.
//  Copyright © 2017 Vishal. All rights reserved.
//

import UIKit

class NewNoteCreationViewController: UIViewController {

    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var priorityTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.addShadowView()
        }
    }
    
    @IBOutlet weak var noteLAbel: UILabel!{
        didSet {
            noteLAbel.addShadowView()
        }
    }
    @IBOutlet weak var priorityLabel: UILabel!{
        didSet {
            priorityLabel.addShadowView()
        }
    }
    
    var task: Task!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let _ = self.task {
            self.fillTask()
            self.navigationItem.title = "Edit Task"
        }else {
            self.navigationItem.title = "New Task"
        }
    }
    
    private func fillTask() {
        self.noteTextField.text = self.task.title
        self.priorityTextField.text = String(self.task.priority)
        self.datePicker.setDate(Date(timeIntervalSince1970: self.task.date as! TimeInterval), animated: true)
    }

    @IBAction func addNoteHandler() {
        guard self.noteTextField.text != ""  else {
            self.noteTextField.shake()
            return
        }
        guard self.priorityTextField.text != "", let priority = Int(self.priorityTextField.text!) else {
            self.priorityTextField.shake()
            return
        }
        let newTask = Task()
        newTask.title = self.noteTextField.text ?? ""
        newTask.date = self.datePicker.date.timeIntervalSince1970
        newTask.priority = priority
        if let _ = self.task {
            do{
                try DatabaseService.updateTask(newTask: newTask, oldTask: self.task)
            }catch  {
                
            }
        }else {
            do{
                try DatabaseService.addNew(task: newTask)
            }catch  {
                
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
