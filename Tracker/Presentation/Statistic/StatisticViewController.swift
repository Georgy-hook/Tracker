//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit

final class StatisticViewController: UIViewController {
    //MARK: - UI Elements
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Statistic placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("There is nothing to analyze yet", comment: "")
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statisticCollectionView = StatisticCollectionView()
    
    //MARK: - Variables
    private let viewModel = StatisticViewModel()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$StatisticsModel.bind{ [weak self] _ in
            guard let self = self else { return }
            statisticCollectionView.set(with: viewModel.StatisticsModel)
        }
        
        viewModel.$currentState.bind{ [weak self] _ in
            guard let self = self else { return }
            updatePlaceholder(for: viewModel.currentState)
        }
        configureUI()
        addSubviews()
        applyConstraints()
        
    }

}

// MARK: - Layout
extension StatisticViewController {
    private func configureUI() {
        view.backgroundColor = UIColor(named: "YP White")
        self.title = NSLocalizedString("Statistics", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = UIColor(named: "YP Black")
        viewModel.initial()
    }
    
    private func addSubviews() {
        view.addSubview(statisticCollectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(initialLabel)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 193),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            initialLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            initialLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            statisticCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statisticCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            statisticCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func updatePlaceholder(for state: PlaceholderState) {
        switch state {
        case .noData:
            placeholderImageView.isHidden = false
            initialLabel.isHidden = false
        case .hide:
            placeholderImageView.isHidden = true
            initialLabel.isHidden = true
        default:
            return
        }
    }
}

