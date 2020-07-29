//
//  SavedSearch.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/13/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
import OctagonAnalyticsService

class SavedSearch {

    var keys: [String]          = []

    var data: [String: Any?]    = [:]

    var columnsWidth: [CGFloat] = []

    //MARK: Functions
    init(_ responseModel: SavedSearchService) {
        self.data   =   responseModel.data
    }
}
