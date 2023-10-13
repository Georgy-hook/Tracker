//
//  PageViewController.swift
//  Tracker
//
//  Created by Georgy on 24.09.2023.
//

import UIKit

final class PageViewController:UIViewController{
    
    // MARK: - UI Elements
    private var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    // MARK: - Initialization
    init(image: UIImage?, labelText: String?, buttonTitle: String?) {
        super.init(nibName: nil, bundle: nil)
        
        if let image = image {
            imageView.image = image
        }
        
        if let labelText = labelText {
            label.text = labelText
        }
        
        if let buttonTitle = buttonTitle {
            button.setTitle(buttonTitle, for: .normal)
        }
        
        configureUI()
        addSubviews()
        applyConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func didTapButton(){
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}

// MARK: - Layout
extension PageViewController{
    private func configureUI() {
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(button)
        view.addSubview(label)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 388),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
            
        ])
        
    }
}
