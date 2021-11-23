//
//  TabbarController.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/11/17.
//

import UIKit

private enum Tab {

    case home

    case group

    case journey

    case profile

    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .home: controller = UIStoryboard.home.instantiateInitialViewController()!

        case .group: controller = UIStoryboard.group.instantiateInitialViewController()!

        case .journey: controller = UIStoryboard.journey.instantiateInitialViewController()!

        case .profile: controller = UIStoryboard.profile.instantiateInitialViewController()!

        }

        controller.tabBarItem = tabBarItem()

        return controller
    }
    
    func tabBarItem() -> UITabBarItem {
        
    switch self {

    case .home:
        return UITabBarItem(
            title: "Home",
            image: UIImage.asset(.route),
            selectedImage: UIImage.asset(.route_fill)
        )

    case .group:
        return UITabBarItem(
            title: "Groups",
            image: UIImage.asset(.group),
            selectedImage: UIImage.asset(.group_fill)
        )

    case .journey:
        return UITabBarItem(
            title: "Journey",
            image: UIImage.asset(.track),
            selectedImage: UIImage.asset(.track_fill)
        )

    case .profile:
        return UITabBarItem(
            title: "Profile",
            image: UIImage.asset(.profile),
            selectedImage: UIImage.asset(.profile_fill)
        )
    }
}
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.home, .group, .journey, .profile]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.controller() })
        
        self.delegate = self
        
        self.tabBar.layer.masksToBounds = true
        
        self.tabBar.isTranslucent = true
        
        self.tabBar.layer.cornerRadius = 10
        
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
}
