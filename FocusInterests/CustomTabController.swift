//
//  CustomTabController.swift
//  FocusInterests
//
//  Created by Manish Dwibedy on 5/6/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class CustomTabController: UITabBarController {

    func setBarColor() {
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundImage = UIImage(named: "greenTabBar")
        self.tabBar.tintColor = UIColor.white
        
    }

}
