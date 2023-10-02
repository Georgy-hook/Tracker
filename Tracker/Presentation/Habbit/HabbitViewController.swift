//
//  HabbitViewController.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//
import UIKit

enum HabbitViewControllerMode {
    case create
    case edit(ID: UUID)
}

protocol HabbitViewControllerProtocol: AnyObject{
    func presentCategoryVC()
    func presentSheduleVC()
    func shouldUpdateUI()
    var isIrregular:Bool {get}
    func setEmoji(_ emoji:String)
    func setColor(_ color:String)
    func setName(_ name:String)
    func getCategory() -> String
    func getShedule() -> [Int]
}

final class HabbitViewController: UIViewController {
    // MARK: - Init
    init(mode: HabbitViewControllerMode) {
        self.mode = mode
        self.viewModel = HabbitViewModel(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.backgroundColor = .clear
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private let addButton: UIButton = {
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
    
    private let cancelButton: UIButton = {
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
    private let viewModel:HabbitViewModel
    private let mode: HabbitViewControllerMode
    
    var isIrregular = false {
        didSet{
            if isIrregular{
                viewModel.setSchedule([0,1,2,3,4,5,6])
                titleLabel.text = "Новое нерегулярное событие"
            }
        }
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$completed.bind{ [weak self] _ in
            guard let self = self else { return }
            shouldOpenButton(viewModel.completed)
        }
        
        configureUI()
        addSubviews()
        applyConstraints()
        
        sectionsCollectionView.delegateVC = self
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
    
    private func shouldOpenButton(_ trackerComplete:Bool){
        if trackerComplete {
            addButton.isUserInteractionEnabled = true
            addButton.backgroundColor = UIColor(named: "YP Black")
        } else{
            addButton.isUserInteractionEnabled = false
            addButton.backgroundColor = UIColor(named: "YP Gray")
        }
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
        viewModel.shouldUpdateUI()
    }
    
    func setEmoji(_ emoji:String){
        viewModel.setEmoji(emoji)
    }
    
    func setColor(_ color:String){
        viewModel.setColor(color)
    }
    
    func setName(_ name:String){
        viewModel.setName(name)
    }
    
    func getCategory() -> String{
        viewModel.getCategory()
    }
    
    func getShedule() -> [Int]{
        viewModel.getShedule()
    }
}

// MARK: - Actions
extension HabbitViewController{
    @objc private func didAddButtonTapped(){
        viewModel.addTracker()
        
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
    
    @objc private func didCancelButtonTapped(){
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}
