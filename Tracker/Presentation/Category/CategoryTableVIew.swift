//
//  CategoryTableView.swift
//  Tracker
//
//  Created by Georgy on 30.08.2023.
//

import UIKit

class CategoryTableView:UITableView{
    
    // MARK: - Variables
    private var categories:[String] =  []
    
    var delegateVC: CategoryViewControllerProtocol?
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
        return categories.count
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
        TempStorage.shared.setCategory(categories[indexPath.row])
        delegateVC?.presentHabbitVC()
    }
}

extension CategoryTableView{
    func set(with categories:[String]){
        self.categories = categories
        self.reloadData()
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

extension CategoryTableView:TrackerCategoryStoreDelegate{
    
    func updateTableViewHeight() {
        invalidateIntrinsicContentSize()
    }
    
    func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        categories = trackerCategoryStore.trackersCategories.map { $0.title }
        updateTableViewHeight()
        self.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(row: $0, section: 0) }
            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(row: $0, section: 0) }
            let updatedIndexPaths = update.updatedIndexes.map { IndexPath(row: $0, section: 0) }
            self.insertRows(at: insertedIndexPaths, with: .automatic)
            self.insertRows(at: insertedIndexPaths, with: .automatic)
            self.insertRows(at: insertedIndexPaths, with: .automatic)
            for move in update.movedIndexes {
                self.moveRow(
                    at: IndexPath(item: move.oldIndex, section: 0),
                    to: IndexPath(item: move.newIndex, section: 0)
                )
            }
        }
    }
}
