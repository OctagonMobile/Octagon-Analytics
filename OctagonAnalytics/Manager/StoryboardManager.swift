//
//  StoryboardManager.swift
//  KibanaGo
//
//  Created by Rameez on 10/25/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case main   = "Main"
    case charts = "Charts"
    case savedSearch = "SavedSearch"
    case search = "Search"
}

class StoryboardManager: NSObject {

    static let shared = StoryboardManager()
    
    func storyBoard(_ type: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: type.rawValue, bundle: Bundle.main)
    }

}
