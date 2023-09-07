//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Georgy on 29.08.2023.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
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
        button.backgroundColor = UIColor(named: "YP Gray")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 16
        return button
    }()
    let categoryName: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название категории"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "YP Background")
        textField.layer.cornerRadius = 16
        textField.textColor = UIColor(named: "YP Black")
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    // MARK: - Variables
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
    }
}

// MARK: - Layout
extension NewCategoryViewController {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        
        addButton.addTarget(self, action: #selector(didAddButtonTapped), for: .touchUpInside)
        
        categoryName.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(categoryName)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryName.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoryName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryName.heightAnchor.constraint(equalToConstant: 75),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
}

// MARK: - Actions
extension NewCategoryViewController{
    @objc private func didAddButtonTapped(){
        guard let categoryName = categoryName.text else {return}
        let categoryVC = CategoryViewController()
        categoryVC.categories.append(categoryName)
        dismiss(animated: true)
    }
}

extension NewCategoryViewController:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.text != "" else {
            addButton.isUserInteractionEnabled = false
            addButton.backgroundColor = UIColor(named: "YP Gray")
            return
        }
        addButton.isUserInteractionEnabled = true
        addButton.backgroundColor = UIColor(named: "YP Black")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
