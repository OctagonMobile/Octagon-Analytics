//
//  IndexPattern.swift
//  OctagonAnalytics
//
//  Created by Rameez on 11/06/2020.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import OctagonAnalyticsService

class IndexPattern: Equatable {
    var id: String              =   ""
    var title: String           =   ""
    var timeFieldName: String   =   ""
    var fields: [IPField]       =   []
    
    init(_ responseModel: IndexPatternService) {
        self.id     =   responseModel.id
        self.title  =   responseModel.title
        self.timeFieldName  =   responseModel.timeFieldName
        self.fields     =   responseModel.fields.compactMap({ IPField($0) })
    }
    
    static func == (lhs: IndexPattern, rhs: IndexPattern) -> Bool {
        return lhs.id == rhs.id
    }
}

class IPField: Equatable, Hashable, CustomStringConvertible {
    var description: String {
        return name
    }
    
    var name                =   ""
    var type                =   ""
    var count               =   0
    var scripted            =   false
    var searchable          =   false
    var aggregatable        =   false
    var readFromDocValues   =   false

    //MARK: Functions

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    init(_ responseModel: IPFieldService) {
        self.name       =   responseModel.name
        self.type       =   responseModel.type
        self.count      =   responseModel.count
        self.scripted   =   responseModel.scripted
        self.searchable =   responseModel.searchable
        self.aggregatable       =   responseModel.aggregatable
        self.readFromDocValues  =   responseModel.readFromDocValues

    }
    
    static func == (lhs: IPField, rhs: IPField) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}

