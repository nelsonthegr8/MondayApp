//
//  MasterTabBarViewController.swift
//  Monday Clock In Tracker
//
//  Created by Nelson Brumaire on 12/15/19.
//  Copyright © 2019 Nelson Brumaire. All rights reserved.
//

import UIKit

class MasterTabBarViewController: UITabBarController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setTabBarApperance()
    }
    
    private func setTabBarApperance()
    {
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .blue
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for:.normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for:.selected)
        self.tabBar.unselectedItemTintColor = UIColor.black
    }
    
}
