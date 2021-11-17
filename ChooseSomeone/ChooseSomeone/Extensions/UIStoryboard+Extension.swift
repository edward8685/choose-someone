//
//  UIStoryboard+Extension.swift
//  ChooseSomeone
//
//  Created by Ed Chang on 2021/10/24.
//

import UIKit

private struct StoryboardCategory {

    static let home = "Home"

    static let group = "ChooseGroup"
    
    static let login = "Login"
    
    static let journey = "Journey"

    static let profile = "Profile"
    
    static let policy = "PrivacyPolicy"
    
    static let main = "Main"
}

extension UIStoryboard {

    static var home: UIStoryboard { return storyboard(name: StoryboardCategory.home) }

    static var group: UIStoryboard { return storyboard(name: StoryboardCategory.group) }
    
    static var login: UIStoryboard { return storyboard(name: StoryboardCategory.login) }

    static var journey: UIStoryboard { return storyboard(name: StoryboardCategory.journey) }

    static var profile: UIStoryboard { return storyboard(name: StoryboardCategory.profile) }
    
    static var policy: UIStoryboard { return storyboard(name: StoryboardCategory.policy) }
    
    static var main: UIStoryboard { return storyboard(name: StoryboardCategory.main) }

    private static func storyboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
