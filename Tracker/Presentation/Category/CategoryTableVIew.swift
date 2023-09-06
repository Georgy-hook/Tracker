//
//  CategoryTableView.swift
//  Tracker
//
//  Created by Georgy on 30.08.2023.
//

import UIKit

class CategoryTableView:UITableView{
    // MARK: - Variables
    private var categories:[String] = ["dfdfsdfdsf","adfdfsdf","fdfsdfsdf","dfdfsdfdsf","adfdfsdf","fdfsdfsdf","dfdfsdfdsf","adfdfsdf","fdfsdfsdf","wdfwfwsdfsfd","wdfsdfsdfsdfds"]
    
    var delegateVC: CategoryViewControllerProtocol?
    
    // MARK: - Initiliazation
    init() {
        super.init(frame: .zero, style: .plain)
        translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 16
        self.backgroundColor = .clear
        self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.showsVerticalScrollIndicator = false
        self.tintColor = .clear
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource
extension CategoryTableView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor(named: "YP Background")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        cell.textLabel?.text = categories[indexPath.row]
        //cell.accessoryType = .none
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
    
    
}
