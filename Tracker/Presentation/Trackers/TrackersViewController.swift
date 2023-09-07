//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Georgy on 27.08.2023.
//

import UIKit

protocol TrackersViewControllerProtocol{
    func addCompletedTracker(_ tracker: Tracker)
    func removeCompletedTracker(_ tracker: Tracker)
    var currentDate:Date { get }
}

final class TrackersViewController: UIViewController {
    
    //MARK: - UI Elements
    private let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Поиск"
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
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackersCollectionView = TrackersCollectionView()
    
    //MARK: - Variables
    private var trackersCategories:[TrackerCategory] = [] {
        didSet{
            changePlaceholder(trackersCategories.isEmpty)
            visibleTrackers = trackersCategories
        }
    }
    private var visibleTrackers:[TrackerCategory] = []
    private let tempStorage = TempStorage.shared
    private let dateFormatter = AppDateFormatter.shared
    private var completedTrackers: [TrackerRecord] = []
    private var completedID: Set<UUID> = []
    var currentDate: Date = Date() {
        didSet {
            filterRelevantTrackers()
        }
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addSubviews()
        applyConstraints()
        
        searchController.searchResultsUpdater = self
    }
}

//MARK: - Layout
extension TrackersViewController{
    private func configureUI(){
        view.backgroundColor = UIColor(named: "YP White")
        configureNavBar()
        changePlaceholder(trackersCategories.isEmpty)
        trackersCollectionView.delegateVC = self
    }
    
    private func addSubviews(){
        view.addSubview(placeholderImageView)
        view.addSubview(initialLabel)
    }
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 220),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            initialLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            initialLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            
        ])
    }
}

//MARK: - NavigationBar
extension TrackersViewController{
    private func configureNavBar(){
        self.title = "Трекеры"
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
        present(ChooseTypeVC(), animated: true)
    }
    
    @objc private func dateChange(sender: UIDatePicker){
        currentDate = sender.date
    }
}

//MARK: - SearchController
extension TrackersViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let lowercaseSearchText = searchController.searchBar.searchTextField.text?.lowercased() else{ return }
        let filteredCategories = trackersCategories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.name.lowercased().hasPrefix(lowercaseSearchText)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        visibleTrackers = filteredCategories
        changePlaceholder(filteredCategories.isEmpty)
        trackersCollectionView.set(cells: visibleTrackers)
    }
}

//MARK: - TrackersViewControllerProtocol
extension TrackersViewController:TrackersViewControllerProtocol {
    func updateTrackers(with track:Tracker){
        guard let title = tempStorage.getCategory() else { return }
        if trackersCategories.isEmpty {
            self.trackersCategories.append(TrackerCategory(title: title, trackers: [track]))
            addCollectionView()
        }
        else{
            for tracker in self.trackersCategories {
                if tracker.title == tempStorage.getCategory(){
                    tracker.addedNewTracker(track)
                }else{
                    self.trackersCategories.append(TrackerCategory(title: title, trackers: [track]))
                }
            }
        }
        trackersCollectionView.set(cells: visibleTrackers)
        tempStorage.resetTempTracker()
    }
    
    func addCompletedTracker(_ tracker: Tracker) {
        let newRecord = TrackerRecord(recordID: tracker.id, date: Date())
        completedTrackers.append(newRecord)
    }
    
    func removeCompletedTracker(_ tracker: Tracker) {
        completedTrackers.removeAll { $0.recordID == tracker.id }
    }
    
    private func addCollectionView(){
        
        view.addSubview(trackersCollectionView)
        
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//MARK: - Filter methods
extension TrackersViewController{
    private func filterRelevantTrackers() {
        let currentDay = dateFormatter.dateToDays(with: currentDate)
        
        let result = trackersCategories.compactMap { category in
            let relevantTrackers = category.trackers.filter { tracker in
                tracker.getDays().contains(currentDay)
            }
            
            return relevantTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: relevantTrackers)
        }
        visibleTrackers = result
        trackersCollectionView.set(cells: visibleTrackers)
    }
    
    private func changePlaceholder(_ isEmpty: Bool) {
        placeholderImageView.image = UIImage(named: trackersCategories.isEmpty ? "RoundStar" : "NotFound")
        initialLabel.text = trackersCategories.isEmpty ? "Что будем отслеживать?" : "Ничего не найдено"
        
        placeholderImageView.isHidden = !isEmpty
        initialLabel.isHidden = !isEmpty
    }
}
