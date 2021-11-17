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

        return controller
    }
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    private let tabs: [Tab] = [.home, .group, .journey, .profile]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
}
