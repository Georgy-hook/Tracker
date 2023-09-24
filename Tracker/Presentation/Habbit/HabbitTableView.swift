//
//  HabbitTableView.swift
//  Tracker
//
//  Created by Georgy on 28.08.2023.
//

import UIKit

class HabbitTableView: UITableView {
    
    // MARK: - Variables
    private let cellTexts = ["Категория", "Расписание"]
    private var cellDetailTexts = ["",""]
    weak var delegateVC:HabbitViewControllerProtocol? {
        didSet{
            if delegateVC?.isIrregular ?? false { numbersOfRows = 1 }
        }
    }
    private var numbersOfRows = 2
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
    
    override var intrinsicContentSize: CGSize {
        return  CGSize(width: 0, height: 75 * numbersOfRows - 1)
     }
}

extension HabbitTableView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbersOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.text = cellTexts[indexPath.row]
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        
        cellDetailTexts[0] = TempStorage.shared.getCategory() ?? ""
        cellDetailTexts[1] = formatWeekdays(TempStorage.shared.getShedule())
        cell.detailTextLabel?.text = cellDetailTexts[indexPath.row]
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor(named: "YP Gray")
        return cell
    }
    
    
}

extension HabbitTableView:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            delegateVC?.presentCategoryVC()
        case 1:
            delegateVC?.presentSheduleVC()
        default:
            break
        }
        deselectRow(at: indexPath, animated: true)
    }
}

extension HabbitTableView{
    func formatWeekdays(_ weekdays: [Int]?) -> String {
        guard let weekdays = weekdays else { return "" }
        let weekdaysArray = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        var formattedWeekdays: [String] = []
        
        for index in weekdays {
            if index >= 0 && index < weekdaysArray.count {
                formattedWeekdays.append(weekdaysArray[index])
            }
        }
        
        return formattedWeekdays.joined(separator: ", ")
    }


}
