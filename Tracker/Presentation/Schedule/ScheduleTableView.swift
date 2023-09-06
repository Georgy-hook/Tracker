//
//  ScheduleTableView.swift
//  Tracker
//
//  Created by Georgy on 30.08.2023.
//

import UIKit

class ScheduleTableView:UITableView{
    // MARK: - Variables
    let weekDays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    var shedule:[Int] = []
    // MARK: - Initiliazation
    init() {
        super.init(frame: .zero, style: .plain)
        translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor(named: "YP Background")
        self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.isScrollEnabled = false
        self.tintColor = UIColor(named: "YP Black")
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource
extension ScheduleTableView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.backgroundColor = .clear
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = weekDays[indexPath.row]
        cell.accessoryType = .none
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        
        let toggle = UISwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
        toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = toggle
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleTableView:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - Actions
extension ScheduleTableView{
    @objc func switchChanged(_ sender: UISwitch) {
        
        if let cell = sender.superview as? UITableViewCell,
           let indexPath = self.indexPath(for: cell) {
            
            let dayOfWeek = weekDays[indexPath.row]
            if sender.isOn {
                if !self.shedule.contains(indexPath.row) {
                    self.shedule.append(indexPath.row)
                }
            } else {
                if let index = self.shedule.firstIndex(of: indexPath.row) {
                    self.shedule.remove(at: index)
                }
            }
            
            TempStorage.shared.setSchedule(shedule)
        }
    }
}
