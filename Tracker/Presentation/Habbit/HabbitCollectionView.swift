//
//  HabbitCollectionView.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//
//TODO: Если видны не все секции ячейки заполняются неправильно
import UIKit

final class HabbitCollectionView: UICollectionView {
    // MARK: - Variables
    private let params = GeometricParams(cellCount: 6, leftInset: 19, rightInset: 19, cellSpacing: 5)
    var delegateVC: HabbitViewControllerProtocol?
    // MARK: - Initiliazation
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        register(HabbitCollectionViewCell.self, forCellWithReuseIdentifier: HabbitCollectionViewCell.reuseId)
        register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.reuseId)
        register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        //TODO: allowsMultipleSelection = true пока непонятно как взять по одному из каждой секции
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UICollectionViewDataSource
extension HabbitCollectionView:UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            1
        default:
            18
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.reuseId, for: indexPath) as! ListCollectionViewCell
            cell.delegateVC = delegateVC
            return cell
        default:
            let cell = dequeueReusableCell(withReuseIdentifier: HabbitCollectionViewCell.reuseId, for: indexPath) as! HabbitCollectionViewCell
            cell.set(with: indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension HabbitCollectionView:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        
        var titleLabel:String
        switch indexPath.section{
        case 1:
            titleLabel = "Emoji"
        case 2:
            titleLabel = "Цвет"
        default:
            titleLabel = ""
        }
        
        view.titleLabel.text = titleLabel
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = cellForItem(at: indexPath) as? HabbitCollectionViewCell
        cell?.isSelected(for: indexPath)
        cell?.didTapped(on: indexPath)
        delegateVC?.shouldUpdateUI()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = cellForItem(at: indexPath) as? HabbitCollectionViewCell
        cell?.isDeselected(for: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HabbitCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section{
        case 0:
            UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
        default:
            UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section{
        case 0:
            return CGSize(width: collectionView.frame.width - 32, height: 250)
        default:
            let availableWidth = collectionView.frame.width - params.paddingWidth
            let cellWidth =  availableWidth / CGFloat(params.cellCount)
            return CGSize(width: cellWidth, height: cellWidth)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 6
    }
}

extension HabbitCollectionView{
    func shouldUpdateTableView(){
        let indexPath = IndexPath(item: 0, section: 0)
        guard let cell = self.cellForItem(at: indexPath) as? ListCollectionViewCell else {return}
        
        cell.updateTableView()
    }
}
