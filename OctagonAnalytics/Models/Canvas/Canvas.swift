//
//  Canvas.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/4/19.
//  Copyright © 2019 Octagon Mobile. All rights reserved.
//

import OctagonAnalyticsService

class Canvas {
    
    /**
     Title of the dashboard.
     */
    var name                =   ""
    
    /**
     ID of teh dashboard.
     */
    var id                  =   ""
    
    var pages: [CanvasPage] =   []

    //MARK: Functions
    init(_ responseModel: CanvasItemService) {
        self.name   =   responseModel.name
        self.id     =   responseModel.id
        self.pages  =   responseModel.pages.compactMap({ CanvasPage($0) })
    }
}

class CanvasPage {
    
    var pageId: String?

    init(_ responseModel: CanvasPageService) {
        self.pageId =   responseModel.id
    }
}
