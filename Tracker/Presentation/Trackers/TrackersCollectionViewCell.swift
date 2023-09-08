//
//  TrackersCollectionViewCell.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit

class TrackersCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "TrackersCollectionViewCell"
    
    private var tracker:Tracker? {
        didSet{
            configureUI()
        }
    }
    
    private var completedDays = 0 {
        didSet {
            counterLabel.text = dayToString(completedDays)
        }
    }
    
    var delegateVC: TrackersViewControllerProtocol?
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YP Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ButtonPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(UIImage(named: "Done")?.withRenderingMode(.alwaysTemplate), for: .selected)
        button.layer.cornerRadius = 17
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        
        return view
    }()
    private let emojiTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        textField.isUserInteractionEnabled = false
        textField.layer.cornerRadius = 12
        textField.clipsToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubviews()
        applyConstraints()
        checkButton.addTarget(self, action: #selector(checkButtonDidTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension TrackersCollectionViewCell {
    
    private func configureUI(){
        guard let tracker = tracker else { return }
        checkButton.isSelected = false
        emojiTextField.text = tracker.emoji
        descriptionLabel.text = tracker.name
        cardView.backgroundColor = UIColor(named: tracker.color)
        checkButton.backgroundColor = .clear
        checkButton.setImage(UIImage(named: "ButtonPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkButton.tintColor = isSelected ? UIColor(named: "YP White"):UIColor(named: tracker.color)
        counterLabel.text = dayToString(completedDays)
        isThisDaySelected()
        
    }
    
    private func addSubviews() {
        addSubview(cardView)
        addSubview(emojiTextField)
        addSubview(descriptionLabel)
        addSubview(counterLabel)
        addSubview(checkButton)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiTextField.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiTextField.widthAnchor.constraint(equalToConstant: 24),
            emojiTextField.heightAnchor.constraint(equalToConstant: 24),
            
            descriptionLabel.topAnchor.constraint(equalTo: emojiTextField.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            checkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            checkButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            checkButton.heightAnchor.constraint(equalToConstant: 34),
            checkButton.widthAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: checkButton.leadingAnchor, constant: -8),
            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16)
        ])
    }
    
    private func dayToString(_ num: Int) -> String {
        let suffix: String
        
        switch num % 10 {
        case 1 where (num - 1) % 100 != 10:
            suffix = "день"
        case 2 where (num - num % 10) % 100 != 10:
            suffix = "дня"
        case 3 where (num - num % 10) % 100 != 10:
            suffix = "дня"
        case 4 where (num - num % 10) % 100 != 10:
            suffix = "дня"
        default:
            suffix = "дней"
        }
        
        return "\(num) \(suffix)"
    }
}

// MARK: - Cell's methods
extension TrackersCollectionViewCell{
    func set(with tracker: Tracker){
        self.tracker = tracker
    }
}

// MARK: - Actions
private extension TrackersCollectionViewCell{
    @objc func checkButtonDidTapped(){
        guard let tracker = tracker else { return }
        let currentDay = delegateVC?.currentDate ?? Date()
        guard currentDay <= Date() else { return }
        
        if !checkButton.isSelected{
            checkButton.backgroundColor = UIColor(named: tracker.color)
            checkButton.tintColor = UIColor(named: "YP White")
            completedDays += 1
            
            checkButton.isSelected.toggle()
            delegateVC?.addCompletedTracker(tracker)
        } else{
            
            checkButton.backgroundColor = .clear
            checkButton.tintColor = UIColor(named: tracker.color)
            completedDays -= 1
            
            checkButton.isSelected.toggle()
            delegateVC?.removeCompletedTracker(tracker)
        }
    }
    
    func isThisDaySelected(){
        guard let tracker = tracker else { return }
        let currentDay = delegateVC?.currentDate ?? Date()
        let containsRecordWithCurrentDate = delegateVC?.completedTrackers.contains { record in
            return Calendar.current.isDate(record.date, inSameDayAs: currentDay)
        } ?? false
        if containsRecordWithCurrentDate {
            checkButton.isSelected = true
            checkButton.backgroundColor = UIColor(named: tracker.color)
            checkButton.tintColor = UIColor(named: "YP White")
        }else{
            checkButton.isSelected = false
            checkButton.backgroundColor = .clear
            checkButton.tintColor = UIColor(named: tracker.color)
            
        }
    }
}