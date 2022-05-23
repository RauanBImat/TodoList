//
//  ViewController.swift
//  TodoList
//
//  Created by Рауан Бимат on 20.05.2022.
//

import UIKit

class TodoListViewContrtoller: UIViewController {
    
    private var tasks: [Task]  = []
    private let mainColor = UIColor.gray
    private lazy var segmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Все", "Избранные"])
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = mainColor
        segmentControl.addTarget(self, action: #selector(segmentedValueChanged(_:)), for: .valueChanged)
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: mainColor,
                                      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .medium)]
        segmentControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        
        return segmentControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifier)
        return tableView
    }()
    

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tasks = StorageManager.shared.fetchTaskList()
        setupView()
        setupNavigationBar()
        
    }
    
    // MARK: - Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(segmentControl)
        view.addSubview(tableView)
       

        NSLayoutConstraint.activate([
            // segment control
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            segmentControl.heightAnchor.constraint(equalToConstant: 50),
            
    
            // table view
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
    
    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = mainColor
        
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        
        title = "To do List"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask))
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    private func showNewTaskAlert() {
        let alert = UIAlertController(title: "Название", message: "Добавьте новую задачу", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Task name..."
            textField.font = UIFont.systemFont(ofSize: 17)
        }
        
        let saveAction = UIAlertAction(title: "Добавить", style:.default) { _ in
            guard let titleText = alert.textFields?.first?.text else { return }
            let newTaskId = StorageManager.shared.uniqueNumber
            let newTask =  Task(id: newTaskId,
                                title: titleText,
                                decription: nil,
                                isFavorite: false,
                                done: false)
            
            self.tasks.append(newTask)
            self.tableView.insertRows(at: [IndexPath(row: self.tasks.count - 1, section: 0)], with: .automatic)
            self.save()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    private func save() {
        StorageManager.shared.saveTaskList(array: self.tasks)
    }
    // MARK: - Selectors
    @objc func addNewTask() {
        showNewTaskAlert()
    }
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            tasks = tasks.filter {$0.isFavorite == true}
        } else  {
            tasks = StorageManager.shared.fetchTaskList()
        }
        
        tableView.reloadData()
    }
}

// MARK: - Table view data source
extension TodoListViewContrtoller: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        
        cell.confiure(with: tasks[indexPath.row])
        cell.saveChanges = { changedTask in
            if let index = self.tasks.firstIndex(where: { $0.id == changedTask.id }) {
                self.tasks[index] = changedTask
                self.tableView.reloadData()
                self.save()
            }
        }
        return cell
    }
    
    
}

// MARK: - Table view delegate
extension TodoListViewContrtoller: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var task = self.tasks[indexPath.row]
        let doneTitile = task.done ? "Undo" : "Done"
        print(segmentControl.selectedSegmentIndex)
        if segmentControl.selectedSegmentIndex == 1 { return nil}
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.tasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.save()
        }
        
        let doneAction = UIContextualAction(style: .normal, title: doneTitile) {[weak self] (_, _, completionHandler) in
            if let self = self {
                task.done.toggle()
                self.tasks[indexPath.row] = task
                self.save()
                let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
                cell.doneButtonTapped()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                completionHandler(true)
               }

               completionHandler(false)
            
           
        }
        
        doneAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, doneAction])
    }
    

}
