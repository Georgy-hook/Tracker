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
    var currentDate:Date { get }
    var completedTrackers: [TrackerRecord] {get}
}

final class TrackersViewController: UIViewController {
    
    //MARK: - UI Elements
    private let searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.isUserInteractionEnabled = false
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
    private var trackersCategories:[TrackerCategory] = []
    private var visibleTrackers:[TrackerCategory] = []
    private let tempStorage = TempStorage.shared
    private let dateFormatter = AppDateFormatter.shared
    var completedTrackers: [TrackerRecord] = []
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var currentDate: Date = Date() {
        didSet {
            filterRelevantTrackers()
            let completedID = trackerRecordStore.getCompletedID(with: currentDate)
            setCompletedTrackers(with: completedID)
            currentState = trackerStore.isEmpty() ? .notFound:.hide
        }
    }
    
    var currentState: placeholderState = .noData {
        didSet{
            updatePlaceholder(for: currentState)
        }
    }
    
    enum placeholderState{
        case noData
        case notFound
        case hide
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
        trackerStore.delegate = trackersCollectionView
        currentDate = datePicker.date
        currentState = trackerStore.isEmpty() ? .noData:.hide
        trackersCollectionView.delegateVC = self
        trackersCollectionView.set(cells: trackerStore.trackers)
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
        tempStorage.resetTempTracker()
        present(ChooseTypeVC(), animated: true)
    }
    
    @objc private func dateChange(sender: UIDatePicker){
        currentDate = sender.date
    }
}

//MARK: - SearchController
extension TrackersViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let lowercaseSearchText = searchController.searchBar.searchTextField.text?.lowercased() else { return }
        
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        
        do {
            try trackerStore.searchTrackers(with: lowercaseSearchText, forDay: currentDay)
            trackersCollectionView.set(cells: trackerStore.trackers)
            currentState = trackerStore.isEmpty() ? .notFound:.hide
        } catch {
            print("Error searching for trackers: \(error)")
        }
    }
}

//MARK: - TrackersViewControllerProtocol
extension TrackersViewController:TrackersViewControllerProtocol {
    func addCompletedTracker(_ tracker: Tracker) {
        let newRecord = TrackerRecord(recordID: tracker.id, date: currentDate)
        do{
            try trackerRecordStore.addNewRecord(newRecord)
        } catch{
            print("Error with completedTrackers: \(error)")
        }
    }
    
    func removeCompletedTracker(_ tracker: Tracker) {
        do {
            try trackerRecordStore.removeRecord(for: tracker.id, with: currentDate)
        } catch {
            print("No delete: \(error)")
        }
    }
    
    func setCompletedTrackers(with completedID:Set<UUID>){
        trackersCollectionView.setCompletedTrackers(with: completedID)
    }
    
    func countRecords(forUUID uuid: UUID) -> Int{
        return trackerRecordStore.countRecords(forUUID: uuid)
    }
    
}

//MARK: - Filter methods
extension TrackersViewController{
    private func filterRelevantTrackers() {
        let currentDay = dateFormatter.dayOfWeekInt(for: currentDate)
        
        do {
            try trackerStore.fetchRelevantTrackers(forDay: currentDay)
            trackersCollectionView.set(cells: trackerStore.trackers)
        }
        catch {
           print(error)
        }
       
    }

    private func updatePlaceholder(for state: placeholderState) {
        placeholderImageView.isHidden = false
        initialLabel.isHidden = false
        switch state {
        case .noData:
            placeholderImageView.image = UIImage(named: "RoundStar")
            initialLabel.text = "Что будем отслеживать?"
        case .notFound:
            placeholderImageView.image = UIImage(named: "NotFound")
            initialLabel.text = "Ничего не найдено"
        case .hide:
            searchController.searchBar.isUserInteractionEnabled = true
            placeholderImageView.isHidden = true
            initialLabel.isHidden = true
        }
    }

}
