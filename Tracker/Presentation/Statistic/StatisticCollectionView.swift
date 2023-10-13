//
//  StatisticCollectionView.swift
//  Tracker
//
//  Created by Georgy on 10.10.2023.
//
import UIKit

class StatisticCollectionView: UICollectionView {
    // MARK: - Variables
    private let params = GeometricParams(cellCount: 1, leftInset: 16, rightInset: 16, cellSpacing: 9)
    private var model: [StatisticsElement] = []
    
    // MARK: - Initiliazation
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        delegate = self
        dataSource = self
        register(StatisticCollectionViewCell.self, forCellWithReuseIdentifier: StatisticCollectionViewCell.reuseId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(with model:[StatisticsElement]){
        self.model = model
        self.reloadData()
    }
}

extension StatisticCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: StatisticCollectionViewCell.reuseId, for: indexPath) as? StatisticCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.set(with: model[indexPath.item])
        return cell
    }
}

extension StatisticCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
}

