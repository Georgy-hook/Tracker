//
//  StatisticCollectionViewCell.swift
//  Tracker
//
//  Created by Georgy on 10.10.2023.
//

import UIKit

class StatisticCollectionViewCell: UICollectionViewCell {
    static let reuseId = "StatisticCollectionViewCell"
    
    // MARK: - UI Elements
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(named: "YP Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(with model:StatisticsElement) {
        valueLabel.text = String(model.value)
        descriptionLabel.text = model.description
    }
    
    // MARK: - Layout
    private func configureUI() {
        let gradient = UIImage.gradientImage(bounds: bounds, colors: [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1),
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1),
            UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1)
        ])
        let gradientColor = UIColor(patternImage: gradient)
        layer.borderWidth = 1
        layer.borderColor = gradientColor.cgColor
        layer.cornerRadius = 16
    }
    
    private func addSubviews() {
        addSubview(valueLabel)
        addSubview(descriptionLabel)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7)
        ])
    }
}
