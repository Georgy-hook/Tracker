//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Georgy on 30.08.2023.
//

import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.textColor = UIColor(named: "YP Black")
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.tintColor = UIColor(named: "YP White")
        button.backgroundColor = UIColor(named: "YP Black")
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        return button
    }()
    
    let weekTableView = ScheduleTableView()
    
    // MARK: - Variables
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()
        
        // Additional setup after loading the view.
    }
}

// MARK: - Layout
extension ScheduleViewController {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        
        addButton.addTarget(self, action: #selector(didAddButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(weekTableView)
        view.addSubview(titleLabel)
        view.addSubview(addButton)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            weekTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            weekTableView.heightAnchor.constraint(equalToConstant: 524),
            weekTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ])
    }
}

// MARK: - Actions
extension ScheduleViewController{
    @objc private func didAddButtonTapped(){
        if let presentingViewController = presentingViewController as? HabbitViewController {
            presentingViewController.shouldUpdateUI()
            presentingViewController.sectionsCollectionView.reloadData()
        }
        dismiss(animated: true)
    }

}
