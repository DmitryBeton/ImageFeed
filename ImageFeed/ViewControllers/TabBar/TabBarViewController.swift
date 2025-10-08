//
//  TabBarViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 06.10.2025.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    // MARK: - Private Methods
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) // #1A1B22
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        
        tabBar.standardAppearance = appearance
                
        tabBar.tintColor = .white // selected item color
        tabBar.unselectedItemTintColor = .white // unselected items color
    }
    
    private func setupViewControllers() {
        let imagesListViewController = ImagesListViewController()
        let profileViewController = ProfileViewController()
        
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
