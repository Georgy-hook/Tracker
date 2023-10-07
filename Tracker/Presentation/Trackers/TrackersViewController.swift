//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject{
    func addCompletedTracker(_ tracker: Tracker)
    func removeCompletedTracker(_ tracker: Tracker)
    func countRecords(forUUID uuid: UUID) -> Int
    func getCurrentDate() -> Date
}

final class TrackersViewController: UIViewController {
    
    //MARK: - UI Elements
    private let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.isUserInteractionEnabled = false
        search.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.tintColor = UIColor(named: "YP Blue")
        search.searchBar.searchTextField.textColor = UIColor(named: "YP Black")
        return search
    }()
    
    private let datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = UIColor(named: "YP Blue")
        return datePicker
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "RoundStar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let initialLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("What will we track?", comment: "")
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackersCollectionView = TrackersCollectionView()
    
    //MARK: - Variables
    private let viewModel = TrackersViewModel()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()
        
        searchController.searchResultsUpdater = self
        
        viewModel.$trackers.bind{ [weak self] _ in
            guard let self = self else { return }
            trackersCollectionView.set(cells: viewModel.trackers)
        }
        
        viewModel.$currentState.bind{ [weak self] _ in
            guard let self = self else { return }
            updatePlaceholder(for: viewModel.currentState)
        }
        
        viewModel.$currentDate.bind{ [weak self] _ in
            guard let self = self else { return }
            viewModel.filterRelevantTrackers(for: viewModel.currentDate)
        }
        
        viewModel.$completedID.bind{ [weak self] _ in
            guard let self = self else { return }
            trackersCollectionView.setCompletedTrackers(with: viewModel.completedID)
        }
        viewModel.configure()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches,with: event)
        view.endEditing(true)
    }
}

//MARK: - Layout
extension TrackersViewController{
    private func configureUI(){
        view.backgroundColor = UIColor(named: "YP White")
        configureNavBar()
        trackersCollectionView.delegateVC = self        
    }
    
    private func addSubviews(){
        view.addSubview(placeholderImageView)
        view.addSubview(initialLabel)
        view.addSubview(trackersCollectionView)
    }
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            initialLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            initialLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
    }
}

//MARK: - NavigationBar
extension TrackersViewController{
    private func configureNavBar(){
        self.title = NSLocalizedString("Trackers", comment: "")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = UIColor(named: "YP Black")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Add tracker"),
            style: .plain, target: self,
            action: #selector(didTapLeftButton)
        )
        self.navigationItem.searchController = searchController
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(
            self, action:
                #selector(dateChange(sender:)),
            for: UIControl.Event.valueChanged
        )
    }
    
    @objc private func didTapLeftButton(){
        viewModel.resetTempTracker()
        present(ChooseTypeVC(), animated: true)
    }
    
    @objc private func dateChange(sender: UIDatePicker){
        viewModel.setCurrentDate(with: sender.date)
    }
}

//MARK: - SearchController
extension TrackersViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let lowercaseSearchText = searchController.searchBar.searchTextField.text?.lowercased() else { return }
        viewModel.searchRelevantTrackers(with: lowercaseSearchText)
    }
}

//MARK: - TrackersViewControllerProtocol
extension TrackersViewController:TrackersViewControllerProtocol {
    func addCompletedTracker(_ tracker: Tracker) {
        viewModel.addCompletedTracker(tracker)
    }
    
    func removeCompletedTracker(_ tracker: Tracker) {
        viewModel.removeCompletedTracker(tracker)
    }
    
    func countRecords(forUUID uuid: UUID) -> Int{
        return viewModel.countRecords(forUUID: uuid)
    }
    
    func getCurrentDate() -> Date{
        return viewModel.currentDate
    }
}

//MARK: - Filter methods
extension TrackersViewController{
    private func updatePlaceholder(for state: PlaceholderState) {
        placeholderImageView.isHidden = false
        initialLabel.isHidden = false
        switch state {
        case .noData:
            placeholderImageView.image = UIImage(named: "RoundStar")
            initialLabel.text = NSLocalizedString("What will we track?", comment: "")
        case .notFound:
            placeholderImageView.image = UIImage(named: "NotFound")
            initialLabel.text = NSLocalizedString("Nothing found", comment: "")
        case .hide:
            searchController.searchBar.isUserInteractionEnabled = true
            placeholderImageView.isHidden = true
            initialLabel.isHidden = true
        }
    }

}
