//
//  InputControlsVisState.swift
//  OctagonAnalytics
//
//  Created by Rameez on 2/23/20.
//  Copyright © 2020 Octagon Mobile. All rights reserved.
//

import Foundation
import OctagonAnalyticsService

class InputControlsVisState: VisState {
    
    var controls: [Control]  =  []
    
    override init(_ responseModel: VisStateService) {
        super.init(responseModel)
        
        guard let controlsServiceVis = responseModel as? InputControlsVisStateService else { return }
        self.controls   =   controlsServiceVis.controls.compactMap({ Control($0) })
    }
}

class Control {
    
    var id: String              =   ""
    var indexPattern: String    =   ""
    var fieldName: String       =   ""
    var parent: String          =   ""
    var label: String           =   ""
    var type: ControlService.ControlType       =   .range
    var rangeOptions: RangeOptions?
    var listOptions: ListOptions?

    init(_ responseModel: ControlService) {
        self.id  =   responseModel.id
        self.indexPattern   =   responseModel.indexPattern
        self.fieldName      =   responseModel.fieldName
        self.parent         =   responseModel.parent
        self.label          =   responseModel.label
        self.type           =   responseModel.type
        
        if let range = responseModel.rangeOptions {
            self.rangeOptions   =   RangeOptions(range)
        }
        
        if let listOpt = responseModel.listOptions {
            self.listOptions   =   ListOptions(listOpt)
        }
    }
}

class RangeOptions {
    
    var decimalPlaces: Int  =   0
    var step: Int           =   0

    init(_ responseModel: RangeOptionsService) {
        self.decimalPlaces  =   responseModel.decimalPlaces
        self.step           =   responseModel.step
    }
}

class ListOptions {
    
    var type: BucketType        =   .unKnown
    var multiselect: Bool       =   true
    var dynamicOptions: Bool    =   true
    var size: Int               =   0
    var order: String           =   ""

    init(_ responseModel: ListOptionsService) {
        self.type           =   responseModel.type
        self.multiselect    =   responseModel.multiselect
        self.dynamicOptions =   responseModel.dynamicOptions
        self.size           =   responseModel.size
        self.order          =   responseModel.order

    }

}
