//
//  HabbitViewController.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//
import UIKit
protocol HabbitViewControllerProtocol{
    func presentCategoryVC()
    func presentSheduleVC()
    func shouldUpdateUI()
}
final class HabbitViewController: UIViewController {
    
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.layer.cornerRadius = 16
        button.isUserInteractionEnabled = false
        button.backgroundColor = UIColor(named: "YP Gray")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        button.backgroundColor = .clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let sectionsCollectionView = HabbitCollectionView()
    
    // MARK: - Variables
    let tempStrotage = TempStorage.shared
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()
        
        sectionsCollectionView.delegateVC = self
        tempStrotage.setID(UUID())
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         view.endEditing(true)
    }
}

// MARK: - Layout
extension HabbitViewController {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        
        addButton.addTarget(self, action: #selector(didAddButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didCancelButtonTapped), for: .touchUpInside)
        
        shouldUpdateUI()
    }
    
    private func addSubviews() {
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(addButton)
        view.addSubview(stackView)
        view.addSubview(titleLabel)
        view.addSubview(sectionsCollectionView)
        
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 60),
            
            sectionsCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            sectionsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sectionsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sectionsCollectionView.bottomAnchor.constraint(equalTo: stackView.topAnchor)
   
        ])
    }
}

// MARK: - HabbitViewControllerProtocol
extension HabbitViewController:HabbitViewControllerProtocol{
    func presentCategoryVC(){
        present(CategoryViewController(), animated: true)
    }
    
    func presentSheduleVC(){
        present(ScheduleViewController(),animated: true)
    }
    
    func shouldUpdateUI(){
        sectionsCollectionView.shouldUpdateTableView()
        
        guard tempStrotage.buildTracker() != nil else { return }
        addButton.isUserInteractionEnabled = true
        addButton.backgroundColor = UIColor(named: "YP Black")
    }
}

// MARK: - Actions
extension HabbitViewController{
    @objc private func didAddButtonTapped(){
        guard let tracker = tempStrotage.buildTracker() else { return }
        let tabBarController = TabBarController()
        tabBarController.tracker = tracker
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
    
    @objc private func didCancelButtonTapped(){
        dismiss(animated: true)
    }
}
