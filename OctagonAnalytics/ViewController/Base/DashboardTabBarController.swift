//
//  DashboardTabBarController.swift
//  OctagonAnalytics
//
//  Created by Rameez on 8/22/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import UIKit

class DashboardTabBarController: UITabBarController {

    enum TabItem: Int {
        case dashboard = 0
        case canvas
    }
        
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showDashboard(_ dashboardId: String) {
        
        guard let navController = self.customizableViewControllers?[TabItem.dashboard.rawValue] as? UINavigationController,
        let dashboardListCtr = navController.viewControllers.first as? DashboardListingViewController else { return }
        navController.popToRootViewController(animated: false)
        self.selectedIndex = TabItem.dashboard.rawValue
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dashboardListCtr.showDashboardWith(dashboardId)
        }
    }
}
