//
//  CategoryTableView.swift
//  Tracker
//
//  Created by Georgy on 30.08.2023.
//

import UIKit
import Foundation

class CategoryTableView:UITableView{
    
    // MARK: - Variables
    private var categories:[String] =  []
    
    weak var delegateVC: CategoryViewControllerProtocol?
    private let trackerCategoryStore = TrackerCategoryStore()
    
    // MARK: - Initiliazation
    init() {
        super.init(frame: .zero, style: .plain)
        translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 16
        self.backgroundColor = .clear
        self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.tableFooterView = UIView()
        self.showsVerticalScrollIndicator = false
        self.tintColor = .clear
        delegate = self
        dataSource = self
    }
    
    override func layoutSubviews() {
        hideLastSeparator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return  CGSize(width: 0, height: categories.count * 75)
     }
}

// MARK: - UITableViewDataSource
extension CategoryTableView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegateVC?.getCountOfCategories() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(named: "YP Background")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryTableView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegateVC?.setCategory(named: categories[indexPath.row])
        delegateVC?.presentHabbitVC()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
         return contextMenuConfiguration(for: indexPath)
     }
}

extension CategoryTableView {
    func set(with newCategories: [String]) {
        let oldCategories = self.categories
        let changes = calculateChanges(from: oldCategories, to: newCategories)
        self.categories = newCategories

        updateTableViewHeight()

        performBatchUpdates{
            
            for change in changes {
                switch change {
                case .insert(let indexPath):
                    insertRows(at: [indexPath], with: .automatic)
                case .delete(let indexPath):
                    deleteRows(at: [indexPath], with: .automatic)
                }
            }
            
        }
    }

    private func calculateChanges(from oldCategories: [String], to newCategories: [String]) -> [Change] {
        var changes: [Change] = []

        let oldSet = Set(oldCategories)
        let newSet = Set(newCategories)

        for (index, category) in oldCategories.enumerated() {
            if !newSet.contains(category) {
                changes.append(.delete(IndexPath(row: index, section: 0)))
            }
        }

        for (index, category) in newCategories.enumerated() {
            if !oldSet.contains(category) {
                changes.append(.insert(IndexPath(row: index, section: 0)))
            }
        }

        return changes
    }

enum Change {
    case insert(IndexPath)
    case delete(IndexPath)
}

    
    private func hideLastSeparator(){
        let lastIndexPath = IndexPath(row: categories.count - 1, section: 0)
        if let lastCell = cellForRow(at: lastIndexPath) {
            let separatorFrame = CGRect(x: lastCell.separatorInset.left, y: lastCell.frame.maxY - 1, width: lastCell.frame.width - lastCell.separatorInset.left - lastCell.separatorInset.right, height: 1)
            let separatorView = UIView(frame: separatorFrame)
            separatorView.backgroundColor = UIColor(named: "YP White")
            addSubview(separatorView)
        }
    }
}

extension CategoryTableView{
    
    func updateTableViewHeight() {
        invalidateIntrinsicContentSize()
    }
    
    func contextMenuConfiguration(for indexPath: IndexPath) -> UIContextMenuConfiguration {
          let editAction = UIAction(title: "Редактировать") { action in
              self.delegateVC?.didEditButtonTapped(on: self.categories[indexPath.row])
          }
          
          let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { action in
              self.delegateVC?.deleteCategory(at: self.categories[indexPath.row])
          }
        
          return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
              UIMenu(title: "", children: [editAction, deleteAction])
          })
      }
}
