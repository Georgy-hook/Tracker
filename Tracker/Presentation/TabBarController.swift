//
//  TabBarController.swift
//  Tracker
//
//  Created by Georgy on 26.08.2023.
//

import UIKit
final class TabBarController: UITabBarController {
    
    //MARK: - Variables
    var tracker:Tracker?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = UIColor(named: "YP White")
        self.tabBar.backgroundColor = UIColor(named: "YP White")
        self.tabBar.tintColor = UIColor(named: "YP Blue")
        self.tabBar.unselectedItemTintColor = UIColor(named: "YP Gray")
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor(named: "YP White")
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let trackersViewController = TrackersViewController()
        let nav = UINavigationController(rootViewController: trackersViewController)
        if let tracker = tracker{trackersViewController.updateTrackers(with: tracker)}
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tabTrackers"),
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
            
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tabStatistic"),
            selectedImage: nil
        )
        
        self.viewControllers = [nav, statisticViewController]
    }
}
