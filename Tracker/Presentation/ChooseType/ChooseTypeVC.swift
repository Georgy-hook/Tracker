//
//  ChooseTypeVC.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit

final class ChooseTypeVC: UIViewController {
    // MARK: - UI Elements
    let habitButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YP Black")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        return button
    }()
    let irregularEventButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "YP Black")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        return button
    }()
    let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()

    }
}

// MARK: - Layout
extension ChooseTypeVC {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        view.addSubview(titleLabel)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            habitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 281),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension ChooseTypeVC{
    @objc private func habitButtonTapped(){
        let HabbitVC = HabbitViewController()
        present(HabbitVC,animated: true)
    }
    
    @objc private func irregularEventButtonTapped(){
        let HabbitVC = HabbitViewController()
        HabbitVC.isIrregular = true
        present(HabbitVC,animated: true)
    }
}
