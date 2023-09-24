//
//  Table + TextField CollectionCell.swift
//  Tracker
//
//  Created by Georgy on 29.08.2023.
//

import UIKit
class ListCollectionViewCell:UICollectionViewCell{
    
    // MARK: - Variables
    static let reuseId = "ListCollectionViewCell"
    weak var delegateVC: HabbitViewControllerProtocol?
    
    // MARK: - UI Elements
    private let trackerName: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название трекера"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "YP Background")
        textField.layer.cornerRadius = 16
        textField.textColor = UIColor(named: "YP Black")
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let habbitTableView = HabbitTableView()
    
    // MARK: - Initialiaze
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        applyConstraints()
        
        trackerName.delegate = self
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        habbitTableView.delegateVC = delegateVC
    }
}

extension ListCollectionViewCell{
    private func addSubviews() {
        addSubview(trackerName)
        addSubview(habbitTableView)
    }
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            trackerName.topAnchor.constraint(equalTo: topAnchor),
            trackerName.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackerName.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            
            habbitTableView.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24),
            habbitTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            habbitTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            //habbitTableView.heightAnchor.constraint(equalToConstant: 149)
        ])
    }
}

extension ListCollectionViewCell:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let name = textField.text else {
            return
        }
        TempStorage.shared.setName(name)
        delegateVC?.shouldUpdateUI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}

extension ListCollectionViewCell{
    func updateTableView(){
        habbitTableView.reloadData()
    }
}
