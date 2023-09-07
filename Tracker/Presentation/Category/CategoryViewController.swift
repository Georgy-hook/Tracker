//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Georgy on 29.08.2023.
//
import UIKit

protocol CategoryViewControllerProtocol{
    func presentHabbitVC()
}

final class CategoryViewController: UIViewController {
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "RoundStar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    let initialLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
        label.textAlignment = .center
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.tintColor = UIColor(named: "YP White")
        button.backgroundColor = UIColor(named: "YP Black")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        return button
    }()
    let categoryTableView = CategoryTableView()
    // MARK: - Variables
    var categories:[String] = ["Happy moments",
                                       "Diary",
                                       "Friends",
                                       "Holidays",
                                       "Birthdays",
                                       "Pets"]
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.delegateVC = self
        configureUI()
        addSubviews()
        applyConstraints()
        categoryTableView.set(with: categories)
    }
}

// MARK: - Layout
extension CategoryViewController {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        
        if categories.count == 0{
            
        }else{
            starImageView.isHidden = true
            initialLabel.isHidden = true
        }
        
        addButton.addTarget(self, action: #selector(didAddButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
       
        view.addSubview(starImageView)
        view.addSubview(initialLabel)
        view.addSubview(addButton)
        view.addSubview(categoryTableView)
        view.addSubview(titleLabel)
        
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            starImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 246),
            starImageView.widthAnchor.constraint(equalToConstant: 80),
            starImageView.heightAnchor.constraint(equalTo: starImageView.widthAnchor),
            
            initialLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialLabel.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 8),
            initialLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            initialLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            

            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.bottomAnchor.constraint(lessThanOrEqualTo: addButton.topAnchor),
            categoryTableView.heightAnchor.constraint(equalToConstant: CGFloat(categories.count * 75))
        ])
    }
}

// MARK: - Actions
extension CategoryViewController{
    @objc private func didAddButtonTapped(){
        present(NewCategoryViewController(), animated: true)
    }
}

extension CategoryViewController:CategoryViewControllerProtocol{
    func presentHabbitVC(){
        guard let presentingViewController = self.presentingViewController as? HabbitViewController else{return}
        presentingViewController.shouldUpdateUI()
        dismiss(animated: true)
    }
}
