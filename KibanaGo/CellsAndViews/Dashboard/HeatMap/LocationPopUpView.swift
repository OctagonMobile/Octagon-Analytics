//
//  LocationPopUpView.swift
//  KibanaGo
//
//  Created by Rameez on 1/4/18.
//  Copyright © 2018 MyCompany. All rights reserved.
//

import UIKit

class LocationPopUpView: UIView {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countValueLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var latitudeValueLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var longitudeValueLabel: UILabel!
    
    @IBOutlet weak var topContentHolderView: UIView!
    
    private var mapDetail: MapDetails?
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        let titleTextStyle = CurrentTheme.caption2TextStyle(CurrentTheme.darkBackgroundColor)
        let valueTextStyle = CurrentTheme.textStyleWith(11.0, weight: .semibold, color: CurrentTheme.darkBackgroundColor)

        countLabel.style(titleTextStyle)
        countValueLabel.style(valueTextStyle)
        latitudeLabel.style(titleTextStyle)
        latitudeValueLabel.style(valueTextStyle)
        longitudeLabel.style(titleTextStyle)
        longitudeValueLabel.style(valueTextStyle)

        topContentHolderView.backgroundColor = CurrentTheme.cellBackgroundColor.withAlphaComponent(0.6)
        topContentHolderView.style(.roundCorner(5.0, 0.0, .clear))
    }
    
    func setup(_ mapDetail: MapDetails) {
        
        self.mapDetail = mapDetail
        countLabel.text = mapDetail.type.capitalized
        countValueLabel.text = "\(NSNumber(value: mapDetail.docCount).formattedWithSeparatorIgnoringDecimal)"
        
        if let location = mapDetail.location {
            latitudeValueLabel.text = String(format: "%0.8f", location.coordinate.latitude)
            longitudeValueLabel.text = String(format: "%0.8f", location.coordinate.longitude)
        }
    }    
}
